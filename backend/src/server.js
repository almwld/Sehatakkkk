require('dotenv').config({
  path: require('path').resolve(__dirname, '../../.env'),
});

const express = require('express');
const cors = require('cors');

const firebaseRoutes = require('./routes/firebase.routes');
const filesRoutes = require('./routes/files.routes');
const chatRoutes = require('./routes/chat.routes');
const livekitRoutes = require('./routes/livekit.routes');

const app = express();

const PORT = process.env.PORT || 3000;

/*
|--------------------------------------------------------------------------
| Middleware
|--------------------------------------------------------------------------
*/

app.use(cors());

app.use(express.json({
  limit: '10mb',
}));

app.use(express.urlencoded({
  extended: true,
  limit: '10mb',
}));

/*
|--------------------------------------------------------------------------
| Basic Routes
|--------------------------------------------------------------------------
*/

app.get('/', (req, res) => {
  res.json({
    success: true,
    app: 'SEHATAK BACKEND',
    version: process.env.APP_VERSION || '1.0.0',
    status: 'running',
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    status: 'healthy',
    service: 'sehatak-backend',
    timestamp: new Date().toISOString(),
  });
});

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Firebase / Firestore
app.use('/api/firebase', firebaseRoutes);

// Nextcloud files
app.use('/api/files', filesRoutes);

// Chat / Firestore
app.use('/api/chats', chatRoutes);
app.use('/api/livekit', livekitRoutes);

/*
|--------------------------------------------------------------------------
| 404 Handler
|--------------------------------------------------------------------------
*/

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'المسار غير موجود',
    path: req.originalUrl,
  });
});

/*
|--------------------------------------------------------------------------
| Global Error Handler
|--------------------------------------------------------------------------
*/

app.use((error, req, res, next) => {
  console.error('========== SERVER ERROR ==========');
  console.error(error);
  console.error('==================================');

  res.status(error.status || 500).json({
    success: false,
    message: 'حدث خطأ في الخادم',
  });
});

/*
|--------------------------------------------------------------------------
| Start Server
|--------------------------------------------------------------------------
*/

app.listen(PORT, () => {
  console.log('');
  console.log('==================================================');
  console.log('🏥 SEHATAK BACKEND');
  console.log('==================================================');
  console.log(`🚀 Server:    http://localhost:${PORT}`);
  console.log(`❤️  Health:    http://localhost:${PORT}/health`);
  console.log(`🔥 Firebase:  http://localhost:${PORT}/api/firebase/health`);
  console.log(`💬 Chats:     http://localhost:${PORT}/api/chats`);
  console.log(`📁 Files:     http://localhost:${PORT}/api/files`);
  console.log(`☁️  Nextcloud: ${process.env.NEXTCLOUD_URL ? 'enabled' : 'disabled'}`);
  console.log(`🔥 Firestore: enabled`);
  console.log(`📞 LiveKit:   ${process.env.LIVEKIT_URL ? 'configured' : 'pending'}`);
  console.log('==================================================');
  console.log('');
});
