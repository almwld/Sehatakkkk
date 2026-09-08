const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();

async function checkDoctors() {
  console.log('🔍 التحقق من الأطباء...\n');
  
  // الأطباء الموثقين (isVerified = true)
  const verified = await db.collection('doctors')
    .where('isVerified', '==', true)
    .get();
  
  console.log(`✅ الأطباء الموثقين: ${verified.docs.length}`);
  
  // الأطباء المتاحين (isAvailable = true)
  const available = await db.collection('doctors')
    .where('isAvailable', '==', true)
    .get();
  
  console.log(`✅ الأطباء المتاحين: ${available.docs.length}`);
  
  // عرض عينة
  console.log('\n📋 عينة من الأطباء:');
  verified.docs.slice(0, 5).forEach(doc => {
    const data = doc.data();
    console.log(`  - ${data.name}`);
    console.log(`    isVerified: ${data.isVerified}`);
    console.log(`    isAvailable: ${data.isAvailable}`);
    console.log(`    specialty: ${data.specialty}`);
  });
}

checkDoctors().catch(console.error);
