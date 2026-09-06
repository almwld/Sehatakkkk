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

  await db.runTransaction(async (tx) => {
    const [walletSnap, existingSnap] = await Promise.all([tx.get(walletRef), tx.get(txRef)]);
    if (existingSnap.exists) return;
    if (!walletSnap.exists) throw new HttpsError('failed-precondition', 'المحفظة غير مفعلة لهذا الحساب');
    const wallet = walletSnap.data();
    const balance = Number(wallet.balance || 0);
    if (wallet.isActive === false) throw new HttpsError('failed-precondition', 'المحفظة غير نشطة');
    if (balance < amount) throw new HttpsError('failed-precondition', 'رصيد المحفظة غير كافٍ');
    const now = FieldValue.serverTimestamp();
    tx.update(walletRef, {balance: balance - amount, totalSpent: Number(wallet.totalSpent || 0) + amount, updatedAt: now, lastTransactionAt: now});
    tx.set(txRef, {userId: uid, amount, fee: 0, netAmount: amount, type: 'payment', status: 'completed', title, description, orderId, serviceId, serviceType, metadata: request.data.metadata || null, idempotencyKey, createdAt: now, completedAt: now});
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
