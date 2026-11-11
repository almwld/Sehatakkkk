const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const db = admin.firestore();

function norm(value) {
  return String(value || '').trim().toLowerCase().replace(/[\\s\\-_.]/g, '');
}

async function sendFcm(uid, data) {
  const tokenSnap = await db.collection('users').doc(uid).collection('private').doc('tokens').get();
  const tokenData = tokenSnap.data() || {};
  const tokens = Array.isArray(tokenData.tokens) ? tokenData.tokens.map(v => String(v || '').trim()).filter(Boolean) : [];
  if (!tokens.length) return;
  try {
    await admin.messaging().sendEachForMulticast({
      tokens,
      data: Object.fromEntries(Object.entries(data).map(([k,v]) => [k, String(v ?? '')])),
      android: {priority: 'high', ttl: 60 * 60 * 1000},
      apns: {headers: {'apns-priority': '5', 'apns-push-type': 'background'}, payload: {aps: {'content-available': 1}}},
    });
  } catch (e) { console.warn('pharmacy purchase notification failed:', e.message); }
}

exports.onPharmacyOrderCreated = onDocumentCreated('orders/{orderId}', async event => {
  const snap = event.data;
  if (!snap) return;
  const order = snap.data() || {};
  if (order.type !== 'pharmacy' || (order.paymentStatus !== 'paid' && order.status !== 'paid')) return;
  const patientId = String(order.userId || '');
  if (!patientId || !Array.isArray(order.items)) return;

  const pharmacyOwnerId = String(order.providerId || '');
  if (pharmacyOwnerId) {
    await sendFcm(pharmacyOwnerId, {
      type: 'pharmacy_order_created',
      orderId: event.params.orderId,
      invoiceId: order.invoiceId || '',
      title: 'طلب صيدلية جديد',
      titleEn: 'New pharmacy order',
      titleFr: 'Nouvelle commande de pharmacie',
      body: 'لديك طلب مدفوع جديد يحتاج إلى التأكيد.',
      bodyEn: 'You have a new paid order that needs confirmation.',
      bodyFr: 'Vous avez une nouvelle commande payée à confirmer.',
    });
  }

  const medicationsSnap = await db.collection('users').doc(patientId).collection('medications').where('active', '==', true).get();
  const medications = medicationsSnap.docs.map(d => ({id: d.id, ...d.data()}));
  const notifications = [];
  const batch = db.batch();

  for (const item of order.items) {
    const itemName = norm(item.name || item.genericName);
    const linked = medications.filter(m => {
      if (item.medicationId && String(m.id) === String(item.medicationId)) return true;
      if (item.prescriptionId && (String(m.prescriptionItemId || '') === String(item.prescriptionId) || String(m.consultationId || '') === String(item.prescriptionId))) return true;
      if (item.productId && String(m.productId || '') === String(item.productId)) return true;
      return itemName && itemName === norm(m.name || m.genericName);
    });
    for (const med of linked) {
      const qty = Math.max(1, Number(item.quantity || 1));
      const current = Number(med.remainingQuantity ?? med.remainingPills ?? 0);
      const remaining = Math.max(0, current + qty);
      batch.set(db.collection('users').doc(patientId).collection('medications').doc(med.id), {
        lastPurchasedAt: admin.firestore.FieldValue.serverTimestamp(),
        lastPurchaseOrderId: event.params.orderId,
        lastPurchasedQuantity: qty,
        remainingQuantity: remaining,
        remainingPills: remaining,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, {merge: true});
      const doctorId = String(item.doctorId || med.doctorId || '');
      if (doctorId) {
        const displayName = String(item.name || med.name || 'دواء');
        const displayNameEn = String(item.nameEn || med.nameEn || item.name || med.name || 'medicine');
        const displayNameFr = String(item.nameFr || med.nameFr || item.name || med.name || 'médicament');
        const n = {
          userId: doctorId,
          type: 'medication_purchased',
          title: 'تم شراء الدواء الموصوف',
          titleEn: 'Prescribed medication purchased',
          titleFr: 'Médicament prescrit acheté',
          body: 'اشترى المريض الدواء «' + displayName + '» بكمية ' + qty + '، وتم ربط العملية بالوصفة.',
          bodyEn: 'The patient purchased “' + displayNameEn + '” (quantity: ' + qty + ') and it was linked to the prescription.',
          bodyFr: 'Le patient a acheté « ' + displayNameFr + ' » (quantité : ' + qty + ') ; l’achat a été associé à l’ordonnance.',
          data: {type: 'medication_purchased', orderId: event.params.orderId, medicationId: med.id, patientId, quantity: qty},
          orderId: event.params.orderId,
          medicationId: med.id,
          patientId,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        const ref = db.collection('notifications').doc();
        batch.set(ref, n);
        notifications.push({doctorId, data: n.data, notification: n});
      }
    }
  }
  if (notifications.length || medications.length) await batch.commit();
  await Promise.all(notifications.map(n => sendFcm(n.doctorId, {
    ...n.data,
    title: n.notification.title,
    titleEn: n.notification.titleEn,
    titleFr: n.notification.titleFr,
    body: n.notification.body,
    bodyEn: n.notification.bodyEn,
    bodyFr: n.notification.bodyFr,
  })));
});
