// ============================================================
// Sehatak LiveKit / Firebase Admin token server
// ============================================================

const express = require('express');
const admin = require('firebase-admin');
const { AccessToken } = require('livekit-server-sdk');

const app = express();
app.use(express.json({ limit: '1mb' }));

const PORT = Number(process.env.PORT || 3000);
const LIVEKIT_URL = process.env.LIVEKIT_URL || '';

// Firebase Admin credentials are supplied through Railway environment variables.
if (!admin.apps.length) {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_JSON
    ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)
    : null;
  admin.initializeApp(serviceAccount ? { credential: admin.credential.cert(serviceAccount) } : { credential: admin.credential.applicationDefault() });
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
    console.log(`📋 [${requestId}] call status=${status} caller=${callerId} receiver=${receiverId}`);

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
    const chatId = String(call.chatId || '');
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

    console.log(`📤 [${requestId}] sending DATA-ONLY FCM receiver=${receiverId} token=${fcmToken.slice(0, 16)}… type=incoming_call isVideo=${isVideo}`);
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

app.use((error, _req, res, _next) => {
  if (error instanceof SyntaxError) return res.status(400).json({ success: false, message: 'Invalid JSON body' });
  console.error('Request error:', error);
  return res.status(500).json({ success: false, message: 'Internal server error' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Sehatak LiveKit token server running on port ${PORT}`);
  console.log(`LIVEKIT_URL: ${LIVEKIT_URL}`);
});
