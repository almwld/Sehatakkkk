const Reporter = require('./utils/test-reporter');
const { db, createTempUser, deleteUser } = require('./utils/firebase-helper');

(async () => {
  const reporter = new Reporter('users');
  let user = null;
  try {
    user = await createTempUser();
    await db().collection('users').doc(user.uid).set({
      name: 'Node integration test',
      email: user.email,
      isTestAccount: true,
    }, { merge: true });
    const snapshot = await db().collection('users').doc(user.uid).get();
    if (!snapshot.exists) throw new Error('Firestore profile was not created');
    reporter.pass('Create Auth + Firestore user', user.uid);
  } catch (error) {
    reporter.fail('Create Auth + Firestore user', error);
  } finally {
    if (user) {
      try {
        await db().collection('users').doc(user.uid).delete();
        await deleteUser(user.uid);
        reporter.pass('Cleanup temporary user');
      } catch (error) {
        reporter.fail('Cleanup temporary user', error);
      }
    }
  }
  reporter.writeReport();
  process.exit(reporter.print() ? 0 : 1);
})().catch(error => { console.error(error); process.exit(1); });
