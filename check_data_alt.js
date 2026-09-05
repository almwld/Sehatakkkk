const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount = require('./service-account.json');

// ✅ تهيئة باستخدام Firebase Admin SDK v11+
const app = initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore(app);

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
