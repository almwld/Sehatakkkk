const Reporter = require('./utils/test-reporter');
const { findRealFcmToken } = require('./utils/firebase-helper');

(async () => {
  const r = new Reporter('fcm-tokens');
  const uid = process.env.TEST_RECEIVER_UID;
  if (!uid) r.skip('Real FCM token audit', 'Set TEST_RECEIVER_UID; fake tokens are never treated as valid');
  else {
    try {
      const token = await findRealFcmToken(uid);
      if (!token) throw new Error('No real fcmToken in users/{uid}');
      r.pass('Real FCM token exists', `length=${token.length}`);
    } catch (e) { r.fail('Real FCM token exists', e); }
  }
  r.writeReport(); process.exit(r.print() ? 0 : 1);
})().catch(e => { console.error(e); process.exit(1); });
