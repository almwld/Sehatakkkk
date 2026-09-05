const admin = require('firebase-admin');

// ✅ تهيئة Firebase باستخدام service-account.json
try {
  const serviceAccount = require('./service-account.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('✅ Firebase initialized successfully');
} catch (e) {
  console.error('❌ Error:', e.message);
  console.error('📋 تأكد من وجود service-account.json في المجلد الحالي');
  process.exit(1);
}

const db = admin.firestore();

// ✅ بيانات الأطباء
const doctors = [
  {
    name: 'د. أحمد المولد',
    specialty: 'باطنية',
    subspecialty: 'أمراض القلب',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor1.jpg',
    rating: 4.9,
    reviewsCount: 328,
    consultationFee: 150,
    isAvailable: true,
    isOnline: true,
    experienceYears: 15,
    hospital: 'مستشفى 22 مايو',
    about: 'استشاري باطنية وأمراض القلب، خبرة 15 سنة.',
    isVerified: true,
    isFeatured: true,
    languages: ['العربية', 'الإنجليزية'],
    services: ['استشارة طبية', 'متابعة الحالة', 'تقييم الأعراض'],
    patientsCount: 450,
  },
  {
    name: 'د. خالد النخلاني',
    specialty: 'قلبية',
    subspecialty: 'قسطرة قلبية',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor2.jpg',
    rating: 4.8,
    reviewsCount: 256,
    consultationFee: 200,
    isAvailable: true,
    isOnline: true,
    experienceYears: 12,
    hospital: 'مستشفى آزال',
    about: 'استشاري أمراض القلب والقسطرة.',
    isVerified: true,
    isFeatured: true,
    languages: ['العربية', 'الإنجليزية', 'الفرنسية'],
    services: ['قسطرة قلبية', 'استشارة قلبية', 'متابعة ضغط الدم'],
    patientsCount: 380,
  },
  {
    name: 'د. أسماء الهندي',
    specialty: 'أطفال',
    subspecialty: 'حديثي الولادة',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor3.jpg',
    rating: 4.7,
    reviewsCount: 189,
    consultationFee: 120,
    isAvailable: true,
    isOnline: false,
    experienceYears: 10,
    hospital: 'مستشفى السبعين',
    about: 'استشارية طب الأطفال وحديثي الولادة.',
    isVerified: true,
    isFeatured: false,
    languages: ['العربية', 'الإنجليزية'],
    services: ['فحص الأطفال', 'تطعيمات', 'متابعة النمو'],
    patientsCount: 280,
  },
  {
    name: 'د. محمد العلاي',
    specialty: 'أنف وأذن وحنجرة',
    subspecialty: 'جراحة الأنف',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor4.jpg',
    rating: 4.6,
    reviewsCount: 89,
    consultationFee: 180,
    isAvailable: false,
    isOnline: false,
    experienceYears: 8,
    hospital: 'مستشفى الكويت',
    about: 'استشاري جراحة الأنف والأذن والحنجرة.',
    isVerified: true,
    isFeatured: false,
    languages: ['العربية', 'الإنجليزية'],
    services: ['جراحة الأنف', 'علاج اللوزتين', 'مناظير الأنف'],
    patientsCount: 150,
  },
  {
    name: 'د. فاطمة صديقي',
    specialty: 'نساء وولادة',
    subspecialty: 'عقم وأطفال أنابيب',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor5.jpg',
    rating: 4.8,
    reviewsCount: 210,
    consultationFee: 160,
    isAvailable: true,
    isOnline: true,
    experienceYears: 14,
    hospital: 'المستشفى الجمهوري',
    about: 'استشارية أمراض النساء والولادة.',
    isVerified: true,
    isFeatured: true,
    languages: ['العربية', 'الإنجليزية', 'الفرنسية'],
    services: ['ولادة طبيعية', 'ولادة قيصرية', 'علاج العقم', 'مناظير'],
    patientsCount: 520,
  },
  {
    name: 'د. سليمان الحكيم',
    specialty: 'جلدية',
    subspecialty: 'تجميل الجلد',
    photoUrl: 'https://ik.imagekit.io/sehatak/doctors/doctor6.jpg',
    rating: 4.5,
    reviewsCount: 145,
    consultationFee: 130,
    isAvailable: true,
    isOnline: false,
    experienceYears: 9,
    hospital: 'مركز الجلدية التخصصي',
    about: 'استشاري الأمراض الجلدية والتجميل.',
    isVerified: true,
    isFeatured: false,
    languages: ['العربية', 'الإنجليزية'],
    services: ['علاج حب الشباب', 'تقشير الجلد', 'علاج التصبغات'],
    patientsCount: 220,
  },
];

async function addDoctors() {
  console.log('');
  console.log('══════════════════════════════════════════════════════════════════');
  console.log('📦 إضافة الأطباء إلى Firestore');
  console.log('══════════════════════════════════════════════════════════════════');
  console.log('');

  for (const doctor of doctors) {
    try {
      const docRef = await db.collection('doctors').add(doctor);
      console.log(`  ✅ ${doctor.name} - ${docRef.id}`);
    } catch (e) {
      console.log(`  ❌ فشل إضافة ${doctor.name}: ${e.message}`);
    }
  }

  console.log('');
  console.log('══════════════════════════════════════════════════════════════════');
  console.log(`✅ تم إضافة ${doctors.length} أطباء بنجاح!`);
  console.log('══════════════════════════════════════════════════════════════════');
  console.log('');
  console.log('🚀 الآن افتح التطبيق واختبر شاشة الأطباء!');
}

addDoctors().then(() => process.exit(0));
