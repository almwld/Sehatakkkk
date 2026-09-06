const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {setGlobalOptions} = require('firebase-functions/v2/options');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();
setGlobalOptions({region: 'us-central1', maxInstances: 10});
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
  return request.auth.uid;
}
function amountOf(value) {
  const amount = Number(value);
  if (!Number.isFinite(amount) || amount <= 0 || amount > 100000000) throw new HttpsError('invalid-argument', 'المبلغ غير صالح');
  return Math.round(amount * 100) / 100;
}
function text(value, field, max = 500) {
  const result = String(value || '').trim();
  if (!result || result.length > max) throw new HttpsError('invalid-argument', `الحقل ${field} غير صالح`);
  return result;
}
function digest(value) { return crypto.createHash('sha256').update(value).digest('hex').slice(0, 40); }
async function isAdmin(uid) {
  const snap = await db.collection('users').doc(uid).get();
  return snap.exists && snap.data().role === 'admin';
}

exports.createWallet = onCall(async (request) => {
  const uid = requireAuth(request);
  const ref = db.collection('wallets').doc(uid);
  const snap = await ref.get();
  if (!snap.exists) {
    await ref.set({userId: uid, balance: 0, pendingBalance: 0, totalDeposited: 0, totalWithdrawn: 0, totalSpent: 0, currency: 'YER', isActive: true, createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp()});
  }
  return {userId: uid, created: !snap.exists};
});

exports.submitDoctorVerification = onCall(async (request) => {
  const uid = requireAuth(request);
  const doctorRef = db.collection('doctors').doc(uid);
  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const [doctorSnap, userSnap] = await Promise.all([tx.get(doctorRef), tx.get(userRef)]);
    if (!doctorSnap.exists || !userSnap.exists) throw new HttpsError('not-found', 'ملف الطبيب غير موجود');
    const user = userSnap.data();
    const doctor = doctorSnap.data();
    if (user.role !== 'doctor' || doctor.userId !== uid) throw new HttpsError('permission-denied', 'حساب الطبيب غير صالح');
    if (doctor.isVerified === true) throw new HttpsError('failed-precondition', 'الطبيب موثق بالفعل');
    tx.update(doctorRef, {verificationStatus: 'pending', isVerified: false, updatedAt: FieldValue.serverTimestamp()});
    tx.update(userRef, {verificationStatus: 'pending', isVerified: false, updatedAt: FieldValue.serverTimestamp()});
  });
  return {status: 'pending'};
});

exports.reviewDoctorVerification = onCall(async (request) => {
  const adminUid = requireAuth(request);
  if (!(await isAdmin(adminUid))) throw new HttpsError('permission-denied', 'صلاحية المدير مطلوبة');
  const doctorId = text(request.data.doctorId, 'doctorId', 128);
  const decision = text(request.data.decision, 'decision', 20);
  if (!['approve', 'reject'].includes(decision)) throw new HttpsError('invalid-argument', 'قرار غير صالح');
  const doctorRef = db.collection('doctors').doc(doctorId);
  const userRef = db.collection('users').doc(doctorId);
  await db.runTransaction(async (tx) => {
    const [doctorSnap, userSnap] = await Promise.all([tx.get(doctorRef), tx.get(userRef)]);
    if (!doctorSnap.exists || !userSnap.exists) throw new HttpsError('not-found', 'ملف الطبيب أو المستخدم غير موجود');
    const doctor = doctorSnap.data();
    const user = userSnap.data();
    if (user.role !== 'doctor' || doctor.userId !== doctorId) throw new HttpsError('failed-precondition', 'ارتباط الطبيب بالمستخدم غير صالح');
    const approved = decision === 'approve';
    const now = FieldValue.serverTimestamp();
    tx.update(doctorRef, {isVerified: approved, verificationStatus: approved ? 'approved' : 'rejected', isAvailable: approved ? Boolean(doctor.isAvailable) : false, isOnline: false, verifiedAt: approved ? now : null, verifiedBy: adminUid, updatedAt: now});
    tx.update(userRef, {isVerified: approved, verificationStatus: approved ? 'approved' : 'rejected', updatedAt: now});
  });
  return {doctorId, status: decision === 'approve' ? 'approved' : 'rejected'};
});

exports.createAppointment = onCall(async (request) => {
  const uid = requireAuth(request);
  const doctorId = text(request.data.doctorId, 'doctorId', 128);
  const doctorRef = db.collection('doctors').doc(doctorId);
  const userRef = db.collection('users').doc(uid);
  const appointmentRef = db.collection('appointments').doc();
  const dateValue = request.data.date;
  const time = text(request.data.time, 'time', 20);
  const type = request.data.type ? String(request.data.type) : 'in_person';
  if (!['in_person', 'video', 'phone'].includes(type)) throw new HttpsError('invalid-argument', 'نوع الموعد غير صالح');
  let date;
  if (dateValue && typeof dateValue === 'string') date = new Date(dateValue);
  else if (dateValue && typeof dateValue._seconds === 'number') date = new Date(dateValue._seconds * 1000);
  else throw new HttpsError('invalid-argument', 'تاريخ الموعد غير صالح');
  if (Number.isNaN(date.getTime()) || date.getTime() < Date.now() - 60000) throw new HttpsError('invalid-argument', 'تاريخ الموعد يجب أن يكون مستقبلياً');

  await db.runTransaction(async (tx) => {
    const [doctorSnap, userSnap, existingSnap] = await Promise.all([
      tx.get(doctorRef),
      tx.get(userRef),
      tx.get(db.collection('appointments').where('doctorId', '==', doctorId).where('date', '==', admin.firestore.Timestamp.fromDate(date)).where('time', '==', time).where('status', 'in', ['pending', 'confirmed']).limit(1)),
    ]);
    if (!userSnap.exists) throw new HttpsError('failed-precondition', 'حساب المريض غير موجود');
    if (!doctorSnap.exists) throw new HttpsError('not-found', 'الطبيب غير موجود');
    const doctor = doctorSnap.data();
    if (doctor.userId !== doctorId || doctor.isVerified !== true) throw new HttpsError('failed-precondition', 'الطبيب غير موثق أو ارتباط الحساب غير صالح');
    if (existingSnap.docs.length) throw new HttpsError('already-exists', 'هذا الموعد محجوز مسبقاً');
    const now = FieldValue.serverTimestamp();
    tx.create(appointmentRef, {patientId: uid, patientName: userSnap.data().name || userSnap.data().displayName || 'مريض', doctorId, doctorName: doctor.name || '', doctorSpecialty: doctor.specialty || '', date: admin.firestore.Timestamp.fromDate(date), time, type, status: 'pending', notes: String(request.data.notes || '').trim().slice(0, 1000), clinicAddress: doctor.clinicAddress || null, clinicPhone: doctor.clinicPhone || null, createdAt: now, updatedAt: now, confirmedAt: null, cancelledAt: null, reminderSent: false});
  });
  return {appointmentId: appointmentRef.id, status: 'pending'};
});

exports.createPayment = onCall(async (request) => {
  const uid = requireAuth(request);
  const amount = amountOf(request.data.amount);
  const title = text(request.data.title, 'title');
  const description = text(request.data.description, 'description');
  const orderId = request.data.orderId ? String(request.data.orderId) : null;
  const serviceId = request.data.serviceId ? String(request.data.serviceId) : null;
  const serviceType = request.data.serviceType ? String(request.data.serviceType) : null;
  const idempotencyKey = request.data.idempotencyKey ? String(request.data.idempotencyKey) : digest(`${uid}|${orderId || ''}|${amount}|${serviceId || ''}|${Date.now()}`);
  const txId = `pay_${uid}_${digest(idempotencyKey)}`;
  const txRef = db.collection('transactions').doc(txId);
  const walletRef = db.collection('wallets').doc(uid);
  const orderRef = orderId ? db.collection('orders').doc(orderId) : null;
  await db.runTransaction(async (tx) => {
    const [walletSnap, existingSnap, orderSnap] = await Promise.all([tx.get(walletRef), tx.get(txRef), orderRef ? tx.get(orderRef) : Promise.resolve(null)]);
    if (existingSnap.exists) return;
    if (!walletSnap.exists) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة لهذا الحساب');
    const wallet = walletSnap.data();
    const balance = Number(wallet.balance || 0);
    if (wallet.isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير نشطة');
    if (balance < amount) throw new HttpsError('failed-precondition', 'رصيد المحفظة غير كافٍ');
    if (orderRef) {
      if (!orderSnap || !orderSnap.exists) throw new HttpsError('not-found', 'الطلب غير موجود');
      const order = orderSnap.data();
      if (order.userId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذا الطلب');
      if (Math.abs(Number(order.total || 0) - amount) > 0.01) throw new HttpsError('failed-precondition', 'مبلغ الدفع لا يطابق إجمالي الطلب');
      if (order.transactionId) throw new HttpsError('already-exists', 'تم ربط الطلب بمعاملة دفع مسبقاً');
    }
    const now = FieldValue.serverTimestamp();
    tx.update(walletRef, {balance: balance - amount, totalSpent: Number(wallet.totalSpent || 0) + amount, updatedAt: now, lastTransactionAt: now});
    tx.set(txRef, {userId: uid, amount, fee: 0, netAmount: amount, type: 'payment', status: 'completed', title, description, orderId, serviceId, serviceType, metadata: request.data.metadata || null, idempotencyKey, createdAt: now, completedAt: now});
    if (orderRef) tx.update(orderRef, {paymentMethod: serviceType || 'wallet', transactionId: txId, updatedAt: new Date().toISOString()});
  });
  return {transactionId: txId, status: 'completed'};
});

exports.submitTopUp = onCall(async (request) => {
  const uid = requireAuth(request);
  const amount = amountOf(request.data.amount);
  const walletName = text(request.data.walletName, 'walletName', 100);
  const referenceNumber = text(request.data.referenceNumber, 'referenceNumber', 120);
  const key = digest(`${uid}|deposit|${walletName}|${referenceNumber}`);
  const txId = `dep_${uid}_${key}`;
  const txRef = db.collection('transactions').doc(txId);
  const walletRef = db.collection('wallets').doc(uid);
  await db.runTransaction(async (tx) => {
    const [existing, wallet] = await Promise.all([tx.get(txRef), tx.get(walletRef)]);
    if (existing.exists) return;
    if (!wallet.exists || wallet.data().isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة');
    tx.set(txRef, {userId: uid, amount, fee: 0, netAmount: amount, type: 'deposit', status: 'pending', title: `طلب تغذية حساب عبر ${walletName}`, description: `رقم الإشعار: ${referenceNumber}`, referenceNumber, walletName, idempotencyKey: key, metadata: request.data.metadata || null, createdAt: FieldValue.serverTimestamp(), completedAt: null});
  });
  return {transactionId: txId, status: 'pending'};
});

exports.requestRefund = onCall(async (request) => {
  const uid = requireAuth(request);
  const originalId = text(request.data.transactionId, 'transactionId', 150);
  const reason = text(request.data.reason, 'reason', 500);
  const originalRef = db.collection('transactions').doc(originalId);
  const refundId = `ref_${uid}_${digest(originalId)}`;
  const refundRef = db.collection('transactions').doc(refundId);
  await db.runTransaction(async (tx) => {
    const [original, existing] = await Promise.all([tx.get(originalRef), tx.get(refundRef)]);
    if (existing.exists) return;
    if (!original.exists) throw new HttpsError('not-found', 'المعاملة غير موجودة');
    const data = original.data();
    if (data.userId !== uid) throw new HttpsError('permission-denied', 'لا تملك هذه المعاملة');
    if (data.type !== 'payment' || data.status !== 'completed') throw new HttpsError('failed-precondition', 'لا يمكن استرداد هذه المعاملة');
    tx.set(refundRef, {userId: uid, amount: Number(data.amount), fee: 0, netAmount: Number(data.amount), type: 'refund', status: 'pending', title: `طلب استرداد: ${data.title || 'عملية دفع'}`, description: `سبب الاسترداد: ${reason}`, orderId: data.orderId || null, serviceId: data.serviceId || null, serviceType: data.serviceType || null, metadata: {originalTransactionId: originalId, reason}, createdAt: FieldValue.serverTimestamp(), completedAt: null});
  });
  return {transactionId: refundId, status: 'pending'};
});

exports.requestWithdrawal = onCall(async (request) => {
  const uid = requireAuth(request);
  const amount = amountOf(request.data.amount);
  const walletName = text(request.data.walletName, 'walletName', 100);
  const destination = text(request.data.destination, 'destination', 150);
  const key = digest(`${uid}|withdrawal|${walletName}|${destination}|${amount}`);
  const txId = `wd_${uid}_${key}`;
  const txRef = db.collection('transactions').doc(txId);
  const walletRef = db.collection('wallets').doc(uid);
  await db.runTransaction(async (tx) => {
    const [wallet, existing] = await Promise.all([tx.get(walletRef), tx.get(txRef)]);
    if (existing.exists) return;
    if (!wallet.exists || wallet.data().isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة');
    const data = wallet.data();
    if (Number(data.balance || 0) < amount) throw new HttpsError('failed-precondition', 'الرصيد غير كافٍ');
    tx.update(walletRef, {balance: Number(data.balance || 0) - amount, pendingBalance: Number(data.pendingBalance || 0) + amount, updatedAt: FieldValue.serverTimestamp()});
    tx.set(txRef, {userId: uid, amount, fee: 0, netAmount: amount, type: 'withdrawal', status: 'pending', title: `طلب سحب عبر ${walletName}`, description: `وجهة السحب: ${destination}`, walletName, referenceNumber: destination, idempotencyKey: key, createdAt: FieldValue.serverTimestamp(), completedAt: null});
  });
  return {transactionId: txId, status: 'pending'};
});

exports.reviewTransaction = onCall(async (request) => {
  const uid = requireAuth(request);
  if (!(await isAdmin(uid))) throw new HttpsError('permission-denied', 'صلاحية المدير مطلوبة');
  const transactionId = text(request.data.transactionId, 'transactionId', 150);
  const decision = text(request.data.decision, 'decision', 20);
  if (!['approve', 'reject'].includes(decision)) throw new HttpsError('invalid-argument', 'قرار غير صالح');
  const txRef = db.collection('transactions').doc(transactionId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(txRef);
    if (!snap.exists) throw new HttpsError('not-found', 'المعاملة غير موجودة');
    const data = snap.data();
    if (data.status !== 'pending') throw new HttpsError('failed-precondition', 'المعاملة تمت معالجتها مسبقاً');
    const amount = Number(data.amount || 0);
    if (!Number.isFinite(amount) || amount <= 0) throw new HttpsError('failed-precondition', 'مبلغ المعاملة غير صالح');
    const walletRef = db.collection('wallets').doc(data.userId);
    const walletSnap = await tx.get(walletRef);
    if (!walletSnap.exists) throw new HttpsError('failed-precondition', 'محفظة المستخدم غير موجودة');
    const wallet = walletSnap.data();
    const now = FieldValue.serverTimestamp();
    if (decision === 'reject') {
      if (data.type === 'withdrawal') tx.update(walletRef, {balance: Number(wallet.balance || 0) + amount, pendingBalance: Math.max(0, Number(wallet.pendingBalance || 0) - amount), updatedAt: now});
      tx.update(txRef, {status: 'failed', completedAt: now, updatedAt: now, reviewedBy: uid});
      return;
    }
    if (data.type === 'deposit') tx.update(walletRef, {balance: Number(wallet.balance || 0) + amount, totalDeposited: Number(wallet.totalDeposited || 0) + amount, updatedAt: now, lastTransactionAt: now});
    else if (data.type === 'refund') tx.update(walletRef, {balance: Number(wallet.balance || 0) + amount, totalSpent: Math.max(0, Number(wallet.totalSpent || 0) - amount), updatedAt: now, lastTransactionAt: now});
    else if (data.type === 'withdrawal') tx.update(walletRef, {pendingBalance: Math.max(0, Number(wallet.pendingBalance || 0) - amount), totalWithdrawn: Number(wallet.totalWithdrawn || 0) + amount, updatedAt: now, lastTransactionAt: now});
    else throw new HttpsError('failed-precondition', 'نوع المعاملة لا يدعم المراجعة');
    tx.update(txRef, {status: 'completed', completedAt: now, reviewedBy: uid, updatedAt: now});
  });
  return {transactionId, status: 'completed'};
});
