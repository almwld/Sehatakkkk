const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();
const imageBase = 'https://ik.imagekit.io/fqcynk86c/images/labs';

const labImageFor = (data, index) => {
  const name = String(data.name || '').trim();
  if (name.includes('الرازي')) return `${imageBase}/lab_1.png`;
  if (name.includes('العولقي')) return `${imageBase}/lab_2.png`;
  if (name.includes('المأمون')) return `${imageBase}/lab_3.png`;
  return `${imageBase}/lab_${(index % 3) + 1}.png`;
};

async function updateLabs() {
  console.log('Updating lab ImageKit URLs...');
  const snapshot = await db.collection('labs').get();
  console.log(`Labs found: ${snapshot.size}`);

  let updated = 0;
  for (let offset = 0; offset < snapshot.docs.length; offset += 450) {
    const batch = db.batch();
    const docs = snapshot.docs.slice(offset, offset + 450);
    docs.forEach((doc, localIndex) => {
      const data = doc.data();
      const imageUrl = labImageFor(data, offset + localIndex);
      batch.update(doc.ref, {
        imageUrl,
        images: [imageUrl],
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`${data.name || doc.id} -> ${imageUrl}`);
      updated++;
    });
    await batch.commit();
  }

  console.log(`Updated ${updated} lab image URLs.`);
}

updateLabs().catch((error) => {
  console.error('Failed to update lab image URLs:', error);
  process.exitCode = 1;
});
