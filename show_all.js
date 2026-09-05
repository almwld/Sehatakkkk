const admin = require('firebase-admin');

try {
  const serviceAccount = require('./service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('✅ Firebase initialized\n');
} catch (e) {
  console.error('❌ Error:', e.message);
  process.exit(1);
}

const db = admin.firestore();

async function showAll() {
  // ✅ قائمة الجداول المطلوبة
  const collections = [
    'doctors', 'users', 'chats', 'messages', 
    'calls', 'notifications', 'appointments',
    'orders', 'payments', 'pharmacies', 'labs',
    'hospitals', 'transactions', 'wallets',
    'blood_donors', 'stories', 'conversations'
  ];

  console.log('══════════════════════════════════════════════════════════════════');
  console.log('📊  Firestore Collections & Data');
  console.log('══════════════════════════════════════════════════════════════════\n');

  let totalDocs = 0;

  for (const name of collections) {
    try {
      const snapshot = await db.collection(name).limit(10).get();
      const count = snapshot.docs.length;
      totalDocs += count;
      
      console.log(`📁 ${name}:`);
      console.log(`   📊 ${count} مستندات`);
      
      if (count > 0) {
        console.log('   📄 أول مستند:');
        const doc = snapshot.docs[0];
        const data = doc.data();
        console.log(`      ID: ${doc.id}`);
        console.log(`      البيانات: ${JSON.stringify(data, null, 2).substring(0, 200)}...`);
      }
      console.log('');
    } catch (e) {
      console.log(`   ❌ خطأ: ${e.message}\n`);
    }
  }

  console.log('──────────────────────────────────────────────────────────────────');
  console.log(`📊 إجمالي المستندات: ${totalDocs}`);
  console.log('──────────────────────────────────────────────────────────────────');
}

showAll().then(() => process.exit(0));
