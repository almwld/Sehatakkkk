// ============================================================
// Sehatak LiveKit / Firebase Admin token server
// ============================================================

const express = require('express');
const admin = require('firebase-admin');
const { AccessToken } = require('livekit-server-sdk');
require('dotenv').config();

const app = express();
app.use(express.json({ limit: '1mb' }));

const PORT = Number(process.env.PORT || 3000);
const LIVEKIT_URL = process.env.LIVEKIT_URL || '';

// Firebase Admin credentials are supplied through Railway environment variables.
if (!admin.apps.length) {
  const fs = require('fs');
  const path = require('path');
  let credential;
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    credential = admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON));
  } else if (fs.existsSync(path.join(__dirname, 'firebase-service-account.json'))) {
    credential = admin.credential.cert(require('./firebase-service-account.json'));
  } else {
    credential = admin.credential.applicationDefault();
  }
  admin.initializeApp({ credential });
}

const db = admin.firestore();

async function verifyFirebaseUser(req) {
  const auth = String(req.headers.authorization || '');
  if (!auth.startsWith('Bearer ')) {
    const error = new Error('Authorization bearer token is required');
    error.statusCode = 401;
    throw error;
  }
  try {
    return await admin.auth().verifyIdToken(auth.substring(7));
  } catch (_) {
    const error = new Error('Invalid Firebase ID token');
    error.statusCode = 401;
    throw error;
  }
}

app.get('/health', (_req, res) => res.json({ success: true, service: 'sehatak-livekit-token-server' }));

app.post('/token', async (req, res) => {
  try {
    const decodedToken = await verifyFirebaseUser(req);
    const roomName = String(req.body?.roomName || '').trim();
    const participantName = String(req.body?.participantName || decodedToken.name || 'مستخدم').trim();
    if (!roomName) return res.status(400).json({ success: false, message: 'roomName is required' });
    const apiKey = process.env.LIVEKIT_API_KEY;
    const apiSecret = process.env.LIVEKIT_API_SECRET;
    if (!apiKey || !apiSecret || !LIVEKIT_URL) return res.status(500).json({ success: false, message: 'LiveKit server configuration is incomplete' });
    const token = new AccessToken(apiKey, apiSecret, {
      identity: decodedToken.uid,
      name: participantName.slice(0, 120),
      ttl: '1h',
    });
    token.addGrant({ roomJoin: true, room: roomName, canPublish: true, canSubscribe: true, canPublishData: true });
    const jwt = await token.toJwt();
    return res.json({ success: true, data: { token: jwt, url: LIVEKIT_URL, roomName, participantIdentity: decodedToken.uid, participantName: participantName.slice(0, 120) } });
  } catch (error) {
    const status = Number(error.statusCode) || 500;
    if (status >= 500) console.error('Token error:', error.message || error);
    return res.status(status).json({ success: false, message: error.message || 'Unable to create LiveKit token' });
  }
});

// Production incoming-call notification endpoint.
// Flutter creates the canonical calls/{callId} document, then calls this endpoint.
// Railway verifies the caller and sends FCM directly, so Firebase Cloud Functions/Blaze are not required.
// IMPORTANT: the FCM payload is DATA-ONLY. This lets Flutter own the notification path:
// foreground -> onMessage -> IncomingCallScreen/local alert
// background/terminated -> background handler -> local call notification.
app.post('/call-notification', async (req, res) => {
  const requestId = `call-notify-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
  console.log(`📞 [${requestId}] incoming /call-notification request`);
  try {
    const decodedToken = await verifyFirebaseUser(req);
    const body = req.body && typeof req.body === 'object' ? req.body : {};
    const callId = String(body.callId || '').trim();
    console.log(`📞 [${requestId}] authenticated uid=${decodedToken.uid} callId=${callId || '(missing)'}`);
    if (!callId) return res.status(400).json({ success: false, message: 'callId is required', requestId });

    const callSnapshot = await db.collection('calls').doc(callId).get();
    if (!callSnapshot.exists) {
      console.error(`❌ [${requestId}] call not found id=${callId}`);
      return res.status(404).json({ success: false, message: 'Call not found', requestId });
    }

    const call = callSnapshot.data() || {};
    const callerId = String(call.callerId || '');
    const receiverId = String(call.receiverId || '').trim();
    const status = String(call.status || '');
    const chatId = String(call.chatId || '').trim();
    console.log(`📋 [${requestId}] call status=${status} caller=${callerId} receiver=${receiverId} chatId=${chatId || '(missing)'}`);

    if (callerId !== String(decodedToken.uid)) {
      console.error(`❌ [${requestId}] caller authorization mismatch token=${decodedToken.uid} call.callerId=${callerId}`);
      return res.status(403).json({ success: false, message: 'Caller is not authorized for this call', requestId });
    }
    if (!['calling', 'ringing'].includes(status)) {
      console.warn(`⚠️ [${requestId}] call no longer ringing status=${status}`);
      return res.status(409).json({ success: false, message: 'Call is no longer ringing', status, requestId });
    }
    if (!receiverId || receiverId === decodedToken.uid) {
      console.error(`❌ [${requestId}] invalid receiverId=${receiverId}`);
      return res.status(400).json({ success: false, message: 'Invalid receiverId', requestId });
    }
    if (!chatId) {
      console.error(`❌ [${requestId}] call has no chatId callId=${callId}`);
      return res.status(400).json({ success: false, reason: 'missing_chat_id', message: 'Call chatId is required for incoming-call UI', requestId });
    }

    const receiverSnapshot = await db.collection('users').doc(receiverId).get();
    if (!receiverSnapshot.exists) {
      console.error(`❌ [${requestId}] receiver user not found uid=${receiverId}`);
      return res.status(404).json({ success: false, message: 'Receiver not found', requestId });
    }
    const receiver = receiverSnapshot.data() || {};
    const fcmToken = typeof receiver.fcmToken === 'string' ? receiver.fcmToken.trim() : '';
    if (!fcmToken) {
      console.error(`❌ [${requestId}] receiver has no FCM token uid=${receiverId}`);
      return res.status(200).json({ success: true, sent: false, reason: 'fcm_token_missing', requestId });
    }

    const isVideo = call.isVideoCall === true || String(call.callType || '') === 'video';
    const callerName = String(call.callerName || decodedToken.name || 'مستخدم');
    const callerPhotoUrl = String(call.callerPhotoUrl || '');
    const message = {
      token: fcmToken,
      data: {
        type: 'incoming_call',
        callId,
        chatId,
        callerId,
        callerName,
        callerPhotoUrl,
        isVideo: isVideo ? 'true' : 'false',
        callType: isVideo ? 'video' : 'audio',
      },
      android: {
        priority: 'high',
        ttl: 60 * 1000,
      },
    };

    console.log(`📤 [${requestId}] sending DATA-ONLY FCM receiver=${receiverId} token=${fcmToken.slice(0, 16)}… type=incoming_call isVideo=${isVideo} chatId=${chatId}`);
    try {
      const messageId = await admin.messaging().send(message);
      console.log(`✅ [${requestId}] FCM accepted by Firebase messageId=${messageId}`);
      return res.json({ success: true, sent: true, messageId, callId, receiverId, requestId, mode: 'data_only' });
    } catch (error) {
      console.error(`❌ [${requestId}] Incoming call FCM error code=${error.code || 'unknown'} message=${error.message || error}`);
      if (['messaging/registration-token-not-registered', 'messaging/invalid-registration-token'].includes(error.code)) {
        await db.collection('users').doc(receiverId).set({ fcmToken: null, lastTokenUpdate: null }, { merge: true });
        console.warn(`🧹 [${requestId}] cleared invalid FCM token uid=${receiverId}`);
      }
      return res.status(502).json({ success: false, sent: false, reason: error.code || 'fcm_send_failed', requestId });
    }
  } catch (error) {
    const status = Number(error.statusCode) || 500;
    console.error(`❌ [${requestId}] Call notification error status=${status} message=${error.message || error}`);
    return res.status(status).json({ success: false, message: error.message || 'Unable to send incoming call notification', requestId });
  }
});

// ============================================================
// Firestore -> FCM: New chat message listener
// ============================================================
function buildMessagePayload(opts) {
  var preview = String(opts.messageText || '').slice(0, 120);
  return {
    token: opts.fcmToken,
    data: {
      type: 'new_message',
      chatId: String(opts.chatId || ''),
      messageId: String(opts.messageId || ''),
      senderId: String(opts.senderId || ''),
      senderName: String(opts.senderName || 'user'),
      senderPhotoUrl: String(opts.senderPhotoUrl || ''),
      body: preview,
      title: String(opts.senderName || 'New message'),
      chatType: String(opts.chatType || 'direct'),
      timestamp: String(Date.now())
    },
    android: {
      priority: 'high',
      ttl: 3600000,
      notification: { channelId: 'sehatak_messages_v2' }
    },
    apns: {
      headers: { 'apns-priority': '5', 'apns-push-type': 'background' },
      payload: { aps: { 'content-available': 1 } }
    }
  };
}

async function handleNewMessage(change) {
  try {
    var msg = change.doc.data() || {};
    // Call timeline entries are not chat messages. The dedicated
    // /call-notification endpoint already sends the incoming-call FCM, so
    // never emit a second notification that opens the chat room.
    if (msg.type === 'call' || (msg.metadata && msg.metadata.callId) || msg.callId) return;
    var messageId = change.doc.id;
    var parent = change.doc.ref.parent;
    var chatId = parent && parent.parent ? parent.parent.id : null;
    if (!chatId) { console.warn('[msg] no chatId id=' + messageId); return; }

    var senderId = String(msg.senderId || '');
    if (!senderId) { console.warn('[msg] no senderId id=' + messageId); return; }

    var senderName = String(msg.senderName || msg.senderDisplayName || '');
    var senderPhotoUrl = String(msg.senderPhotoUrl || msg.senderAvatar || '');
    var messageText = '';
    if (typeof msg.text === 'string') messageText = msg.text;
    else if (typeof msg.message === 'string') messageText = msg.message;
    else if (typeof msg.content === 'string') messageText = msg.content;

    var chatSnap = await db.collection('chats').doc(chatId).get();
    if (!chatSnap.exists) { console.warn('[msg] chat missing id=' + chatId); return; }
    var chat = chatSnap.data() || {};

    if (chat.isMuted === true || chat.muted === true) {
      console.log('[msg] muted chatId=' + chatId);
      return;
    }

    var participants = Array.isArray(chat.participants)
      ? chat.participants.map(String).filter(Boolean) : [];
    if (participants.length === 0) { console.warn('[msg] no participants'); return; }

    var receivers = participants.filter(function(id) { return id !== senderId; });
    if (receivers.length === 0) { console.log('[msg] self-chat'); return; }

    var userRefs = receivers.map(function(uid) { return db.collection('users').doc(uid); });
    var userSnaps = await db.getAll.apply(db, userRefs);

    var chatType = String(chat.type || 'direct');
    var senderLabel = senderName || 'user';
    var sentCount = 0;
    var i;

    for (i = 0; i < userSnaps.length; i++) {
      var userSnap = userSnaps[i];
      if (!userSnap.exists) continue;
      var user = userSnap.data() || {};
      var fcmToken = typeof user.fcmToken === 'string' ? user.fcmToken.trim() : '';
      if (!fcmToken) continue;

      var payload = buildMessagePayload({
        fcmToken: fcmToken,
        senderId: senderId,
        senderName: senderLabel,
        senderPhotoUrl: senderPhotoUrl,
        chatId: chatId,
        messageId: messageId,
        messageText: messageText,
        chatType: chatType
      });

      try {
        var fcmId = await admin.messaging().send(payload);
        sentCount++;
        console.log('[msg] sent id=' + messageId + ' to=' + userSnap.id + ' fcm=' + fcmId);
      } catch (err) {
        console.error('[msg] FCM failed to=' + userSnap.id + ' code=' + (err.code || '?'));
        if (err.code === 'messaging/registration-token-not-registered' ||
            err.code === 'messaging/invalid-registration-token') {
          await db.collection('users').doc(userSnap.id).set(
            { fcmToken: null, lastTokenUpdate: null }, { merge: true }
          );
        }
      }
    }
    console.log('[msg] done id=' + messageId + ' sent=' + sentCount + '/' + receivers.length);
  } catch (err) {
    console.error('[msg] handler error: ' + (err.message || err));
  }
}

function startMessageListener() {
  try {
    var startTime = new Date();
    console.log('[msg] listener starting since ' + startTime.toISOString());
    db.collectionGroup('messages')
      .where('timestamp', '>=', startTime)
      .orderBy('timestamp', 'asc')
      .onSnapshot(
        function(snap) {
          snap.docChanges().forEach(function(change) {
            if (change.type !== 'added') return;
            handleNewMessage(change).catch(function(err) {
              console.error('[msg] unhandled: ' + (err.message || err));
            });
          });
        },
        function(err) { console.error('[msg] snapshot error: ' + (err.message || err)); }
      );
    console.log('[msg] listener active.');
  } catch (err) {
    console.error('[msg] listener failed: ' + (err.message || err));
  }
}
// ============================================================

app.use((error, _req, res, _next) => {
  if (error instanceof SyntaxError) return res.status(400).json({ success: false, message: 'Invalid JSON body' });
  console.error('Request error:', error);
  return res.status(500).json({ success: false, message: 'Internal server error' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Sehatak LiveKit token server running on port ${PORT}`);
  console.log(`LIVEKIT_URL: ${LIVEKIT_URL}`);
  startMessageListener();
});
