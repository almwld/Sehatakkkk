const admin = require('firebase-admin');

// ✅ الطريقة الصحيحة للتهيئة
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function check() {
  const collections = ['doctors', 'products', 'labs', 'pharmacies'];
  console.log('\n📊 Firestore Data\n');
  
  for (const name of collections) {
    console.log(`📋 ${name}:`);
    try {
      const snapshot = await db.collection(name).limit(10).get();
      console.log(`   📊 ${snapshot.docs.length} مستندات`);
      if (snapshot.docs.isEmpty) {
        console.log('   ⚠️ لا توجد بيانات');
      } else {
        snapshot.docs.forEach(doc => {
          const data = doc.data();
          console.log(`   ✅ ${doc.id}: ${JSON.stringify(data)}`);
        });
      }
    } catch (e) {
      console.log(`   ❌ خطأ: ${e.message}`);
    }
    console.log('');
  }
}

check().then(() => process.exit(0));
