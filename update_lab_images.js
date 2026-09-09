const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();
const imageBase = 'https://ik.imagekit.io/fqcynk86c';

async function updateLabs() {
  console.log('🔄 جاري تحديث صور المختبرات...\n');
  
  const snapshot = await db.collection('labs').get();
  console.log(`📊 عدد المختبرات: ${snapshot.docs.length}\n`);
  
  const batch = db.batch();
  let count = 0;
  
  snapshot.docs.forEach((doc, index) => {
    const data = doc.data();
    const imageNumber = (index % 8) + 1;
    const imageUrl = `${imageBase}/images/labs/lab_${imageNumber}.jpg`;
    
    batch.update(doc.ref, {
      imageUrl: imageUrl,
      images: [imageUrl],
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    
    console.log(`✅ ${data.name || doc.id} → ${imageUrl}`);
    count++;
  });
  
  await batch.commit();
  console.log(`\n✅ تم تحديث ${count} مختبر بنجاح!`);
}

updateLabs().catch(console.error);
