const { getAuth } = require('../services/firebase.service');

/**
 * التحقق من Firebase ID Token
 *
 * Header:
 * Authorization: Bearer <Firebase ID Token>
 *
 * بعد نجاح التحقق:
 * req.user = decodedToken
 */
async function requireAuth(req, res, next) {
  try {
    const authorization = req.headers.authorization || '';

    if (!authorization.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'المصادقة مطلوبة',
      });
    }

    const idToken = authorization.substring(7).trim();

    if (!idToken) {
      return res.status(401).json({
        success: false,
        message: 'Firebase ID Token مفقود',
      });
    }

    const decodedToken = await getAuth().verifyIdToken(idToken);

    req.user = decodedToken;

    return next();
  } catch (error) {
    console.error('Authentication error:', error.code || error.message);

    return res.status(401).json({
      success: false,
      message: 'رمز المصادقة غير صالح أو منتهي',
    });
  }
}

module.exports = {
  requireAuth,
};
