const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

function requireAuth(request) {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
  return request.auth.uid;
}
function text(value, field, max = 200) {
  const v = String(value ?? '').trim();
  if (!v || v.length > max) throw new HttpsError('invalid-argument', `الحقل ${field} غير صالح`);
  return v;
}
async function isAdmin(uid) {
  const snap = await db.collection('users').doc(uid).get();
  return snap.exists && snap.data().role === 'admin';
}

exports.submitLabVerification = onCall(async (request) => {
  const uid = requireAuth(request);
  const labRef = db.collection('labs').doc(uid);
  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const [labSnap, userSnap] = await Promise.all([tx.get(labRef), tx.get(userRef)]);
    if (!labSnap.exists || !userSnap.exists) throw new HttpsError('not-found', 'ملف المختبر أو المستخدم غير موجود');
    const user = userSnap.data();
    const lab = labSnap.data();
    if (user.role !== 'lab' || lab.userId !== uid) throw new HttpsError('permission-denied', 'حساب المختبر غير صالح');
    if (lab.isVerified === true) throw new HttpsError('failed-precondition', 'المختبر موثق بالفعل');
    const now = FieldValue.serverTimestamp();
    tx.update(labRef, {isVerified: false, verificationStatus: 'pending', updatedAt: now});
    tx.update(userRef, {verificationStatus: 'pending', isVerified: false, updatedAt: now});
  });
  return {status: 'pending'};
});

exports.reviewLabVerification = onCall(async (request) => {
  const adminUid = requireAuth(request);
  if (!(await isAdmin(adminUid))) throw new HttpsError('permission-denied', 'صلاحية المدير مطلوبة');
  const labId = text(request.data.labId, 'labId', 128);
  const decision = text(request.data.decision, 'decision', 20);
  if (!['approve', 'reject'].includes(decision)) throw new HttpsError('invalid-argument', 'قرار غير صالح');
  const labRef = db.collection('labs').doc(labId);
  await db.runTransaction(async (tx) => {
    const labSnap = await tx.get(labRef);
    if (!labSnap.exists) throw new HttpsError('not-found', 'المختبر غير موجود');
    const lab = labSnap.data();
    const uid = String(lab.userId || '');
    const userRef = uid ? db.collection('users').doc(uid) : null;
    const userSnap = userRef ? await tx.get(userRef) : null;
    if (!uid || !userSnap?.exists || userSnap.data().role !== 'lab') throw new HttpsError('failed-precondition', 'ارتباط المختبر بحساب المستخدم غير صالح');
    const approved = decision === 'approve';
    const now = FieldValue.serverTimestamp();
    tx.update(labRef, {isVerified: approved, verificationStatus: approved ? 'approved' : 'rejected', verifiedAt: approved ? now : null, verifiedBy: adminUid, updatedAt: now});
    tx.update(userRef, {isVerified: approved, verificationStatus: approved ? 'approved' : 'rejected', updatedAt: now});
  });
  return {labId, status: decision === 'approve' ? 'approved' : 'rejected'};
});

exports.createLabBooking = onCall(async (request) => {
  const uid = requireAuth(request);
  const labId = text(request.data.labId, 'labId', 128);
  const testId = request.data.testId ? text(request.data.testId, 'testId', 128) : null;
  const date = text(request.data.date, 'date', 30);
  const time = text(request.data.time, 'time', 20);
  const notes = String(request.data.notes || '').trim().slice(0, 1000);
  const labRef = db.collection('labs').doc(labId);
  const patientRef = db.collection('users').doc(uid);
  const bookingRef = db.collection('lab_bookings').doc();
  await db.runTransaction(async (tx) => {
    const [labSnap, patientSnap] = await Promise.all([tx.get(labRef), tx.get(patientRef)]);
    if (!labSnap.exists) throw new HttpsError('not-found', 'المختبر غير موجود');
    if (!patientSnap.exists) throw new HttpsError('failed-precondition', 'حساب المريض غير موجود');
    const lab = labSnap.data();
    if (lab.isVerified !== true) throw new HttpsError('failed-precondition', 'لا يمكن الحجز في مختبر غير موثق');
    const tests = Array.isArray(lab.tests) ? lab.tests : [];
    let selected = null;
    if (testId) selected = tests.find((t) => t && typeof t === 'object' && String(t.id || '') === testId);
    if (testId && !selected) throw new HttpsError('not-found', 'الفحص غير متوفر في هذا المختبر');
    const total = selected ? Number(selected.price || 0) : Number(lab.bookingFee || 0);
    if (!Number.isFinite(total) || total < 0) throw new HttpsError('failed-precondition', 'سعر الفحص غير صالح');
    const duplicate = await tx.get(db.collection('lab_bookings').where('labId', '==', labId).where('date', '==', date).where('time', '==', time).where('status', 'in', ['pending', 'confirmed']).limit(1));
    if (!duplicate.empty) throw new HttpsError('already-exists', 'هذا الموعد محجوز مسبقاً');
    const now = FieldValue.serverTimestamp();
    tx.create(bookingRef, {patientId: uid, patientName: patientSnap.data().name || patientSnap.data().displayName || 'مريض', labId, labName: lab.name || '', testId: testId || null, testName: selected?.name || null, total, date, time, notes, status: 'pending', createdAt: now, updatedAt: now, cancelledAt: null, paymentStatus: 'unpaid'});
  });
  return {bookingId: bookingRef.id, status: 'pending'};
});
