require('dotenv').config();

const express = require('express');
const cors = require('cors');

const filesRoutes = require('./routes/files.routes');

const app = express();

app.use(cors());

app.use(express.json({
  limit: '10mb',
}));

app.use('/api/files', filesRoutes);

app.get('/health', (req, res) => {
  res.json({
    success: true,
    service: 'Sehatak Backend',
    status: 'healthy',
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`
==================================================
🏥 SEHATAK BACKEND
==================================================
🚀 Server: http://localhost:${PORT}
☁️ Nextcloud: enabled
🔥 Firestore: ready
📞 LiveKit: ready
==================================================
`);
});
