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
const tableName = process.argv[2] || 'doctors';

async function showTable() {
  console.log(`\n📊 جدول: ${tableName}`);
  console.log('══════════════════════════════════════════════════════════════════\n');
  
  try {
    const snapshot = await db.collection(tableName).limit(20).get();
    console.log(`📊 عدد المستندات: ${snapshot.docs.length}\n`);
    
    if (snapshot.docs.length === 0) {
      console.log('⚠️  لا توجد بيانات في هذا الجدول');
      return;
    }
    
    snapshot.docs.forEach((doc, i) => {
      const data = doc.data();
      console.log(`📄 المستند ${i + 1}:`);
      console.log(`   ID: ${doc.id}`);
      console.log(`   البيانات: ${JSON.stringify(data, null, 2)}`);
      console.log('');
    });
  } catch (e) {
    console.log(`❌ خطأ: ${e.message}`);
  }
}

showTable().then(() => process.exit(0));
