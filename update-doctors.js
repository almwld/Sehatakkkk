const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();

async function updateDoctors() {
  console.log('🔧 تحديث الأطباء...\n');
  
  const snapshot = await db.collection('doctors').get();
  console.log(`📊 عدد الأطباء: ${snapshot.docs.length}`);
  
  const batch = db.batch();
  let count = 0;
  
  snapshot.docs.forEach(doc => {
    const data = doc.data();
    
    // إضافة الحقول المفقودة
    const updates = {
      isVerified: data.isVerified ?? true,  // ✅ تعيين true إذا كان undefined
      isAvailable: data.isAvailable ?? true,
      isOnline: data.isOnline ?? false,
      verificationStatus: data.verificationStatus ?? 'approved'
    };
    
    batch.update(doc.ref, updates);
    count++;
    console.log(`  ✅ تم تحديث: ${data.name || doc.id}`);
  });
  
  await batch.commit();
  console.log(`\n✅ تم تحديث ${count} طبيب بنجاح!`);
}

updateDoctors().catch(console.error);
