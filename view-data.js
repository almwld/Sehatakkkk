const admin = require('firebase-admin');

// استخدام مفتاح الخدمة
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform'
});

const db = admin.firestore();

async function viewData() {
  console.log('📊 عرض بيانات Firestore\n');
  console.log('=' .repeat(50));
  
  // 1. عرض الأطباء
  console.log('\n👨‍⚕️ الأطباء:');
  const doctors = await db.collection('doctors').limit(20).get();
  if (doctors.empty) {
    console.log('  ❌ لا يوجد أطباء');
  } else {
    console.log(`  ✅ عدد الأطباء: ${doctors.docs.length}`);
    doctors.docs.forEach(d => {
      const data = d.data();
      console.log(`  - ${data.name || 'بدون اسم'}`);
      console.log(`    isVerified: ${data.isVerified}`);
      console.log(`    isAvailable: ${data.isAvailable}`);
      console.log(`    specialty: ${data.specialty || 'غير محدد'}`);
    });
  }
  
  // 2. عرض المحادثات
  console.log('\n💬 المحادثات:');
  const chats = await db.collection('chats').limit(20).get();
  if (chats.empty) {
    console.log('  ❌ لا يوجد محادثات');
  } else {
    console.log(`  ✅ عدد المحادثات: ${chats.docs.length}`);
    chats.docs.forEach(d => {
      const data = d.data();
      console.log(`  - ${d.id}`);
      console.log(`    participants: ${data.participants?.join(', ')}`);
      console.log(`    lastMessage: ${data.lastMessage || 'لا توجد رسائل'}`);
    });
  }
  
  // 3. عرض المنتجات
  console.log('\n🛒 المنتجات:');
  const products = await db.collection('products').limit(20).get();
  if (products.empty) {
    console.log('  ❌ لا يوجد منتجات');
  } else {
    console.log(`  ✅ عدد المنتجات: ${products.docs.length}`);
    products.docs.forEach(d => {
      const data = d.data();
      console.log(`  - ${data.name || 'بدون اسم'}`);
      console.log(`    price: ${data.price}`);
    });
  }
  
  // 4. عرض المختبرات
  console.log('\n🧪 المختبرات:');
  const labs = await db.collection('labs').limit(20).get();
  if (labs.empty) {
    console.log('  ❌ لا يوجد مختبرات');
  } else {
    console.log(`  ✅ عدد المختبرات: ${labs.docs.length}`);
    labs.docs.forEach(d => {
      const data = d.data();
      console.log(`  - ${data.name || 'بدون اسم'}`);
    });
  }
  
  console.log('\n' + '=' .repeat(50));
  console.log('✅ تم عرض البيانات بنجاح');
}

viewData().catch(err => {
  console.error('❌ خطأ:', err.message);
  console.error('تفاصيل:', err);
});
