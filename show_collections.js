const admin = require('firebase-admin');

try {
  const serviceAccount = require('./service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('✅ Firebase initialized');
} catch (e) {
  console.error('❌ Error:', e.message);
  process.exit(1);
}

const db = admin.firestore();

async function listCollections() {
  console.log('\n📊 Firestore Collections:\n');
  console.log('──────────────────────────────────────────────────');
  
  const collections = await db.listCollections();
  
  if (collections.length === 0) {
    console.log('⚠️  لا توجد جداول (Collections)');
  } else {
    console.log(`📌 إجمالي الجداول: ${collections.length}\n`);
    for (const collection of collections) {
      const snapshot = await collection.limit(1).get();
      const count = snapshot.docs.length;
      console.log(`  📁 ${collection.id} - ${count > 0 ? '✅ يوجد بيانات' : '⚠️  فارغ'}`);
    }
  }
  console.log('\n──────────────────────────────────────────────────');
}

listCollections().then(() => process.exit(0));
