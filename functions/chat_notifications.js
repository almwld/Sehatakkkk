const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

const db = admin.firestore();

async function sendToUser(uid, payload) {
  if (!uid) return;
  const userSnap = await db.collection('users').doc(uid).get();
  const token = userSnap.data()?.fcmToken;
  if (!token) return;
  try {
    await admin.messaging().send({
      token,
      notification: payload.notification,
      data: payload.data,
      android: {
        priority: 'high',
        notification: {channelId: 'sehatak_channel', sound: 'default'},
      },
    });
  } catch (error) {
    console.error(`FCM send failed for ${uid}:`, error.message);
    if (['messaging/registration-token-not-registered', 'messaging/invalid-registration-token'].includes(error.code)) {
      await db.collection('users').doc(uid).set({fcmToken: null}, {merge: true});
    }
  }
}

exports.notifyNewChatMessage = onDocumentCreated('chats/{chatId}/messages/{messageId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const message = snapshot.data() || {};
  const chatId = event.params.chatId;
  const messageId = event.params.messageId;
  const senderId = String(message.senderId || '');
  if (!senderId) return;

  const chatSnap = await db.collection('chats').doc(chatId).get();
  if (!chatSnap.exists) return;
  const chat = chatSnap.data() || {};
  if (chat.isMuted === true) return;

  const participants = Array.isArray(chat.participants) ? chat.participants.map(String) : [];
  const receiverIds = participants.filter((uid) => uid && uid !== senderId);
  if (!receiverIds.length) return;

  const type = String(message.type || 'text');
  const text = String(message.text || '').trim();
  const body = type === 'image' ? '📷 أرسل صورة' : type === 'audio' ? '🎵 أرسل رسالة صوتية' : type === 'location' ? '📍 شارك موقعاً' : (text || 'أرسل رسالة جديدة');
  const senderName = String(message.senderName || 'مستخدم');

  await Promise.all(receiverIds.map((uid) => sendToUser(uid, {
    notification: {title: senderName, body},
    data: {
      type: 'chat_message',
      chatId,
      messageId,
      senderId,
      senderName,
    },
  })));
});

exports.notifyIncomingCall = onDocumentCreated('calls/{callId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const call = snapshot.data() || {};
  const receiverId = String(call.receiverId || '');
  const callerId = String(call.callerId || '');
  if (!receiverId || !callerId) return;

  const isVideo = call.callType === 'video' || call.isVideoCall === true;
  const callId = event.params.callId;
  const chatId = String(call.chatId || call.liveKitRoomName || callId);

  await sendToUser(receiverId, {
    notification: {title: isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة صوتية واردة', body: `${call.callerName || 'مستخدم'} يتصل بك`},
    data: {
      type: 'incoming_call',
      callId,
      chatId,
      callerId,
      callerName: String(call.callerName || 'مستخدم'),
      isVideo: String(isVideo),
    },
  });
});
