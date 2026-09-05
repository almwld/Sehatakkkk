const admin = require('firebase-admin');

// ✅ استخدام service-account.json
const serviceAccount = require('./service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform',
});

const db = admin.firestore();

async function show() {
  const cols = ['doctors', 'products', 'labs', 'pharmacies'];
  console.log('\n📊 Firestore Data\n');
  for (const c of cols) {
    console.log(`📋 ${c}:`);
    const snap = await db.collection(c).limit(5).get();
    console.log(`   📊 ${snap.docs.length} مستندات`);
    snap.docs.forEach(d => console.log(`   ✅ ${d.id}`));
    console.log('');
  }
}
show().then(() => process.exit(0));
