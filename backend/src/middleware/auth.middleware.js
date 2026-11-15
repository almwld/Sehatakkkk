const { getAuth } = require('../services/firebase.service');

/**
 * Verify Firebase ID tokens and reject revoked/disabled sessions.
 * Header: Authorization: Bearer <Firebase ID Token>
 */
async function requireAuth(req, res, next) {
  try {
    const authorization = req.headers.authorization || '';
    if (!authorization.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'المصادقة مطلوبة' });
    }

    const idToken = authorization.substring(7).trim();
    if (!idToken) {
      return res.status(401).json({ success: false, message: 'Firebase ID Token مفقود' });
    }

    const decodedToken = await getAuth().verifyIdToken(idToken, true);
    req.user = decodedToken;
    return next();
  } catch (error) {
    // Do not log the token or request headers.
    console.warn('Authentication rejected:', error.code || 'invalid-token');
    return res.status(401).json({
      success: false,
      message: 'رمز المصادقة غير صالح أو منتهي أو ملغى',
    });
  }
}

module.exports = { requireAuth };
