const admin = require('firebase-admin');

// ✅ استخدام service-account.json
try {
  const serviceAccount = require('./service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'sehatak-platform',
  });
  console.log('✅ Firebase initialized');
} catch (e) {
  console.error('❌ Error:', e.message);
  process.exit(1);
}

const db = admin.firestore();

// ✅ بيانات الأطباء
const doctors = [
  {
    name: 'د. أحمد المولد',
    specialty: 'باطنية',
    rating: 4.9,
    reviewsCount: 328,
    consultationFee: 150,
    isAvailable: true,
    isOnline: true,
    experienceYears: 15,
    hospital: 'مستشفى 22 مايو',
    about: 'استشاري باطنية وأمراض القلب، خبرة 15 سنة.',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor1.jpg',
  },
  {
    name: 'د. خالد النخلاني',
    specialty: 'قلبية',
    rating: 4.8,
    reviewsCount: 256,
    consultationFee: 200,
    isAvailable: true,
    isOnline: true,
    experienceYears: 12,
    hospital: 'مستشفى آزال',
    about: 'استشاري أمراض القلب والقسطرة.',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor2.jpg',
  },
  {
    name: 'د. أسماء الهندي',
    specialty: 'أطفال',
    rating: 4.7,
    reviewsCount: 189,
    consultationFee: 120,
    isAvailable: true,
    isOnline: false,
    experienceYears: 10,
    hospital: 'مستشفى السبعين',
    about: 'استشارية طب الأطفال وحديثي الولادة.',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor3.jpg',
  },
];

async function addDoctors() {
  console.log('📦 إضافة الأطباء...');
  for (const doctor of doctors) {
    const docRef = await db.collection('doctors').add(doctor);
    console.log(`  ✅ ${doctor.name} - ${docRef.id}`);
  }
  console.log('✅ تم إضافة جميع الأطباء!');
}

addDoctors().then(() => process.exit(0));
