const express = require('express');
const { getFirestore } = require('../services/firebase.service');

const router = express.Router();

/**
 * GET /api/firebase/health
 * اختبار اتصال Backend بـ Firestore
 */
router.get('/health', async (req, res) => {
  try {
    const db = getFirestore();

    const testRef = db.collection('_system').doc('health');
    await testRef.set({
      service: 'sehatak-backend',
      status: 'healthy',
      updatedAt: new Date(),
    }, { merge: true });

    const snapshot = await testRef.get();

    return res.json({
      success: true,
      firebase: true,
      firestore: snapshot.exists,
      message: 'Firestore connection successful',
    });
  } catch (error) {
    console.error('========== FIREBASE ERROR ==========');
    console.error(error);
    console.error('====================================');

    return res.status(500).json({
      success: false,
      firebase: false,
      firestore: false,
      message: 'Firestore connection failed',
    });
  }
});

module.exports = router;
