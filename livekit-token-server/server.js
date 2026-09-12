const express = require('express');
const admin = require('firebase-admin');
const { AccessToken } = require('livekit-server-sdk');
require('dotenv').config();

const app = express();
app.disable('x-powered-by');
app.use(express.json({ limit: '32kb' }));

const PORT = Number(process.env.PORT || 8080);
const LIVEKIT_API_KEY = process.env.LIVEKIT_API_KEY;
const LIVEKIT_API_SECRET = process.env.LIVEKIT_API_SECRET;
const LIVEKIT_URL = process.env.LIVEKIT_URL || 'wss://platformsehatak-z73p6n5m.livekit.cloud';
const FIREBASE_SERVICE_ACCOUNT_JSON = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

let firebaseConfigured = false;

if (FIREBASE_SERVICE_ACCOUNT_JSON) {
  try {
    const serviceAccount = JSON.parse(FIREBASE_SERVICE_ACCOUNT_JSON);
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    firebaseConfigured = true;
  } catch (error) {
    console.error('Invalid FIREBASE_SERVICE_ACCOUNT_JSON:', error.message);
  }
} else {
  console.warn('FIREBASE_SERVICE_ACCOUNT_JSON is not configured; Firebase endpoints will be unavailable.');
}

if (!LIVEKIT_API_KEY || !LIVEKIT_API_SECRET) {
  console.warn('LIVEKIT_API_KEY/LIVEKIT_API_SECRET are not configured; /token will return 503 until configured.');
}

function getBearerToken(req) {
  const header = req.get('authorization') || '';
  if (!header.startsWith('Bearer ')) return null;
  return header.slice('Bearer '.length).trim() || null;
}

async function verifyFirebaseUser(req) {
  const idToken = getBearerToken(req);
  if (!idToken) {
    const error = new Error('Firebase ID token is required');
    error.statusCode = 401;
    throw error;
  }
  if (!firebaseConfigured) {
    const error = new Error('Firebase authentication is not configured on the token server');
    error.statusCode = 503;
    throw error;
  }
  try {
    return await admin.auth().verifyIdToken(idToken);
  } catch (_) {
    const error = new Error('Invalid or expired Firebase ID token');
    error.statusCode = 401;
    throw error;
  }
}

app.get('/health', (_req, res) => {
  const ready = firebaseConfigured && Boolean(LIVEKIT_API_KEY && LIVEKIT_API_SECRET);
  res.status(ready ? 200 : 503).json({
    status: ready ? 'ok' : 'not_ready',
    service: 'sehatak-livekit-token-server',
    livekit: LIVEKIT_URL,
    firebaseAuth: firebaseConfigured ? 'configured' : 'not_configured',
    livekitCredentials: LIVEKIT_API_KEY && LIVEKIT_API_SECRET ? 'configured' : 'not_configured',
  });
});

// Compatibility/readiness endpoint used by the backend notification test suite.
// Keep this endpoint unauthenticated and cheap: it only reports whether Firebase
// and FCM are configured on this process. It does not send a notification.
app.get('/notification/health', (_req, res) => {
  const firebaseReady = firebaseConfigured;
  const messagingReady = firebaseConfigured && Boolean(admin.apps.length);
  const ready = firebaseReady && messagingReady;
  return res.status(ready ? 200 : 503).json({
    status: ready ? 'ok' : 'not_ready',
    service: 'sehatak-livekit-token-server',
    notification: 'fcm',
    firebaseAuth: firebaseReady ? 'configured' : 'not_configured',
    firebaseMessaging: messagingReady ? 'configured' : 'not_configured',
  });
});

app.get('/', (_req, res) => {
  res.json({ service: 'sehatak-livekit-token-server', status: 'running' });
});

app.post('/token', async (req, res) => {
  try {
    if (!LIVEKIT_API_KEY || !LIVEKIT_API_SECRET) {
      return res.status(503).json({ success: false, message: 'LiveKit credentials are not configured' });
    }
    const decodedToken = await verifyFirebaseUser(req);
    const uid = decodedToken.uid;
    const body = req.body && typeof req.body === 'object' ? req.body : {};
    const roomName = String(body.roomName || body.room || '').trim();
    const participantName = String(body.participantName || decodedToken.name || 'مستخدم').trim();
    if (!roomName) return res.status(400).json({ success: false, message: 'roomName is required' });
    if (roomName.length > 128) return res.status(400).json({ success: false, message: 'roomName is too long' });

    const token = new AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
      identity: uid,
      name: participantName.slice(0, 120),
      ttl: '1h',
    });
    token.addGrant({ roomJoin: true, room: roomName, canPublish: true, canSubscribe: true, canPublishData: true });
    const jwt = await token.toJwt();
    return res.json({ success: true, data: { token: jwt, url: LIVEKIT_URL, roomName, participantIdentity: uid, participantName: participantName.slice(0, 120) } });
  } catch (error) {
    const status = Number(error.statusCode) || 500;
    if (status >= 500) console.error('Token error:', error.message);
    return res.status(status).json({ success: false, message: error.message || 'Unable to create LiveKit token' });
  }
});

// Production incoming-call notification endpoint.
// Flutter creates the canonical calls/{callId} document, then calls this endpoint.
// Railway verifies the caller and sends FCM directly, so Firebase Cloud Functions/Blaze are not required.
// FCM is intentionally DATA-ONLY: Flutter handles foreground/background routing itself,
// while the background handler creates the local notification with the app's call channel.
app.post('/call-notification', async (req, res) => {
  const requestId = `call-notify-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
  console.log(`📞 [${requestId}] /call-notification received`);
  try {
    const decodedToken = await verifyFirebaseUser(req);
    const body = req.body && typeof req.body === 'object' ? req.body : {};
    const callId = String(body.callId || '').trim();
    console.log(`📞 [${requestId}] authenticated uid=${decodedToken.uid} callId=${callId || '(missing)'}`);
    if (!callId) return res.status(400).json({ success: false, message: 'callId is required', requestId });

    const db = admin.firestore();
    const callSnapshot = await db.collection('calls').doc(callId).get();
    if (!callSnapshot.exists) {
      console.error(`❌ [${requestId}] Call not found id=${callId}`);
      return res.status(404).json({ success: false, message: 'Call not found', requestId });
    }

    const call = callSnapshot.data() || {};
    const callerId = String(call.callerId || '');
    const receiverId = String(call.receiverId || '').trim();
    const status = String(call.status || '');
    console.log(`📋 [${requestId}] call status=${status} caller=${callerId} receiver=${receiverId}`);

    if (callerId !== String(decodedToken.uid)) {
      console.error(`❌ [${requestId}] Caller authorization mismatch token=${decodedToken.uid} call.callerId=${callerId}`);
      return res.status(403).json({ success: false, message: 'Caller is not authorized for this call', requestId });
    }
    if (!['calling', 'ringing'].includes(status)) {
      console.warn(`⚠️ [${requestId}] Call is no longer ringing status=${status}`);
      return res.status(409).json({ success: false, message: 'Call is no longer ringing', status, requestId });
    }
    if (!receiverId || receiverId === decodedToken.uid) {
      console.error(`❌ [${requestId}] Invalid receiverId=${receiverId}`);
      return res.status(400).json({ success: false, message: 'Invalid receiverId', requestId });
    }

    const receiverSnapshot = await db.collection('users').doc(receiverId).get();
    if (!receiverSnapshot.exists) {
      console.error(`❌ [${requestId}] Receiver not found uid=${receiverId}`);
      return res.status(404).json({ success: false, message: 'Receiver not found', requestId });
    }
    const receiver = receiverSnapshot.data() || {};
    const fcmToken = typeof receiver.fcmToken === 'string' ? receiver.fcmToken.trim() : '';
    if (!fcmToken) {
      console.error(`❌ [${requestId}] No FCM token for receiver uid=${receiverId}`);
      return res.status(200).json({ success: true, sent: false, reason: 'fcm_token_missing', requestId });
    }

    const isVideo = call.isVideoCall === true || String(call.callType || '') === 'video';
    const callerName = String(call.callerName || decodedToken.name || 'مستخدم');
    const message = {
      token: fcmToken,
      data: {
        type: 'incoming_call',
        callId,
        chatId: String(call.chatId || ''),
        callerId,
        callerName,
        callerPhotoUrl: String(call.callerPhotoUrl || ''),
        isVideo: isVideo ? 'true' : 'false',
        callType: isVideo ? 'video' : 'audio',
      },
      android: {
        priority: 'high',
        ttl: 60 * 1000,
      },
    };

    console.log(`📤 [${requestId}] FCM DATA-ONLY -> receiver=${receiverId} token=${fcmToken.slice(0, 16)}… isVideo=${isVideo}`);
    try {
      const messageId = await admin.messaging().send(message);
      console.log(`✅ [${requestId}] FCM accepted messageId=${messageId}`);
      return res.json({ success: true, sent: true, messageId, callId, receiverId, requestId, mode: 'data_only' });
    } catch (error) {
      console.error(`❌ [${requestId}] Incoming call FCM error code=${error.code || 'unknown'} message=${error.message || error}`);
      if (['messaging/registration-token-not-registered', 'messaging/invalid-registration-token'].includes(error.code)) {
        await db.collection('users').doc(receiverId).set({ fcmToken: null, lastTokenUpdate: null }, { merge: true });
        console.warn(`🧹 [${requestId}] Invalid FCM token cleared uid=${receiverId}`);
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
