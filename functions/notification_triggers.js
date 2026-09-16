const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

module.exports = {
  ...require('./chat_notifications'),
  revokeAllSessions: onCall(async (request) => {
    if (!request.auth || !request.auth.uid) {
      throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
    }
    await admin.auth().revokeRefreshTokens(request.auth.uid);
    return {success: true, revokedAt: Date.now()};
  }),
  deleteMyAccount: onCall(async (request) => {
    if (!request.auth || !request.auth.uid) {
      throw new HttpsError('unauthenticated', 'يجب تسجيل الدخول أولاً');
    }
    const uid = request.auth.uid;
    await admin.auth().deleteUser(uid);
    await admin.firestore().collection('users').doc(uid).delete();
    return {success: true};
  }),
};
