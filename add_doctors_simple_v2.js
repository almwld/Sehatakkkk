const admin = require('firebase-admin');

// ✅ استخدم Application Default Credentials (من firebase login)
admin.initializeApp({
  projectId: 'sehatak-platform',
});

const db = admin.firestore();

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
  {
    name: 'د. محمد العلاي',
    specialty: 'أنف وأذن وحنجرة',
    rating: 4.6,
    reviewsCount: 89,
    consultationFee: 180,
    isAvailable: false,
    isOnline: false,
    experienceYears: 8,
    hospital: 'مستشفى الكويت',
    about: 'استشاري جراحة الأنف والأذن والحنجرة.',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor4.jpg',
  },
  {
    name: 'د. فاطمة صديقي',
    specialty: 'نساء وولادة',
    rating: 4.8,
    reviewsCount: 210,
    consultationFee: 160,
    isAvailable: true,
    isOnline: true,
    experienceYears: 14,
    hospital: 'المستشفى الجمهوري',
    about: 'استشارية أمراض النساء والولادة.',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor5.jpg',
  },
  {
    name: 'د. سليمان الحكيم',
    specialty: 'جلدية',
    rating: 4.5,
    reviewsCount: 145,
    consultationFee: 130,
    isAvailable: true,
    isOnline: false,
    experienceYears: 9,
    hospital: 'مركز الجلدية التخصصي',
    about: 'استشاري الأمراض الجلدية والتجميل.',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor6.jpg',
  },
];

async function add() {
  console.log('\n📦 إضافة الأطباء...\n');
  for (const d of doctors) {
    try {
      const ref = await db.collection('doctors').add(d);
      console.log(`✅ ${d.name} - ${ref.id}`);
    } catch (e) {
      console.log(`❌ ${d.name}: ${e.message}`);
    }
  }
  console.log('\n✅ تم إضافة الأطباء!');
}

add().then(() => process.exit(0));
