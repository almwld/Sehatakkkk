const {onDocumentUpdated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const db = admin.firestore();
exports.onPrescriptionUpdated = onDocumentUpdated('consultations/{consultationId}', async (event) => {
  const before = event.data?.before?.data() || {};
  const after = event.data?.after?.data() || {};
  if (!Array.isArray(after.prescription) || JSON.stringify(before.prescription || null) === JSON.stringify(after.prescription || null)) return;
  const patientId = String(after.patientId || ''); if (!patientId) return;
  const names = after.prescription.map(x => String(x?.name || x?.medicine || x?.medication || '').trim()).filter(Boolean);
  await db.collection('notifications').add({
    userId: patientId, type: 'medication_prescription', title: 'وصفة دوائية جديدة',
    body: 'أضاف ' + String(after.doctorName || 'الطبيب') + ' وصفة دوائية' + (names.length ? ': ' + names.join('، ') : '') + '. تم نقلها إلى تذكير الأدوية.',
    consultationId: event.params.consultationId, doctorId: after.doctorId || null,
    action: 'medications', isRead: false, createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
});