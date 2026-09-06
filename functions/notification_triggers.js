const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

const db = admin.firestore();

function asString(value, fallback = '') {
  return value == null ? fallback : String(value);
}

async function sendToUser(uid, payload) {
  if (!uid) return {sent: false, reason: 'missing-user'};
  const userSnap = await db.collection('users').doc(uid).get();
  if (!userSnap.exists) return {sent: false, reason: 'user-not-found'};
  const token = asString(userSnap.data().fcmToken).trim();
  if (!token) return {sent: false, reason: 'missing-token'};

  try {
    await admin.messaging().send({
      token,
      notification: payload.notification,
      data: Object.fromEntries(Object.entries(payload.data || {}).map(([k, v]) => [k, asString(v)])),
      android: {priority: 'high', notification: {channelId: 'sehatak_channel'}},
    });
    return {sent: true};
  } catch (error) {
    // Remove invalid/stale tokens so future messages are not repeatedly rejected.
    const code = error?.code || '';
    if (code.includes('registration-token-not-registered') || code.includes('invalid-registration-token')) {
      await db.collection('users').doc(uid).set({fcmToken: admin.firestore.FieldValue.delete()}, {merge: true});
    }
    console.error('FCM send failed', uid, code, error?.message || error);
    return {sent: false, reason: code};
  }
}

exports.notifyNewChatMessage = onDocumentCreated('chats/{chatId}/messages/{messageId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const message = snapshot.data() || {};
  const chatId = event.params.chatId;
  const senderId = asString(message.senderId).trim();
  if (!senderId) return;

  const chatSnap = await db.collection('chats').doc(chatId).get();
  if (!chatSnap.exists) return;
  const chat = chatSnap.data() || {};
  const participants = Array.isArray(chat.participants) ? chat.participants.map(asString).filter(Boolean) : [];
  const recipients = participants.filter(uid => uid !== senderId);
  if (!recipients.length) return;

  const senderName = asString(message.senderName, 'مستخدم');
  const text = asString(message.text).trim();
  const type = asString(message.type, 'text');
  const body = text || (type === 'image' ? '📷 صورة جديدة' : type === 'audio' ? '🎤 رسالة صوتية' : type === 'file' ? '📎 ملف جديد' : 'لديك رسالة جديدة');

  await Promise.all(recipients.map(uid => sendToUser(uid, {
    notification: {title: senderName, body},
    data: {type: 'chat_message', chatId, messageId: snapshot.id, senderId, senderName},
  })));
});

exports.notifyIncomingCall = onDocumentCreated('calls/{callId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const call = snapshot.data() || {};
  const receiverId = asString(call.receiverId).trim();
  const callerId = asString(call.callerId).trim();
  if (!receiverId || !callerId) return;

  const isVideo = call.callType === 'video' || call.isVideoCall === true;
  const callerName = asString(call.callerName, 'مستخدم');
  await sendToUser(receiverId, {
    notification: {title: isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة', body: `من ${callerName}`},
    data: {
      type: 'incoming_call',
      callId: snapshot.id,
      chatId: asString(call.chatId),
      callerId,
      callerName,
      isVideo: isVideo ? 'true' : 'false',
    },
  });
});
