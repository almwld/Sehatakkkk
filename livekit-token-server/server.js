const express = require('express');
const admin = require('firebase-admin');
const { AccessToken } = require('livekit-server-sdk');

const app = express();
app.disable('x-powered-by');
app.use(express.json({ limit: '32kb' }));

const PORT = Number(process.env.PORT || 8080);
const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'sehatak-platform';
const LIVEKIT_API_KEY = process.env.LIVEKIT_API_KEY;
const LIVEKIT_API_SECRET = process.env.LIVEKIT_API_SECRET;
const LIVEKIT_URL = process.env.LIVEKIT_URL || 'wss://platformsehatak-z73p6n5m.livekit.cloud';

function initializeFirebase() {
  if (admin.apps.length) return;

  // Railway and other external hosts do not provide Google ADC automatically.
  // Prefer a service-account JSON secret supplied through the host environment.
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (raw) {
    try {
      const credentials = JSON.parse(raw);
      admin.initializeApp({
        credential: admin.credential.cert(credentials),
        projectId: credentials.project_id || FIREBASE_PROJECT_ID,
      });
      return;
    } catch (error) {
      throw new Error(`Invalid FIREBASE_SERVICE_ACCOUNT_JSON: ${error.message}`);
    }
  }

  // GOOGLE_APPLICATION_CREDENTIALS is supported for local/dev environments.
  // On Railway, configure FIREBASE_SERVICE_ACCOUNT_JSON instead.
  admin.initializeApp({ projectId: FIREBASE_PROJECT_ID });
}

initializeFirebase();

function requireLiveKitConfig() {
  if (!LIVEKIT_API_KEY || !LIVEKIT_API_SECRET) {
    const error = new Error('LiveKit server configuration is incomplete');
    error.statusCode = 503;
    throw error;
  }
}

function validText(value, max) {
  const text = String(value || '').trim();
  if (!text || text.length > max) return null;
  return text;
}

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'sehatak-livekit-token-server',
    firebaseProjectId: FIREBASE_PROJECT_ID,
    firebaseCredentialConfigured: Boolean(process.env.FIREBASE_SERVICE_ACCOUNT_JSON || process.env.GOOGLE_APPLICATION_CREDENTIALS),
    livekitConfigured: Boolean(LIVEKIT_API_KEY && LIVEKIT_API_SECRET),
  });
});

app.post('/token', async (req, res) => {
  try {
    requireLiveKitConfig();

    const header = req.get('authorization') || '';
    if (!header.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Firebase ID token is required' });
    }

    const idToken = header.slice('Bearer '.length).trim();
    if (!idToken) {
      return res.status(401).json({ success: false, message: 'Invalid authorization token' });
    }

    const decoded = await admin.auth().verifyIdToken(idToken);
    const uid = decoded.uid;
    const roomName = validText(req.body?.roomName, 200);
    const participantName = validText(req.body?.participantName || decoded.name || uid, 120);

    if (!roomName || !participantName) {
      return res.status(400).json({ success: false, message: 'Invalid roomName or participantName' });
    }

    const token = new AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
      identity: uid,
      name: participantName,
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
        participantName,
      },
    });
  } catch (error) {
    console.error('LiveKit token error:', error?.message || error);
    const status = Number(error?.statusCode || 500);
    return res.status(status >= 400 && status < 600 ? status : 500).json({
      success: false,
      message: status === 401 ? 'Firebase authentication failed' : 'Failed to create LiveKit token',
    });
  }
});

app.use((_req, res) => res.status(404).json({ success: false, message: 'Not found' }));

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Sehatak LiveKit token server listening on port ${PORT}`);
});
