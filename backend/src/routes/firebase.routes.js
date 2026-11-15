const express = require('express');
const { getFirestore } = require('../services/firebase.service');

const router = express.Router();

/**
 * Read-only dependency health check. Public health probes must not create or
 * mutate Firestore documents on every unauthenticated request.
 */
router.get('/health', async (_req, res) => {
  try {
    await getFirestore().collection('_system').limit(1).get();
    return res.json({
      success: true,
      firebase: true,
      firestore: true,
      message: 'Firestore connection successful',
    });
  } catch (error) {
    console.error('Firestore health check failed:', error.code || error.name || 'unknown');
    return res.status(503).json({
      success: false,
      firebase: false,
      firestore: false,
      message: 'Firestore health check unavailable',
    });
  }
});

module.exports = router;
