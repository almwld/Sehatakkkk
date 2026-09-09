const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();

async function deleteBadChats() {
  const badChatIds = ['94gaOiHoqCDVIqi1J8Ng', '9GmI8Srnluae9KvZ6yZW'];
  
  for (const id of badChatIds) {
    try {
      await db.collection('chats').doc(id).delete();
      console.log(`✅ تم حذف المحادثة: ${id}`);
    } catch (error) {
      console.error(`❌ فشل حذف ${id}:`, error.message);
    }
  }
}

deleteBadChats().catch(console.error);
