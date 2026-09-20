const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const db = admin.firestore();

async function sendToUser(uid, data) {
  const snap = await db.collection('users').doc(uid).get();
  const u = snap.data() || {};
  const tokens = [...(Array.isArray(u.fcmTokens) ? u.fcmTokens : []), u.fcmToken].map(v => String(v || '').trim()).filter(Boolean);
  if (!tokens.length) return;
  try {
    await admin.messaging().sendEachForMulticast({tokens, data: Object.fromEntries(Object.entries(data).map(([k,v]) => [k, String(v ?? '')])), android:{priority:'high', ttl:3600000}, apns:{headers:{'apns-priority':'5','apns-push-type':'background'},payload:{aps:{'content-available':1}}}});
  } catch (e) { console.warn('prescription notification FCM failed:', e.message); }
}

exports.onPrescriptionUpdated = onDocumentUpdated('consultations/{consultationId}', async (event) => {
  const before = event.data?.before?.data() || {};
  const after = event.data?.after?.data() || {};
  if (!Array.isArray(after.prescription) || JSON.stringify(before.prescription || null) === JSON.stringify(after.prescription || null)) return;
  const patientId = String(after.patientId || '');
  if (!patientId) return;
  const names = after.prescription.map(x => String(x?.name || x?.medicine || x?.medication || '').trim()).filter(Boolean);
  const data = {
    type: 'medication_prescription',
    title: 'وصفة دوائية جديدة',
    body: 'أضاف ' + String(after.doctorName || 'الطبيب') + ' وصفة دوائية' + (names.length ? ': ' + names.join('، ') : '') + '. تم نقلها إلى تذكير الأدوية.',
    consultationId: event.params.consultationId,
    doctorId: after.doctorId || '',
    recipientId: patientId,
    action: 'medications',
  };
  await db.collection('notifications').add({
    userId: patientId, type: data.type, title: data.title, body: data.body,
    data, consultationId: event.params.consultationId, doctorId: after.doctorId || null,
    action: 'medications', isRead: false, createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  await sendToUser(patientId, data);
});
