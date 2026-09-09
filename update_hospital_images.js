const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();
const imageBase = 'https://ik.imagekit.io/fqcynk86c';

// تحديث المستشفيات بالصور
async function updateHospitals() {
  console.log('🔄 جاري تحديث صور المستشفيات...\n');
  
  const snapshot = await db.collection('hospitals').get();
  console.log(`📊 عدد المستشفيات: ${snapshot.docs.length}\n`);
  
  const batch = db.batch();
  let count = 0;
  
  snapshot.docs.forEach((doc, index) => {
    const data = doc.data();
    // إضافة صورة افتراضية لكل مستشفى
    const imageNumber = (index % 6) + 1;
    const imageUrl = `${imageBase}/images/hospitals/hospital_${imageNumber}.png`;
    
    batch.update(doc.ref, {
      imageUrl: imageUrl,
      images: [imageUrl],
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`✅ ${data.name || doc.id} → ${imageUrl}`);
    count++;
  });
  
  await batch.commit();
  console.log(`\n✅ تم تحديث ${count} مستشفى بنجاح!`);
}

updateHospitals().catch(console.error);
