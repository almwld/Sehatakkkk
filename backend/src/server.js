require('dotenv').config({
  path: require('path').resolve(__dirname, '../../.env'),
});

const express = require('express');
const cors = require('cors');

const firebaseRoutes = require('./routes/firebase.routes');
const filesRoutes = require('./routes/files.routes');
const chatRoutes = require('./routes/chat.routes');
const { requireAuth } = require('./middleware/auth.middleware');
const livekitRoutes = require('./routes/livekit.routes');
const labResultsRoutes = require('./routes/lab-results.routes');
const prescriptionsRoutes = require('./routes/prescriptions.routes');
const {
  createCorsOptions,
  securityHeaders,
  createRateLimiter,
} = require('./middleware/security.middleware');

const app = express();
const PORT = process.env.PORT || 3000;

// The managed hosting proxy is the single trusted hop by default. Override only
// when the deployment topology is known and documented.
const proxyHops = Number.parseInt(process.env.TRUST_PROXY_HOPS || '1', 10);
if (!Number.isInteger(proxyHops) || proxyHops < 0 || proxyHops > 5) {
  throw new Error('TRUST_PROXY_HOPS must be an integer between 0 and 5');
}
app.set('trust proxy', proxyHops);
app.disable('x-powered-by');

app.use(securityHeaders);
app.use(cors(createCorsOptions()));
app.use('/api', createRateLimiter({
  windowMs: 60_000,
  max: Number.parseInt(process.env.API_RATE_LIMIT_PER_MINUTE || '120', 10),
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.get('/', (_req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  res.json({
    success: true,
    app: 'SEHATAK BACKEND',
    version: process.env.APP_VERSION || '1.0.0',
    status: 'running',
  });
});

app.get('/health', (_req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  res.status(200).json({
    success: true,
    status: 'healthy',
    service: 'sehatak-backend',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/firebase', firebaseRoutes);
app.use('/api/files', requireAuth, filesRoutes);
app.use('/api/lab-results', requireAuth, labResultsRoutes);
app.use('/api/prescriptions', requireAuth, prescriptionsRoutes);
app.use('/api/chats', requireAuth, chatRoutes);
app.use('/api/livekit', livekitRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'المسار غير موجود',
  });
});

app.use((error, _req, res, _next) => {
  if (error.code === 'CORS_ORIGIN_DENIED') {
    return res.status(403).json({ success: false, message: 'Origin is not allowed.' });
  }
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return res.status(400).json({ success: false, message: 'Invalid JSON body.' });
  }
  console.error('Request error:', error.code || error.name || 'unknown');
  return res.status(500).json({
    success: false,
    message: 'حدث خطأ في الخادم',
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('Sehatak backend listening on configured port');
});
