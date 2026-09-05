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

async function showDoctors() {
  console.log('\n👨‍⚕️  قائمة الأطباء');
  console.log('══════════════════════════════════════════════════════════════════\n');
  
  try {
    const snapshot = await db.collection('doctors').get();
    console.log(`📊 عدد الأطباء: ${snapshot.docs.length}\n`);
    
    if (snapshot.docs.length === 0) {
      console.log('⚠️  لا يوجد أطباء');
      return;
    }
    
    snapshot.docs.forEach((doc, i) => {
      const data = doc.data();
      console.log(`${i + 1}. ${data.name || 'بدون اسم'}`);
      console.log(`   🆔 ID: ${doc.id}`);
      console.log(`   📌 التخصص: ${data.specialty || 'غير محدد'}`);
      console.log(`   ⭐ التقييم: ${data.rating || 0}`);
      console.log(`   💰 السعر: ${data.consultationFee || 0} ر.ي`);
      console.log(`   📍 المستشفى: ${data.hospital || 'غير محدد'}`);
      console.log(`   🔵 متاح: ${data.isAvailable ? '✅ نعم' : '❌ لا'}`);
      console.log(`   🟢 متصل: ${data.isOnline ? '✅ نعم' : '❌ لا'}`);
      console.log('');
    });
  } catch (e) {
    console.log(`❌ خطأ: ${e.message}`);
  }
}

showDoctors().then(() => process.exit(0));
