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
  console.warn('FIREBASE_SERVICE_ACCOUNT_JSON is not configured; /token will return 503 until configured.');
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

    if (!roomName) {
      return res.status(400).json({ success: false, message: 'roomName is required' });
    }
    if (roomName.length > 128) {
      return res.status(400).json({ success: false, message: 'roomName is too long' });
    }

    const token = new AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
      identity: uid,
      name: participantName.slice(0, 120),
      ttl: '1h',
    });

    token.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    });

    const jwt = await token.toJwt();

    return res.json({
      success: true,
      data: {
        token: jwt,
        url: LIVEKIT_URL,
        roomName,
        participantIdentity: uid,
        participantName: participantName.slice(0, 120),
      },
    });
  } catch (error) {
    const status = Number(error.statusCode) || 500;
    if (status >= 500) console.error('Token error:', error.message);
    return res.status(status).json({
      success: false,
      message: error.message || 'Unable to create LiveKit token',
    });
  }
});

app.use((error, _req, res, _next) => {
  if (error instanceof SyntaxError) {
    return res.status(400).json({ success: false, message: 'Invalid JSON body' });
  }
  console.error('Request error:', error);
  return res.status(500).json({ success: false, message: 'Internal server error' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Sehatak LiveKit token server running on port ${PORT}`);
  console.log(`LIVEKIT_URL: ${LIVEKIT_URL}`);
});
