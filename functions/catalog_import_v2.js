const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const crypto = require('crypto');

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

function requireAuth(request) {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
  return request.auth.uid;
}

async function isAdmin(uid) {
  const snap = await db.collection('users').doc(uid).get();
  const role = String(snap.data()?.role || '').toLowerCase();
  if (!['admin', 'super_admin'].includes(role)) {
    throw new HttpsError('permission-denied', 'هذه العملية للإدارة فقط');
  }
}

function stableId(raw) {
  const explicit = String(raw?.id || raw?.code || '').trim();
  if (explicit) return explicit.toLowerCase().replace(/[^a-z0-9_-]+/g, '_').replace(/^_+|_+$/g, '').slice(0, 120) || `drug_${hash(raw?.name)}`;
  return `drug_${hash(raw?.name)}`;
}

function hash(value) {
  return crypto.createHash('sha256').update(String(value || '')).digest('hex').slice(0, 16);
}

function text(value, max) {
  const v = String(value ?? '').trim();
  return v ? v.slice(0, max) : null;
}

function safePrice(value) {
  const n = Number(value);
  return Number.isFinite(n) && n > 0 && n <= 100000000 ? Math.round(n * 100) / 100 : null;
}

function chunks(items, size) {
  const out = [];
  for (let i = 0; i < items.length; i += size) out.push(items.slice(i, i + size));
  return out;
}

/**
 * Imports the canonical catalog and creates the platform's own offers.
 * External pharmacy offers remain separate documents and must be approved.
 */
exports.importOfficialCatalogV2 = onCall(async (request) => {
  const uid = requireAuth(request);
  await isAdmin(uid);

  const input = Array.isArray(request.data?.drugs) ? request.data.drugs : [];
  if (input.length !== 300) {
    throw new HttpsError('invalid-argument', `يجب إرسال 300 سجل بالضبط، تم استلام ${input.length}`);
  }

  const normalized = input.map((raw) => {
    const drugId = stableId(raw);
    const name = text(raw.name, 180);
    if (!name) throw new HttpsError('invalid-argument', 'يوجد سجل دواء بدون اسم');
    return {
      drugId,
      name,
      genericName: text(raw.genericName, 180),
      activeIngredient: text(raw.activeIngredient, 180),
      strength: text(raw.strength, 100),
      dosageForm: text(raw.dosageForm, 100),
      category: text(raw.category, 100),
      subcategory: text(raw.subcategory, 100),
      manufacturer: text(raw.manufacturer, 180),
      requiresPrescription: Boolean(raw.requiresPrescription),
      imageAsset: text(raw.imageAsset || raw.image, 500),
      description: text(raw.description, 1000),
      legacyPrice: safePrice(raw.legacyPrice ?? raw.price),
      legacyRating: Number.isFinite(Number(raw.legacyRating ?? raw.rating)) ? Number(raw.legacyRating ?? raw.rating) : null,
      legacyInStock: raw.legacyInStock ?? raw.inStock ?? false,
    };
  });

  const seen = new Set();
  for (const drug of normalized) {
    if (seen.has(drug.drugId)) throw new HttpsError('invalid-argument', `معرف مكرر: ${drug.drugId}`);
    seen.add(drug.drugId);
  }

  const now = FieldValue.serverTimestamp();
  let catalogCount = 0;
  let offerCount = 0;

  // Firestore batch limit is 500 writes. Keep each batch below the limit and
  // use a fresh batch after every commit.
  for (const group of chunks(normalized, 200)) {
    const batch = db.batch();
    for (const drug of group) {
      const catalogRef = db.collection('drug_catalog').doc(drug.drugId);
      batch.set(catalogRef, {
        ...drug,
        isOfficial: true,
        isActive: true,
        verificationStatus: 'unverified_source',
        updatedAt: now,
      }, {merge: true});

      const productId = `platform_${drug.drugId}`;
      const productRef = db.collection('products').doc(productId);
      batch.set(productRef, {
        productId,
        sourceType: 'platform',
        sellerType: 'platform',
        sellerId: 'sehatak',
        drugId: drug.drugId,
        name: drug.name,
        genericName: drug.genericName,
        activeIngredient: drug.activeIngredient,
        strength: drug.strength,
        dosageForm: drug.dosageForm,
        category: drug.category,
        subcategory: drug.subcategory,
        manufacturer: drug.manufacturer,
        description: drug.description,
        imageAsset: drug.imageAsset,
        price: drug.legacyPrice,
        stock: drug.legacyInStock ? 1 : 0,
        requiresPrescription: drug.requiresPrescription,
        approvalStatus: 'approved',
        isPublished: true,
        isActive: Boolean(drug.legacyInStock),
        verificationStatus: 'unverified_source',
        rating: drug.legacyRating,
        createdAt: now,
        updatedAt: now,
      }, {merge: true});

      batch.set(db.collection('product_inventory').doc(productId), {
        productId,
        sourceType: 'platform',
        sellerType: 'platform',
        sellerId: 'sehatak',
        quantity: drug.legacyInStock ? 1 : 0,
        isAvailable: Boolean(drug.legacyInStock),
        updatedAt: now,
      }, {merge: true});

      catalogCount++;
      offerCount++;
    }
    await batch.commit();
  }

  return {ok: true, catalogCount, platformOfferCount: offerCount, verificationStatus: 'unverified_source'};
});
