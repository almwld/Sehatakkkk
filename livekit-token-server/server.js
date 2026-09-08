const express = require('express');
require('dotenv').config();
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 8080;
const LIVEKIT_API_KEY = process.env.LIVEKIT_API_KEY;
const LIVEKIT_API_SECRET = process.env.LIVEKIT_API_SECRET;
const LIVEKIT_URL = process.env.LIVEKIT_URL || 'wss://platformsehatak-z73p6n5m.livekit.cloud';

if (!LIVEKIT_API_KEY || !LIVEKIT_API_SECRET) {
  console.error('❌ Missing API keys');
  process.exit(1);
}

console.log('🔑 API Key configured');

// ✅ المسار الرئيسي (مع Firebase Auth)
app.post('/token', async (req, res) => {
  try {
    const { uid, room } = req.body;
    if (!uid) {
      return res.status(400).json({ success: false, message: 'uid is required' });
    }

    const roomName = room || 'default-room';
    const now = Math.floor(Date.now() / 1000);
    
    const claims = {
      iss: LIVEKIT_API_KEY,
      exp: now + 3600,
      nbf: now,
      sub: uid,
      video: {
        room: roomName,
        roomJoin: true,
        canPublish: true,
        canSubscribe: true,
        canPublishData: true,
      },
    };

    const token = jwt.sign(claims, LIVEKIT_API_SECRET, { algorithm: 'HS256' });

    return res.json({
      success: true,
      token: token,
      url: LIVEKIT_URL,
      roomName: roomName,
    });
  } catch (error) {
    console.error('❌ Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// ✅ مسار تجريبي (بدون Auth)
app.post('/token-dev', async (req, res) => {
  try {
    const { uid, room } = req.body;
    if (!uid) {
      return res.status(400).json({ success: false, message: 'uid is required' });
    }

    const roomName = room || 'default-room';
    const now = Math.floor(Date.now() / 1000);
    
    const claims = {
      iss: LIVEKIT_API_KEY,
      exp: now + 3600,
      nbf: now,
      sub: uid,
      video: {
        room: roomName,
        roomJoin: true,
        canPublish: true,
        canSubscribe: true,
        canPublishData: true,
      },
    };

    const token = jwt.sign(claims, LIVEKIT_API_SECRET, { algorithm: 'HS256' });

    return res.json({
      success: true,
      token: token,
      url: LIVEKIT_URL,
      roomName: roomName,
    });
  } catch (error) {
    console.error('❌ Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    apiKey: LIVEKIT_API_KEY ? 'configured' : 'missing',
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📡 LIVEKIT_URL: ${LIVEKIT_URL}`);
});
