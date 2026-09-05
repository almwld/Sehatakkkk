const admin = require('firebase-admin');

try {
  const serviceAccount = require('./service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (e) {
  console.error('❌ Error:', e.message);
  process.exit(1);
}

const db = admin.firestore();

async function showData() {
  const collections = ['doctors', 'users', 'chats', 'messages', 'calls', 'notifications'];
  
  console.log('\n📊 بيانات الجداول:\n');
  console.log('──────────────────────────────────────────────────');
  
  for (const name of collections) {
    try {
      const snapshot = await db.collection(name).limit(5).get();
      console.log(`\n📁 ${name}:`);
      console.log(`   📊 ${snapshot.docs.length} مستندات`);
      
      if (snapshot.docs.length > 0) {
        snapshot.docs.forEach((doc, i) => {
          const data = doc.data();
          console.log(`   📄 مستند ${i + 1}: ${doc.id}`);
          console.log(`      ${JSON.stringify(data).substring(0, 150)}...`);
        });
      }
    } catch (e) {
      console.log(`   ❌ خطأ: ${e.message}`);
    }
  }
  console.log('\n──────────────────────────────────────────────────');
}

showData().then(() => process.exit(0));
