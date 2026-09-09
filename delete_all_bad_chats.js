const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();

async function deleteBadChats() {
  const snapshot = await db.collection('chats').get();
  let deleted = 0;
  let kept = 0;
  
  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (!data.participants || data.participants.length === 0) {
      await doc.ref.delete();
      console.log(`🗑️ تم حذف: ${doc.id}`);
      deleted++;
    } else {
      console.log(`✅ تم الاحتفاظ: ${doc.id} → ${data.participants.join(', ')}`);
      kept++;
    }
  }
  
  console.log(`\n📊 ملخص:`);
  console.log(`   🗑️ تم حذف: ${deleted} محادثة فاسدة`);
  console.log(`   ✅ تم الاحتفاظ: ${kept} محادثة صالحة`);
}

deleteBadChats().catch(console.error);
