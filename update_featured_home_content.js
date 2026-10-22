// Sehatak — تحديث صور المنتجات والمختبرات المميزة في Firestore.
// لا يحذف أي مستند؛ يستخدم merge:true ويحافظ على الحقول غير المذكورة.
// يحتاج service-account.json بصلاحية Firestore Admin داخل مجلد المشروع.

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const credentialPath = path.join(__dirname, 'service-account.json');
if (!fs.existsSync(credentialPath)) {
  console.error('ملف service-account.json غير موجود. ضعه محلياً ولا ترفعه إلى GitHub.');
  process.exit(1);
}

const serviceAccount = require(credentialPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'sehatak-platform',
});

const db = admin.firestore();
const imageBase = 'https://ik.imagekit.io/fqcynk86c/images';

const products = [
  { id: 'med_001', name: 'باراسيتامول 500 مجم', file: 1, imageId: '6a6e9b8d5c7cd75eb824fb25', imageSize: 40622 },
  { id: 'med_002', name: 'باراسيتامول 1 جرام', file: 2, imageId: '6a6e994a5c7cd75eb80be509', imageSize: 121706 },
  { id: 'med_003', name: 'باراسيتامول شراب للأطفال', file: 3, imageId: '6a6e9b825c7cd75eb8247423', imageSize: 40232 },
  { id: 'med_004', name: 'إيبوبروفين 200 مجم', file: 4, imageId: '6a6e9b6b5c7cd75eb823b12e', imageSize: 42484 },
  { id: 'med_005', name: 'إيبوبروفين 400 مجم', file: 5, imageId: '6ad57393ead997d09a3f40b0', imageSize: 41804 },
  { id: 'med_006', name: 'إيبوبروفين 600 مجم', file: 6, imageId: '6ad57393ead997d09a3f40dc', imageSize: 39170 },
  { id: 'med_007', name: 'نابروكسين 250 مجم', file: 7, imageId: '6ad57393ead997d09a3f40b3', imageSize: 41804 },
  { id: 'med_008', name: 'نابروكسين 500 مجم', file: 8, imageId: '6ad57393ead997d09a3f40d7', imageSize: 39170 },
  { id: 'med_009', name: 'ديكلوفيناك 50 مجم', file: 9, imageId: '6ad57393ead997d09a3f40c6', imageSize: 41804 },
  { id: 'med_010', name: 'ديكلوفيناك 100 مجم', file: 10, imageId: '6ad57393ead997d09a3f40cc', imageSize: 39170 },
];

const hours = (open, close) => ({
  saturday: { open, close },
  sunday: { open, close },
  monday: { open, close },
  tuesday: { open, close },
  wednesday: { open, close },
  thursday: { open, close },
  friday: { open: '14:00', close },
});

const labs = [
  {
    id: 'lab_001', name: 'مختبرات الرازي', nameEn: 'Al-Razi Laboratories', location: 'حدة، صنعاء',
    imageId: '6a6e9b625c7cd75eb8238861', imageSize: 275080,
    imageDimensions: { width: 480, height: 351 },
    phone: '+967 771234568', email: 'info@alrazilabs.ye',
    address: { street: 'شارع حدة', district: 'حدة', city: 'صنعاء', country: 'اليمن',
      coordinates: { latitude: 15.3694, longitude: 44.1910 } },
    workingHours: hours('07:00', '20:00'),
    services: ['فحص الدم الشامل', 'فحص السكر', 'فحص الكوليسترول', 'تحليل البول', 'تحليل البراز', 'فحص الحمل', 'فحص الغدة الدرقية', 'فحص الكلى والكبد'],
    rating: 4.8, reviewsCount: 156, testsCount: 45,
  },
  {
    id: 'lab_002', name: 'مختبرات العولقي', nameEn: 'Al-Awlaqi Laboratories', location: 'الحصبة، صنعاء',
    imageId: '6a6e9b815c7cd75eb82471e4', imageSize: 286621,
    imageDimensions: { width: 480, height: 310 },
    phone: '+967 771234569', email: 'info@alawlaqilabs.ye',
    address: { street: 'شارع الستين', district: 'الحصبة', city: 'صنعاء', country: 'اليمن',
      coordinates: { latitude: 15.3650, longitude: 44.1900 } },
    workingHours: hours('07:00', '21:00'),
    services: ['فحوصات شاملة', 'تحاليل الدم', 'الفحوصات الطبية', 'تحليل الهرمونات', 'فحص الفيتامينات', 'تحليل البكتيريا'],
    rating: 4.7, reviewsCount: 128, testsCount: 38,
  },
  {
    id: 'lab_003', name: 'مختبرات المأمون', nameEn: 'Al-Mamoon Laboratories', location: 'الصافية، صنعاء',
    imageId: '6a6e9bd15c7cd75eb827761f', imageSize: 266345,
    imageDimensions: { width: 480, height: 269 },
    phone: '+967 771234570', email: 'info@almamoonlabs.ye',
    address: { street: 'شارع الزبيري', district: 'الصافية', city: 'صنعاء', country: 'اليمن',
      coordinates: { latitude: 15.3700, longitude: 44.1920 } },
    workingHours: hours('08:00', '20:00'),
    services: ['فحص PCR', 'تحليل كورونا', 'فحوصات ما قبل الزواج', 'فحوصات الأمراض المعدية', 'تحليل الجينات', 'فحص الأمراض الوراثية'],
    rating: 4.6, reviewsCount: 98, testsCount: 42,
  },
];

async function updateProducts() {
  for (let offset = 0; offset < products.length; offset += 400) {
    const batch = db.batch();
    for (const product of products.slice(offset, offset + 400)) {
      const ref = db.collection('products').doc(product.id);
      const imageUrl = `${imageBase}/medicines/med_${product.file}.png`;
      batch.set(ref, {
        imageUrl,
        thumbnailUrl: `${imageUrl}?tr=w-200,h-200`,
        imageId: product.imageId,
        imageSize: product.imageSize,
        imageDimensions: { width: 1536, height: 1536 },
        imageSource: 'imagekit',
        isFeatured: true,
        isActive: true,
        isPublished: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
    await batch.commit();
  }
  console.log(`تم تحديث صور وبيانات ${products.length} منتجاً مميزاً.`);
}

async function updateLabs() {
  for (let offset = 0; offset < labs.length; offset += 400) {
    const batch = db.batch();
    for (const lab of labs.slice(offset, offset + 400)) {
      const imageUrl = `${imageBase}/labs/lab_${Number(lab.id.slice(-3))}.png`;
      const { id, ...data } = lab;
      batch.set(db.collection('labs').doc(id), {
        ...data,
        imageUrl,
        logoUrl: imageUrl,
        thumbnailUrl: `${imageUrl}?tr=w-200,h-200`,
        images: [imageUrl],
        imageSource: 'imagekit',
        isActive: true,
        isVerified: true,
        isFeatured: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
    await batch.commit();
  }
  console.log(`تم تحديث ${labs.length} مختبرات مميزة.`);
}

async function main() {
  await updateProducts();
  await updateLabs();
  console.log('اكتمل تحديث المحتوى المميز. لم تُحذف أي مستندات.');
}

main()
  .catch(error => {
    console.error('فشل تحديث المحتوى المميز:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await admin.app().delete();
  });
