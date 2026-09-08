const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

function auth(request) {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
  return request.auth.uid;
}

function clean(value, field, max = 200) {
  const v = String(value ?? '').trim();
  if (!v || v.length > max) throw new HttpsError('invalid-argument', `الحقل ${field} غير صالح`);
  return v;
}

function money(value, field = 'price') {
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0 || n > 100000000) throw new HttpsError('invalid-argument', `السعر ${field} غير صالح`);
  return Math.round(n * 100) / 100;
}

async function userData(uid) {
  const snap = await db.collection('users').doc(uid).get();
  return snap.exists ? snap.data() : {};
}

async function assertAdmin(uid) {
  const u = await userData(uid);
  if (!['admin', 'super_admin'].includes(String(u.role || '').toLowerCase())) {
    throw new HttpsError('permission-denied', 'هذه العملية للإدارة فقط');
  }
  return u;
}

async function assertPharmacyOwner(uid, pharmacyId) {
  const ref = db.collection('pharmacies').doc(pharmacyId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', 'الصيدلية غير موجودة');
  if (snap.data().ownerId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذه الصيدلية');
  if (snap.data().status !== 'approved') throw new HttpsError('failed-precondition', 'الصيدلية لم تعتمد بعد');
  return {ref, data: snap.data()};
}

// Database model:
// pharmacies/{pharmacyId}              -> pharmacy identity, ownerId, approval status
// pharmacy_products/{submissionId}     -> seller submissions and review lifecycle
// products/{productId}                 -> public marketplace offers after approval
// drug_catalog/{drugId}                -> official platform master drug catalog (300+)
// product_inventory/{productId}        -> stock/availability owned by platform or pharmacy

exports.createPharmacyProfile = onCall(async (request) => {
  const uid = auth(request);
  const name = clean(request.data.name, 'name', 160);
  const phone = clean(request.data.phone, 'phone', 40);
  const address = clean(request.data.address, 'address', 300);
  const licenseNumber = String(request.data.licenseNumber ?? '').trim().slice(0, 120);
  const user = await userData(uid);
  if (!['pharmacy', 'pharmacist', 'pharmacy_owner'].includes(String(user.role || '').toLowerCase())) {
    throw new HttpsError('permission-denied', 'حساب الصيدلية يجب أن يكون من نوع صيدلية');
  }
  const existing = await db.collection('pharmacies').where('ownerId', '==', uid).limit(1).get();
  if (!existing.empty) return {pharmacyId: existing.docs[0].id, status: existing.docs[0].data().status};
  const ref = db.collection('pharmacies').doc();
  await ref.set({pharmacyId: ref.id, ownerId: uid, name, phone, address, licenseNumber, status: 'pending', isActive: false, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp()});
  return {pharmacyId: ref.id, status: 'pending'};
});

exports.getMyPharmacy = onCall(async (request) => {
  const uid = auth(request);
  const snap = await db.collection('pharmacies').where('ownerId', '==', uid).limit(1).get();
  if (snap.empty) return {exists: false};
  return {exists: true, pharmacy: {id: snap.docs[0].id, ...snap.docs[0].data()}};
});

exports.submitPharmacyProduct = onCall(async (request) => {
  const uid = auth(request);
  const pharmacyId = clean(request.data.pharmacyId, 'pharmacyId', 128);
  await assertPharmacyOwner(uid, pharmacyId);
  const name = clean(request.data.name, 'name', 180);
  const genericName = String(request.data.genericName ?? '').trim().slice(0, 180);
  const category = clean(request.data.category, 'category', 100);
  const price = money(request.data.price);
  const stock = Math.max(0, Math.min(100000, Math.floor(Number(request.data.stock ?? 0))));
  const imageUrl = String(request.data.imageUrl ?? '').trim().slice(0, 1000);
  const drugId = String(request.data.drugId ?? '').trim().slice(0, 128);
  const requiresPrescription = Boolean(request.data.requiresPrescription);
  const ref = db.collection('pharmacy_products').doc();
  await ref.set({submissionId: ref.id, pharmacyId, ownerId: uid, drugId: drugId || null, name, genericName, category, price, stock, imageUrl: imageUrl || null, requiresPrescription, status: 'pending', reviewNote: null, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp()});
  return {submissionId: ref.id, status: 'pending'};
});

exports.getMyPharmacyProducts = onCall(async (request) => {
  const uid = auth(request);
  const pharmacyId = clean(request.data.pharmacyId, 'pharmacyId', 128);
  await assertPharmacyOwner(uid, pharmacyId);
  const snap = await db.collection('pharmacy_products').where('pharmacyId', '==', pharmacyId).orderBy('createdAt', 'desc').limit(100).get();
  return {products: snap.docs.map(d => ({id: d.id, ...d.data()}))};
});

exports.reviewPharmacyProduct = onCall(async (request) => {
  const uid = auth(request);
  await assertAdmin(uid);
  const submissionId = clean(request.data.submissionId, 'submissionId', 150);
  const decision = clean(request.data.decision, 'decision', 20);
  if (!['approve', 'reject'].includes(decision)) throw new HttpsError('invalid-argument', 'قرار غير صالح');
  const note = String(request.data.note ?? '').trim().slice(0, 500);
  const submissionRef = db.collection('pharmacy_products').doc(submissionId);
  await db.runTransaction(async tx => {
    const snap = await tx.get(submissionRef);
    if (!snap.exists) throw new HttpsError('not-found', 'المنتج غير موجود');
    const p = snap.data();
    if (p.status === 'approved' && decision === 'approve') return;
    const now = FieldValue.serverTimestamp();
    if (decision === 'reject') {
      tx.update(submissionRef, {status: 'rejected', reviewNote: note || 'لم يتم اعتماد المنتج', reviewedBy: uid, reviewedAt: now, updatedAt: now});
      return;
    }
    const productId = `pharmacy_${p.pharmacyId}_${submissionId}`;
    tx.set(db.collection('products').doc(productId), {productId, sourceType: 'pharmacy', pharmacyId: p.pharmacyId, ownerId: p.ownerId, drugId: p.drugId || null, name: p.name, genericName: p.genericName || null, category: p.category, price: p.price, stock: p.stock, imageUrl: p.imageUrl || null, requiresPrescription: Boolean(p.requiresPrescription), approvalStatus: 'approved', isPublished: true, isActive: p.stock > 0, createdAt: p.createdAt || now, updatedAt: now});
    tx.set(db.collection('product_inventory').doc(productId), {productId, sourceType: 'pharmacy', pharmacyId: p.pharmacyId, ownerId: p.ownerId, quantity: p.stock, isAvailable: p.stock > 0, updatedAt: now});
    tx.update(submissionRef, {status: 'approved', reviewNote: note || null, reviewedBy: uid, reviewedAt: now, productId, updatedAt: now});
  });
  return {submissionId, status: decision === 'approve' ? 'approved' : 'rejected'};
});

exports.updatePharmacyProductStock = onCall(async (request) => {
  const uid = auth(request);
  const pharmacyId = clean(request.data.pharmacyId, 'pharmacyId', 128);
  await assertPharmacyOwner(uid, pharmacyId);
  const productId = clean(request.data.productId, 'productId', 200);
  const quantity = Math.max(0, Math.min(100000, Math.floor(Number(request.data.quantity))));
  const productRef = db.collection('products').doc(productId);
  const inventoryRef = db.collection('product_inventory').doc(productId);
  await db.runTransaction(async tx => {
    const snap = await tx.get(productRef);
    if (!snap.exists || snap.data().pharmacyId !== pharmacyId || snap.data().approvalStatus !== 'approved') throw new HttpsError('not-found', 'المنتج غير موجود أو غير معتمد');
    const now = FieldValue.serverTimestamp();
    tx.update(productRef, {stock: quantity, isActive: quantity > 0, updatedAt: now});
    tx.set(inventoryRef, {productId, sourceType: 'pharmacy', pharmacyId, ownerId: uid, quantity, isAvailable: quantity > 0, updatedAt: now}, {merge: true});
  });
  return {productId, quantity};
});

exports.importOfficialDrugCatalog = onCall(async (request) => {
  const uid = auth(request);
  await assertAdmin(uid);
  const drugs = Array.isArray(request.data.drugs) ? request.data.drugs : [];
  if (!drugs.length || drugs.length > 1000) throw new HttpsError('invalid-argument', 'قائمة الأدوية غير صالحة');
  const batch = db.batch();
  let count = 0;
  for (const raw of drugs) {
    const id = clean(raw.id || raw.code || raw.name, 'id', 160).toLowerCase().replace(/[^a-z0-9_-]+/g, '_');
    const name = clean(raw.name, 'name', 180);
    const ref = db.collection('drug_catalog').doc(id);
    batch.set(ref, {drugId: id, name, genericName: String(raw.genericName ?? '').trim().slice(0, 180) || null, activeIngredient: String(raw.activeIngredient ?? '').trim().slice(0, 180) || null, strength: String(raw.strength ?? '').trim().slice(0, 100) || null, dosageForm: String(raw.dosageForm ?? '').trim().slice(0, 100) || null, category: String(raw.category ?? '').trim().slice(0, 100) || null, manufacturer: String(raw.manufacturer ?? '').trim().slice(0, 180) || null, requiresPrescription: Boolean(raw.requiresPrescription), isOfficial: true, isActive: raw.isActive !== false, updatedAt: FieldValue.serverTimestamp()}, {merge: true});
    count++;
    if (count % 450 === 0) { await batch.commit(); }
  }
  await batch.commit();
  return {imported: count, collection: 'drug_catalog'};
});

exports.getMarketplaceProducts = onCall(async (request) => {
  auth(request);
  const limit = Math.max(1, Math.min(100, Number(request.data.limit || 50)));
  const snap = await db.collection('products').where('approvalStatus', '==', 'approved').where('isPublished', '==', true).where('isActive', '==', true).limit(limit).get();
  return {products: snap.docs.map(d => ({id: d.id, ...d.data()}))};
});
