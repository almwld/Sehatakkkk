const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const db = admin.firestore();

async function sendToUser(uid, data) {
  const tokenSnap = await db.collection('users').doc(uid).collection('private').doc('tokens').get();
  const tokenData = tokenSnap.data() || {};
  const tokens = Array.isArray(tokenData.tokens) ? tokenData.tokens.map(v => String(v || '').trim()).filter(Boolean) : [];
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
  const prescription = after.prescription;
  const names = prescription.map(x => String(x?.name || x?.medicine || x?.medication || '').trim()).filter(Boolean);
  const namesEn = prescription.map(x => String(x?.nameEn || x?.name || x?.medicine || x?.medication || '').trim()).filter(Boolean);
  const namesFr = prescription.map(x => String(x?.nameFr || x?.name || x?.medicine || x?.medication || '').trim()).filter(Boolean);
  const doctorName = String(after.doctorName || 'الطبيب');
  const doctorNameEn = String(after.doctorNameEn || after.doctorName || 'the doctor');
  const doctorNameFr = String(after.doctorNameFr || after.doctorName || 'le médecin');
  const body = 'أضاف ' + doctorName + ' وصفة دوائية' + (names.length ? ': ' + names.join('، ') : '') + '. تم نقلها إلى تذكير الأدوية.';
  const bodyEn = doctorNameEn + ' added a new prescription' + (namesEn.length ? ': ' + namesEn.join(', ') : '') + '. It has been added to medication reminders.';
  const bodyFr = doctorNameFr + ' a ajouté une nouvelle ordonnance' + (namesFr.length ? ' : ' + namesFr.join(', ') : '') + '. Elle a été ajoutée aux rappels de médicaments.';
  const data = {
    type: 'medication_prescription',
    title: 'وصفة دوائية جديدة',
    titleEn: 'New medication prescription',
    titleFr: 'Nouvelle ordonnance médicale',
    body,
    bodyEn,
    bodyFr,
    consultationId: event.params.consultationId,
    doctorId: after.doctorId || '',
    recipientId: patientId,
    action: 'medications',
  };
  await db.collection('notifications').add({
    userId: patientId, type: data.type, title: data.title, titleEn: data.titleEn, titleFr: data.titleFr,
    body: data.body, bodyEn: data.bodyEn, bodyFr: data.bodyFr,
    data, consultationId: event.params.consultationId, doctorId: after.doctorId || null,
    action: 'medications', isRead: false, createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  await sendToUser(patientId, data);
});
