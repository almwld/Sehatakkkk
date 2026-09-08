const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();

async function checkUser() {
  // عرض المستخدمين
  const users = await db.collection('users').limit(5).get();
  console.log('👤 المستخدمين:');
  users.docs.forEach(doc => {
    console.log(`  - ${doc.id}: ${doc.data().role || 'مستخدم'}`);
  });
}

checkUser().catch(console.error);
