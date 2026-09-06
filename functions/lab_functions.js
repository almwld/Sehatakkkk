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
    if (!uid) throw new HttpsError('failed-precondition', 'المختبر غير مرتبط بحساب');
    const userRef = db.collection('users').doc(uid);
    const userSnap = await tx.get(userRef);
    if (!userSnap.exists || userSnap.data().role !== 'lab') throw new HttpsError('failed-precondition', 'حساب المختبر غير صالح');
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
  const date = text(request.data.date, 'date', 30);
  const time = text(request.data.time, 'time', 20);
  const notes = String(request.data.notes || '').trim().slice(0, 1000);
  const rawIds = Array.isArray(request.data.testIds) ? request.data.testIds : (request.data.testId ? [request.data.testId] : []);
  const testIds = [...new Set(rawIds.map((v) => String(v).trim()).filter(Boolean))];
  if (!testIds.length) throw new HttpsError('invalid-argument', 'اختر فحصًا واحدًا على الأقل');
  if (testIds.length > 20) throw new HttpsError('invalid-argument', 'عدد الفحوصات كبير جدًا');
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
    const selected = testIds.map((id) => tests.find((t) => t && typeof t === 'object' && String(t.id || '') === id)).filter(Boolean);
    if (selected.length !== testIds.length) throw new HttpsError('not-found', 'أحد الفحوصات غير متوفر في هذا المختبر');
    const total = selected.reduce((sum, t) => sum + Number(t.price || 0), 0);
    if (!Number.isFinite(total) || total < 0) throw new HttpsError('failed-precondition', 'أسعار الفحوصات غير صالحة');
    const duplicate = await tx.get(db.collection('lab_bookings').where('labId', '==', labId).where('date', '==', date).where('time', '==', time).where('status', 'in', ['pending', 'confirmed']).limit(1));
    if (!duplicate.empty) throw new HttpsError('already-exists', 'هذا الموعد محجوز مسبقاً');
    const now = FieldValue.serverTimestamp();
    tx.create(bookingRef, {patientId: uid, patientName: patientSnap.data().name || patientSnap.data().displayName || 'مريض', labId, labName: lab.name || '', testIds, tests: selected.map((t) => ({id: String(t.id), name: String(t.name || ''), price: Number(t.price || 0)})), total, date, time, notes, status: 'pending', createdAt: now, updatedAt: now, cancelledAt: null, paymentStatus: 'unpaid'});
  });
  return {bookingId: bookingRef.id, status: 'pending'};
});
