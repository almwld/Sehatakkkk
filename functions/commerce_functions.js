const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const crypto = require('crypto');
function requireAuth(request) { if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً'); return request.auth.uid; }
function amount(value, allowZero = false) { const n = Number(value); if (!Number.isFinite(n) || n < 0 || n > 100000000 || (!allowZero && n <= 0)) throw new HttpsError('invalid-argument', 'مبلغ غير صالح'); return Math.round(n * 100) / 100; }
function text(value, field, max = 300) { const v = String(value ?? '').trim(); if (!v || v.length > max) throw new HttpsError('invalid-argument', `الحقل ${field} غير صالح`); return v; }
function digest(v) { return crypto.createHash('sha256').update(v).digest('hex').slice(0, 40); }
const DELIVERY_FEE = 500;
const subscriptionCatalog = Object.freeze({silver: {name: 'الباقة الفضية', monthly: 3000, annual: 30000}, bronze: {name: 'الباقة البرونزية', monthly: 3900, annual: 39000}, gold: {name: 'الباقة الذهبية', monthly: 4900, annual: 35000}, family: {name: 'باقة العائلة', monthly: 7500, annual: 75000}, crystal: {name: 'الباقة الكريستالية', monthly: 12000, annual: 120000}});
async function chargeWallet(tx, uid, total, title, description, serviceType, orderId, metadata, idempotencyKey) { const walletRef = db.collection('wallets').doc(uid); const txId = `pay_${uid}_${digest(idempotencyKey)}`; const txRef = db.collection('transactions').doc(txId); const walletSnap = await tx.get(walletRef); const existing = await tx.get(txRef); if (existing.exists) return {txId, reused: true}; if (!walletSnap.exists || walletSnap.data().isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة'); const wallet = walletSnap.data(); if (Number(wallet.balance || 0) < total) throw new HttpsError('failed-precondition', 'رصيد المحفظة غير كافٍ'); const now = FieldValue.serverTimestamp(); tx.update(walletRef, {balance: Number(wallet.balance || 0) - total, totalSpent: Number(wallet.totalSpent || 0) + total, updatedAt: now, lastTransactionAt: now}); tx.set(txRef, {userId: uid, amount: total, fee: 0, netAmount: total, type: 'payment', status: 'completed', title, description, orderId: orderId || null, serviceType, metadata: metadata || null, idempotencyKey, createdAt: now, completedAt: now}); return {txId, reused: false}; }
function writeInvoice(tx, {uid, transactionId, orderId, serviceType, subtotal, deliveryFee, total, items, title}) { const invoiceId = `INV-${Date.now()}-${digest(`${uid}|${transactionId}`).slice(0, 8).toUpperCase()}`; tx.set(db.collection('invoices').doc(invoiceId), {invoiceId, invoiceNumber: invoiceId, userId: uid, transactionId, orderId: orderId || null, serviceType, title, currency: 'YER', subtotal, deliveryFee, total, items, paymentStatus: 'paid', status: 'issued', issuedAt: FieldValue.serverTimestamp()}); return invoiceId; }
function validOrderId(value, field) {
  const result = String(value || '').trim();
  if (!result || result.length > 150 || !/^[A-Za-z0-9_-]+$/.test(result)) throw new HttpsError('invalid-argument', `معرّف غير صالح: ${field}`);
  return result;
}

const { canTransition: canPharmacyOrderTransition, isPharmacyOwner } = require('./pharmacy_order_workflow');

exports.checkoutCart = onCall(async (request) => {
  const uid = requireAuth(request);
  const rawItems = Array.isArray(request.data.items) ? request.data.items : [];
  if (!rawItems.length || rawItems.length > 50) throw new HttpsError('invalid-argument', 'السلة فارغة أو تحتوي عدداً غير مسموح من المنتجات');
  const idempotencyKey = text(request.data.idempotencyKey || `cart|${uid}|${Date.now()}`, 'idempotencyKey', 180);
  const deliveryRequired = request.data.deliveryRequired !== false;
  const deliveryAddress = deliveryRequired ? String(request.data.deliveryAddress || '').trim().slice(0, 1000) : '';
  const normalized = new Map();
  for (const item of rawItems) {
    const productId = validOrderId(item.productId, 'productId');
    const quantity = Number(item.quantity);
    if (!Number.isInteger(quantity) || quantity < 1 || quantity > 100) throw new HttpsError('invalid-argument', 'كمية المنتج غير صالحة');
    const old = normalized.get(productId);
    normalized.set(productId, {
      productId,
      quantity: quantity + (old?.quantity || 0),
      requestedPharmacyId: item.pharmacyId ? validOrderId(item.pharmacyId, 'pharmacyId') : null,
      prescriptionId: item.prescriptionId ? validOrderId(item.prescriptionId, 'prescriptionId') : null,
    });
  }
  if ([...normalized.values()].some(item => item.quantity > 100)) throw new HttpsError('invalid-argument', 'الكمية المطلوبة تتجاوز الحد المسموح');

  const keyDigest = digest(`${uid}|pharmacy_checkout|${idempotencyKey}`);
  const idempotencyRef = db.collection('checkout_idempotency').doc(keyDigest);
  const walletRef = db.collection('wallets').doc(uid);
  const userRef = db.collection('users').doc(uid);
  const productRefs = [...normalized.values()].map(item => db.collection('products').doc(item.productId));
  const inventoryRefs = [...normalized.values()].map(item => db.collection('product_inventory').doc(item.productId));

  return db.runTransaction(async (tx) => {
    const [idempotencySnap, walletSnap, userSnap, ...productAndInventorySnaps] = await Promise.all([
      tx.get(idempotencyRef),
      tx.get(walletRef),
      tx.get(userRef),
      ...productRefs.map(ref => tx.get(ref)),
      ...inventoryRefs.map(ref => tx.get(ref)),
    ]);
    if (idempotencySnap.exists) return idempotencySnap.data();

    if (!walletSnap.exists || walletSnap.data().isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة');
    const count = productRefs.length;
    const productSnaps = productAndInventorySnaps.slice(0, count);
    const inventorySnaps = productAndInventorySnaps.slice(count);
    const patient = userSnap.exists ? (userSnap.data() || {}) : {};
    const patientName = String(patient.name || patient.displayName || patient.fullName || '');
    const patientPhone = String(patient.phoneNumber || patient.phone || '');

    const prepared = [];
    const pharmacyIds = new Set();
    for (let index = 0; index < count; index += 1) {
      const item = [...normalized.values()][index];
      const productSnap = productSnaps[index];
      const inventorySnap = inventorySnaps[index];
      if (!productSnap.exists) throw new HttpsError('not-found', 'أحد المنتجات لم يعد متاحاً');
      const product = productSnap.data() || {};
      if (product.approvalStatus !== 'approved' || product.isPublished !== true || product.isActive !== true) throw new HttpsError('failed-precondition', 'أحد المنتجات غير منشور أو غير معتمد حالياً');
      const pharmacyId = String(product.pharmacyId || '');
      if (!pharmacyId || (item.requestedPharmacyId && item.requestedPharmacyId !== pharmacyId)) throw new HttpsError('failed-precondition', 'بيانات الصيدلية للمنتج غير متطابقة');
      pharmacyIds.add(pharmacyId);
      const rawPrice = Number(product.offerPrice ?? product.discountPrice ?? product.price);
      if (!Number.isFinite(rawPrice) || rawPrice <= 0) throw new HttpsError('failed-precondition', 'سعر أحد المنتجات غير صالح');
      const stockField = Object.prototype.hasOwnProperty.call(product, 'stock') ? 'stock' : 'quantity';
      const stock = Number(product[stockField]);
      const inventoryQty = inventorySnap.exists ? Number(inventorySnap.data().quantity ?? stock) : stock;
      if (!Number.isInteger(stock) || stock < item.quantity || !Number.isFinite(inventoryQty) || inventoryQty < item.quantity) throw new HttpsError('failed-precondition', 'المخزون غير كافٍ لأحد المنتجات');

      let prescriptionRef = null;
      const requiresPrescription = product.requiresPrescription === true || product.prescriptionRequired === true;
      if (requiresPrescription) {
        if (!item.prescriptionId) throw new HttpsError('failed-precondition', 'هذا المنتج يتطلب وصفة طبية معتمدة');
        prescriptionRef = db.collection('prescriptions').doc(item.prescriptionId);
        const prescriptionSnap = await tx.get(prescriptionRef);
        if (!prescriptionSnap.exists) throw new HttpsError('not-found', 'الوصفة الطبية غير موجودة');
        const prescription = prescriptionSnap.data() || {};
        if (String(prescription.userId || prescription.patientId || '') !== uid) throw new HttpsError('permission-denied', 'الوصفة لا تخص هذا الحساب');
        if (String(prescription.pharmacyId || '') !== pharmacyId || (prescription.productId && String(prescription.productId) !== item.productId)) throw new HttpsError('failed-precondition', 'الوصفة غير مرتبطة بهذا المنتج أو الصيدلية');
        if (prescription.status !== 'approved' || !String(prescription.fileRemotePath || prescription.imageUrl || prescription.documentUrl || '').trim()) throw new HttpsError('failed-precondition', 'الوصفة لم تعتمدها الصيدلية بعد');
      }
      const unitPrice = Math.round(rawPrice * 100) / 100;
      prepared.push({
        item, product, productRef: productRefs[index], inventoryRef: inventoryRefs[index],
        inventoryExists: inventorySnap.exists, pharmacyId, unitPrice,
        lineTotal: Math.round(unitPrice * item.quantity * 100) / 100,
        stockField, stock, inventoryQty, prescriptionRef,
      });
    }

    const pharmacyRefs = new Map([...pharmacyIds].map(id => [id, db.collection('pharmacies').doc(id)]));
    const pharmacySnaps = await Promise.all([...pharmacyRefs.values()].map(ref => tx.get(ref)));
    const pharmacies = new Map(pharmacySnaps.map(snap => [snap.id, snap]));
    for (const pharmacyId of pharmacyIds) {
      const snap = pharmacies.get(pharmacyId);
      if (!snap?.exists) throw new HttpsError('failed-precondition', 'الصيدلية المرتبطة بأحد المنتجات غير موجودة');
      const pharmacy = snap.data() || {};
      if (pharmacy.status !== 'approved' || pharmacy.isActive === false || pharmacy.acceptingOrders === false) throw new HttpsError('failed-precondition', 'إحدى الصيدليات لا تستقبل الطلبات حالياً');
      const authorizedSellers = [pharmacy.ownerId, pharmacy.userId, pharmacyId].map(value => String(value || '')).filter(Boolean);
      for (const row of prepared.filter(item => item.pharmacyId === pharmacyId)) {
        const sellerId = String(row.product.sellerId || '');
        if (sellerId && !authorizedSellers.includes(sellerId) && !(sellerId === 'sehatak' && row.product.sellerType === 'platform')) throw new HttpsError('permission-denied', 'أحد المنتجات غير معتمد من مالك الصيدلية');
      }
    }

    const subtotal = Math.round(prepared.reduce((sum, row) => sum + row.lineTotal, 0) * 100) / 100;
    const total = amount(subtotal);
    const wallet = walletSnap.data() || {};
    const balance = Number(wallet.balance || 0);
    if (!Number.isFinite(balance) || balance < total) throw new HttpsError('failed-precondition', 'رصيد المحفظة غير كافٍ');

    const invoiceId = 'INV-' + keyDigest.slice(0, 16).toUpperCase();
    const transactionId = 'pay_' + uid + '_' + keyDigest;
    const orderGroups = new Map();
    for (const row of prepared) {
      if (!orderGroups.has(row.pharmacyId)) orderGroups.set(row.pharmacyId, []);
      orderGroups.get(row.pharmacyId).push(row);
    }
    const orderIds = [];
    const now = FieldValue.serverTimestamp();
    tx.update(walletRef, {
      balance: Math.round((balance - total) * 100) / 100,
      totalSpent: Number(wallet.totalSpent || 0) + total,
      updatedAt: now,
      lastTransactionAt: now,
    });
    tx.create(db.collection('transactions').doc(transactionId), {
      userId: uid, amount: total, fee: 0, netAmount: total, type: 'payment',
      status: 'completed', title: 'شراء منتجات صيدلية', description: 'دفع طلب صيدلية عبر محفظة صحتك',
      orderId: null, invoiceId, serviceType: 'pharmacy', idempotencyKey,
      createdAt: now, completedAt: now,
    });

    for (const [pharmacyId, rows] of orderGroups) {
      const pharmacy = pharmacies.get(pharmacyId).data() || {};
      const ownerId = String(pharmacy.ownerId || pharmacy.userId || '');
      if (!ownerId) throw new HttpsError('failed-precondition', 'لا يوجد مالك موثق للصيدلية');
      const orderId = 'ord_' + digest(uid + '|' + keyDigest + '|' + pharmacyId).slice(0, 24);
      orderIds.push(orderId);
      const groupSubtotal = Math.round(rows.reduce((sum, row) => sum + row.lineTotal, 0) * 100) / 100;
      tx.create(db.collection('orders').doc(orderId), {
        id: orderId, orderId, type: 'pharmacy', userId: uid, patientName, patientPhone,
        phoneNumber: patientPhone, pharmacyId, providerId: ownerId,
        pharmacyName: String(pharmacy.name || pharmacy.pharmacyName || ''),
        items: rows.map(row => ({
          productId: row.item.productId, name: String(row.product.name || row.product.genericName || ''),
          genericName: row.product.genericName || null, category: row.product.category || null,
          quantity: row.item.quantity, unitPrice: row.unitPrice, price: row.unitPrice,
          total: row.lineTotal, requiresPrescription: row.product.requiresPrescription === true || row.product.prescriptionRequired === true,
          prescriptionId: row.item.prescriptionId || null,
        })),
        subtotal: groupSubtotal, discount: 0, deliveryFee: 0, deliveryFeePendingQuote: deliveryRequired,
        total: groupSubtotal, currency: 'YER', status: 'pending', paymentStatus: 'paid', paymentMethod: 'wallet',
        transactionId, invoiceId, deliveryRequired, deliveryAddress: deliveryAddress || null,
        delivery: {required: deliveryRequired, address: deliveryAddress || null, status: deliveryRequired ? 'pending' : 'not_required'},
        createdAt: now, updatedAt: now, statusHistory: [{status: 'pending', at: new Date().toISOString(), actorId: uid}],
      });
      tx.set(db.collection('notifications').doc(), {
        userId: ownerId, type: 'pharmacy_order_created', title: 'طلب صيدلية جديد',
        body: 'لديك طلب جديد يحتاج إلى التأكيد.', data: {orderId, pharmacyId, invoiceId},
        orderId, isRead: false, createdAt: now,
      });
      const linkedPrescriptionIds = new Set(rows.filter(row => row.prescriptionRef).map(row => row.item.prescriptionId));
      for (const prescriptionId of linkedPrescriptionIds) {
        tx.update(db.collection('prescriptions').doc(prescriptionId), {linkedOrderIds: FieldValue.arrayUnion(orderId), updatedAt: now});
      }
    }

    for (const row of prepared) {
      const nextStock = row.stock - row.item.quantity;
      tx.update(row.productRef, {[row.stockField]: nextStock, inStock: nextStock > 0, isActive: nextStock > 0, updatedAt: now});
      if (row.inventoryExists) tx.update(row.inventoryRef, {quantity: row.inventoryQty - row.item.quantity, isAvailable: row.inventoryQty - row.item.quantity > 0, updatedAt: now});
    }
    tx.set(db.collection('invoices').doc(invoiceId), {
      id: invoiceId, invoiceId, invoiceNumber: invoiceId, userId: uid, orderIds,
      amount: total, subtotal, deliveryFee: 0, deliveryFeePendingQuote: deliveryRequired,
      currency: 'YER', paymentMethod: 'wallet', paymentStatus: 'paid', transactionId,
      items: prepared.map(row => ({productId: row.item.productId, name: String(row.product.name || ''), quantity: row.item.quantity, unitPrice: row.unitPrice, total: row.lineTotal})),
      createdAt: now, status: 'issued',
    });
    const response = {success: true, orderId: orderIds[0], orderIds, invoiceId, total, deliveryFee: 0, currency: 'YER', status: 'paid'};
    tx.create(idempotencyRef, {...response, userId: uid, createdAt: now});
    return response;
  });
});
exports.activateSubscription = onCall(async (request) => { const uid = requireAuth(request); const planCode = text(request.data.planCode, 'planCode', 80); const billing = text(request.data.billing, 'billing', 20); if (!['monthly', 'annual'].includes(billing)) throw new HttpsError('invalid-argument', 'نوع الاشتراك غير صالح'); const plan = subscriptionCatalog[planCode]; if (!plan) throw new HttpsError('not-found', 'الباقة غير موجودة'); const price = billing === 'annual' ? plan.annual : plan.monthly; const idempotencyKey = text(request.data.idempotencyKey || `subscription|${uid}|${planCode}|${billing}|${Date.now()}`, 'idempotencyKey', 180); const subscriptionId = `sub_${uid}_${digest(idempotencyKey)}`; const subRef = db.collection('subscriptions').doc(subscriptionId); await db.runTransaction(async (tx) => { const existing = await tx.get(subRef); if (existing.exists) return; const active = await tx.get(db.collection('subscriptions').where('userId', '==', uid).where('status', '==', 'active').limit(1)); if (!active.empty) throw new HttpsError('already-exists', 'لديك اشتراك نشط بالفعل'); const payment = await chargeWallet(tx, uid, price, `اشتراك ${plan.name}`, `تفعيل ${plan.name} - ${billing === 'annual' ? 'سنوي' : 'شهري'}`, 'subscription', subscriptionId, {planCode, billing}, idempotencyKey); const now = FieldValue.serverTimestamp(); const start = new Date(); const end = new Date(start); if (billing === 'annual') end.setFullYear(end.getFullYear() + 1); else end.setMonth(end.getMonth() + 1); tx.set(subRef, {subscriptionId, userId: uid, planCode, planName: plan.name, billing, price, currency: 'YER', status: 'active', transactionId: payment.txId, startedAt: start, expiresAt: end, createdAt: now, updatedAt: now}); writeInvoice(tx, {uid, transactionId: payment.txId, orderId: subscriptionId, serviceType: 'subscription', subtotal: price, deliveryFee: 0, total: price, items: [{name: plan.name, quantity: 1, unitPrice: price, lineTotal: price}], title: `فاتورة اشتراك ${plan.name}`}); }); return {subscriptionId, status: 'active', price, currency: 'YER'}; });
exports.payLabBooking = onCall(async (request) => { const uid = requireAuth(request); const bookingId = text(request.data.bookingId, 'bookingId', 150); const ref = db.collection('lab_bookings').doc(bookingId); const idempotencyKey = text(request.data.idempotencyKey || `lab|${uid}|${bookingId}`, 'idempotencyKey', 180); await db.runTransaction(async (tx) => { const snap = await tx.get(ref); if (!snap.exists) throw new HttpsError('not-found', 'حجز المختبر غير موجود'); const booking = snap.data(); if (booking.patientId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذا الحجز'); if (booking.paymentStatus === 'paid') return; const total = amount(booking.total ?? booking.totalPrice ?? booking.price); const payment = await chargeWallet(tx, uid, total, `حجز فحص ${booking.labName || ''}`, 'دفع حجز المختبر', 'lab', bookingId, {labId: booking.labId, testIds: booking.testIds || []}, idempotencyKey); tx.update(ref, {paymentStatus: 'paid', paymentMethod: 'wallet', transactionId: payment.txId, status: 'confirmed', updatedAt: FieldValue.serverTimestamp()}); writeInvoice(tx, {uid, transactionId: payment.txId, orderId: bookingId, serviceType: 'lab', subtotal: total, deliveryFee: 0, total, items: booking.tests || [], title: 'فاتورة حجز فحص مختبر'}); }); return {bookingId, status: 'paid'}; });
exports.payAppointment = onCall(async (request) => { const uid = requireAuth(request); const appointmentId = text(request.data.appointmentId, 'appointmentId', 150); const ref = db.collection('appointments').doc(appointmentId); const idempotencyKey = text(request.data.idempotencyKey || `appointment|${uid}|${appointmentId}`, 'idempotencyKey', 180); await db.runTransaction(async (tx) => { const snap = await tx.get(ref); if (!snap.exists) throw new HttpsError('not-found', 'الموعد غير موجود'); const appointment = snap.data(); if (appointment.patientId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذا الموعد'); if (appointment.paymentStatus === 'paid') return; const doctorSnap = await tx.get(db.collection('doctors').doc(String(appointment.doctorId))); const fee = doctorSnap.exists ? Number(doctorSnap.data().consultationFee ?? doctorSnap.data().fee ?? 0) : 0; if (!Number.isFinite(fee) || fee <= 0) { tx.update(ref, {paymentStatus: 'not_required', updatedAt: FieldValue.serverTimestamp()}); return; } const payment = await chargeWallet(tx, uid, fee, `حجز مع ${appointment.doctorName || 'الطبيب'}`, 'دفع موعد طبي', 'appointment', appointmentId, {doctorId: appointment.doctorId, date: appointment.date, time: appointment.time}, idempotencyKey); tx.update(ref, {paymentStatus: 'paid', paymentMethod: 'wallet', transactionId: payment.txId, fee, updatedAt: FieldValue.serverTimestamp()}); writeInvoice(tx, {uid, transactionId: payment.txId, orderId: appointmentId, serviceType: 'appointment', subtotal: fee, deliveryFee: 0, total: fee, items: [{name: `حجز مع ${appointment.doctorName || 'الطبيب'}`, quantity: 1, unitPrice: fee, lineTotal: fee}], title: 'فاتورة حجز موعد طبي'}); }); return {appointmentId, status: 'paid'}; });