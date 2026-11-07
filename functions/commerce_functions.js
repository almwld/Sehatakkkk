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
exports.checkoutCart = onCall(async (request) => {
  const uid = requireAuth(request);
  const rawItems = Array.isArray(request.data.items) ? request.data.items : [];
  if (!rawItems.length) throw new HttpsError('invalid-argument', 'السلة فارغة');
  if (rawItems.length > 50) throw new HttpsError('invalid-argument', 'عدد عناصر السلة كبير جداً');

  const idempotencyKey = text(request.data.idempotencyKey || `cart|${uid}|${Date.now()}`, 'idempotencyKey', 180);
  const orderId = `ord_${uid}_${digest(idempotencyKey)}`;
  const orderRef = db.collection('orders').doc(orderId);
  const deliveryAddress = request.data.deliveryAddress ? String(request.data.deliveryAddress).trim().slice(0, 500) : '';
  const deliveryFee = deliveryAddress ? DELIVERY_FEE : 0;
  let response;

  await db.runTransaction(async (tx) => {
    const existingOrder = await tx.get(orderRef);
    if (existingOrder.exists) {
      const data = existingOrder.data();
      response = {orderId, status: data.status || 'paid', total: Number(data.total || 0), deliveryFee: Number(data.deliveryFee || 0), currency: data.currency || 'YER', reused: true};
      return;
    }

    // Normalize and combine duplicate product lines before reading inventory.
    const quantities = new Map();
    const metadataByProduct = new Map();
    for (const raw of rawItems) {
      const productId = text(raw.productId, 'productId', 200);
      const requestedQuantity = Number(raw.quantity || 1);
      if (!Number.isFinite(requestedQuantity) || requestedQuantity <= 0) throw new HttpsError('invalid-argument', 'كمية المنتج غير صالحة');
      const quantity = Math.max(1, Math.min(99, Math.floor(requestedQuantity)));
      const combined = (quantities.get(productId) || 0) + quantity;
      if (combined > 99) throw new HttpsError('invalid-argument', 'كمية المنتج تتجاوز الحد المسموح');
      quantities.set(productId, combined);
      if (!metadataByProduct.has(productId)) metadataByProduct.set(productId, raw);
    }

    const productIds = [...quantities.keys()];
    const productRefs = productIds.map((id) => db.collection('products').doc(id));
    const inventoryRefs = productIds.map((id) => db.collection('product_inventory').doc(id));
    const walletRef = db.collection('wallets').doc(uid);
    const transactionId = `pay_${uid}_${digest(idempotencyKey)}`;
    const transactionRef = db.collection('transactions').doc(transactionId);
    const invoiceId = `INV-${digest(`${uid}|${transactionId}`).slice(0, 16).toUpperCase()}`;
    const invoiceRef = db.collection('invoices').doc(invoiceId);

    // Firestore requires every transaction read to finish before the first write.
    const snapshots = await Promise.all([
      ...productRefs.map((ref) => tx.get(ref)),
      ...inventoryRefs.map((ref) => tx.get(ref)),
      tx.get(walletRef),
      tx.get(transactionRef),
    ]);
    const productSnapshots = snapshots.slice(0, productIds.length);
    const inventorySnapshots = snapshots.slice(productIds.length, productIds.length * 2);
    const walletSnap = snapshots[productIds.length * 2];
    const transactionSnap = snapshots[productIds.length * 2 + 1];
    if (!walletSnap.exists || walletSnap.data().isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة');
    if (transactionSnap.exists) throw new HttpsError('failed-precondition', 'توجد معاملة سابقة بهذا المفتاح دون طلب مكتمل؛ تواصل مع الدعم قبل إعادة المحاولة');

    const items = [];
    const stockUpdates = [];
    let subtotal = 0;
    for (let index = 0; index < productIds.length; index += 1) {
      const productId = productIds[index];
      const productSnap = productSnapshots[index];
      const inventorySnap = inventorySnapshots[index];
      if (!productSnap.exists) throw new HttpsError('not-found', 'المنتج غير موجود');
      const product = productSnap.data();
      if (product.approvalStatus !== 'approved' || product.isPublished !== true || product.isActive !== true) throw new HttpsError('failed-precondition', 'المنتج غير متاح حالياً');
      const quantity = quantities.get(productId);
      const stock = Number(product.stock || 0);
      const price = Number(product.price);
      if (!Number.isFinite(price) || price <= 0) throw new HttpsError('failed-precondition', 'سعر المنتج غير صالح');
      if (!Number.isFinite(stock) || stock < quantity) throw new HttpsError('failed-precondition', 'المخزون غير كافٍ');
      const inventoryQty = inventorySnap.exists ? Number(inventorySnap.data().quantity ?? stock) : stock;
      if (!Number.isFinite(inventoryQty) || inventoryQty < quantity) throw new HttpsError('failed-precondition', 'المخزون غير كافٍ');
      const raw = metadataByProduct.get(productId) || {};
      const lineTotal = Math.round(price * quantity * 100) / 100;
      subtotal += lineTotal;
      items.push({
        productId, name: String(product.name || product.genericName || productId),
        genericName: product.genericName || null, category: product.category || null,
        quantity, unitPrice: price, lineTotal,
        requiresPrescription: product.requiresPrescription === true,
        pharmacyId: product.pharmacyId || null,
        medicationId: raw.medicationId ? String(raw.medicationId) : null,
        prescriptionId: raw.prescriptionId ? String(raw.prescriptionId) : null,
        doctorId: raw.doctorId ? String(raw.doctorId) : null,
      });
      stockUpdates.push({productRef: productRefs[index], inventoryRef: inventoryRefs[index], inventoryExists: inventorySnap.exists, stock, inventoryQty, quantity});
    }

    const total = amount(subtotal + deliveryFee);
    const wallet = walletSnap.data();
    if (Number(wallet.balance || 0) < total) throw new HttpsError('failed-precondition', 'رصيد المحفظة غير كافٍ');
    const now = FieldValue.serverTimestamp();
    for (const update of stockUpdates) {
      const remaining = update.stock - update.quantity;
      tx.update(update.productRef, {stock: remaining, isActive: remaining > 0, updatedAt: now});
      if (update.inventoryExists) tx.update(update.inventoryRef, {quantity: update.inventoryQty - update.quantity, isAvailable: update.inventoryQty - update.quantity > 0, updatedAt: now});
    }
    tx.update(walletRef, {balance: Number(wallet.balance || 0) - total, totalSpent: Number(wallet.totalSpent || 0) + total, updatedAt: now, lastTransactionAt: now});
    tx.set(transactionRef, {userId: uid, amount: total, fee: 0, netAmount: total, type: 'payment', status: 'completed', title: 'شراء من الصيدلية', description: 'شراء منتجات الصيدلية مع التوصيل', orderId, serviceType: 'pharmacy', metadata: {deliveryAddress: deliveryAddress || null}, idempotencyKey, createdAt: now, completedAt: now});
    tx.set(orderRef, {orderId, userId: uid, type: 'pharmacy', catalogMode: 'firestore', items, subtotal, deliveryFee, total, currency: 'YER', status: 'paid', paymentStatus: 'paid', paymentMethod: 'wallet', transactionId, delivery: {required: deliveryFee > 0, address: deliveryAddress || null, status: deliveryFee > 0 ? 'pending' : 'not_required'}, createdAt: now, updatedAt: now});
    tx.set(invoiceRef, {invoiceId, invoiceNumber: invoiceId, userId: uid, transactionId, orderId, serviceType: 'pharmacy', title: 'فاتورة شراء من الصيدلية', currency: 'YER', subtotal, deliveryFee, total, items, paymentStatus: 'paid', status: 'issued', issuedAt: now});
    response = {orderId, status: 'paid', total, deliveryFee, currency: 'YER', reused: false};
  });
  return response;
});
exports.activateSubscription = onCall(async (request) => { const uid = requireAuth(request); const planCode = text(request.data.planCode, 'planCode', 80); const billing = text(request.data.billing, 'billing', 20); if (!['monthly', 'annual'].includes(billing)) throw new HttpsError('invalid-argument', 'نوع الاشتراك غير صالح'); const plan = subscriptionCatalog[planCode]; if (!plan) throw new HttpsError('not-found', 'الباقة غير موجودة'); const price = billing === 'annual' ? plan.annual : plan.monthly; const idempotencyKey = text(request.data.idempotencyKey || `subscription|${uid}|${planCode}|${billing}|${Date.now()}`, 'idempotencyKey', 180); const subscriptionId = `sub_${uid}_${digest(idempotencyKey)}`; const subRef = db.collection('subscriptions').doc(subscriptionId); await db.runTransaction(async (tx) => { const existing = await tx.get(subRef); if (existing.exists) return; const active = await tx.get(db.collection('subscriptions').where('userId', '==', uid).where('status', '==', 'active').limit(1)); if (!active.empty) throw new HttpsError('already-exists', 'لديك اشتراك نشط بالفعل'); const payment = await chargeWallet(tx, uid, price, `اشتراك ${plan.name}`, `تفعيل ${plan.name} - ${billing === 'annual' ? 'سنوي' : 'شهري'}`, 'subscription', subscriptionId, {planCode, billing}, idempotencyKey); const now = FieldValue.serverTimestamp(); const start = new Date(); const end = new Date(start); if (billing === 'annual') end.setFullYear(end.getFullYear() + 1); else end.setMonth(end.getMonth() + 1); tx.set(subRef, {subscriptionId, userId: uid, planCode, planName: plan.name, billing, price, currency: 'YER', status: 'active', transactionId: payment.txId, startedAt: start, expiresAt: end, createdAt: now, updatedAt: now}); writeInvoice(tx, {uid, transactionId: payment.txId, orderId: subscriptionId, serviceType: 'subscription', subtotal: price, deliveryFee: 0, total: price, items: [{name: plan.name, quantity: 1, unitPrice: price, lineTotal: price}], title: `فاتورة اشتراك ${plan.name}`}); }); return {subscriptionId, status: 'active', price, currency: 'YER'}; });
exports.payLabBooking = onCall(async (request) => { const uid = requireAuth(request); const bookingId = text(request.data.bookingId, 'bookingId', 150); const ref = db.collection('lab_bookings').doc(bookingId); const idempotencyKey = text(request.data.idempotencyKey || `lab|${uid}|${bookingId}`, 'idempotencyKey', 180); await db.runTransaction(async (tx) => { const snap = await tx.get(ref); if (!snap.exists) throw new HttpsError('not-found', 'حجز المختبر غير موجود'); const booking = snap.data(); if (booking.patientId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذا الحجز'); if (booking.paymentStatus === 'paid') return; const total = amount(booking.total ?? booking.totalPrice ?? booking.price); const payment = await chargeWallet(tx, uid, total, `حجز فحص ${booking.labName || ''}`, 'دفع حجز المختبر', 'lab', bookingId, {labId: booking.labId, testIds: booking.testIds || []}, idempotencyKey); tx.update(ref, {paymentStatus: 'paid', paymentMethod: 'wallet', transactionId: payment.txId, status: 'confirmed', updatedAt: FieldValue.serverTimestamp()}); writeInvoice(tx, {uid, transactionId: payment.txId, orderId: bookingId, serviceType: 'lab', subtotal: total, deliveryFee: 0, total, items: booking.tests || [], title: 'فاتورة حجز فحص مختبر'}); }); return {bookingId, status: 'paid'}; });
exports.payAppointment = onCall(async (request) => { const uid = requireAuth(request); const appointmentId = text(request.data.appointmentId, 'appointmentId', 150); const ref = db.collection('appointments').doc(appointmentId); const idempotencyKey = text(request.data.idempotencyKey || `appointment|${uid}|${appointmentId}`, 'idempotencyKey', 180); await db.runTransaction(async (tx) => { const snap = await tx.get(ref); if (!snap.exists) throw new HttpsError('not-found', 'الموعد غير موجود'); const appointment = snap.data(); if (appointment.patientId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذا الموعد'); if (appointment.paymentStatus === 'paid') return; const doctorSnap = await tx.get(db.collection('doctors').doc(String(appointment.doctorId))); const fee = doctorSnap.exists ? Number(doctorSnap.data().consultationFee ?? doctorSnap.data().fee ?? 0) : 0; if (!Number.isFinite(fee) || fee <= 0) { tx.update(ref, {paymentStatus: 'not_required', updatedAt: FieldValue.serverTimestamp()}); return; } const payment = await chargeWallet(tx, uid, fee, `حجز مع ${appointment.doctorName || 'الطبيب'}`, 'دفع موعد طبي', 'appointment', appointmentId, {doctorId: appointment.doctorId, date: appointment.date, time: appointment.time}, idempotencyKey); tx.update(ref, {paymentStatus: 'paid', paymentMethod: 'wallet', transactionId: payment.txId, fee, updatedAt: FieldValue.serverTimestamp()}); writeInvoice(tx, {uid, transactionId: payment.txId, orderId: appointmentId, serviceType: 'appointment', subtotal: fee, deliveryFee: 0, total: fee, items: [{name: `حجز مع ${appointment.doctorName || 'الطبيب'}`, quantity: 1, unitPrice: fee, lineTotal: fee}], title: 'فاتورة حجز موعد طبي'}); }); return {appointmentId, status: 'paid'}; });