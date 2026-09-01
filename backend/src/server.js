require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

const express = require('express');
const cors = require('cors');

const filesRoutes = require('./routes/files.routes');

const app = express();

app.disable('x-powered-by');

app.use(
  cors({
    origin: true,
    credentials: true,
  })
);

app.use(
  express.json({
    limit: '10mb',
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: '10mb',
  })
);

app.get('/health', (req, res) => {
  res.json({
    success: true,
    service: 'Sehatak Backend',
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/files', filesRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'المسار غير موجود',
  });
});

app.use((err, req, res, next) => {
  console.error('Backend error:', err);

  res.status(500).json({
    success: false,
    message: 'حدث خطأ داخلي في الخادم',
  });
});

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(`
==================================================
🏥 SEHATAK BACKEND
==================================================
🚀 Server:    http://localhost:${PORT}
❤️  Health:    http://localhost:${PORT}/health
☁️  Nextcloud: enabled
🔥 Firestore:  pending
📞 LiveKit:    pending
==================================================
`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down...');
  server.close(() => {
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received. Shutting down...');
  server.close(() => {
    process.exit(0);
  });
});

module.exports = app;
