const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform',
});

const db = admin.firestore();

async function check() {
  const collections = ['doctors', 'products', 'labs', 'pharmacies', 'chats', 'users'];
  
  console.log('\n📊 Firestore Collections\n');
  for (const name of collections) {
    console.log(`📋 ${name}:`);
    const snapshot = await db.collection(name).limit(5).get();
    console.log(`   المستندات: ${snapshot.docs.length}`);
    snapshot.docs.forEach(doc => {
      console.log(`   ✅ ${doc.id}: ${JSON.stringify(doc.data()).substring(0, 100)}...`);
    });
    console.log('');
  }
}

check().then(() => process.exit(0));
