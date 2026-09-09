const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID || 'sehatak-platform',
  });
}

const db = admin.firestore();
const imageBase = 'https://ik.imagekit.io/fqcynk86c';

const hospitals = [
  ['sanaa_thawra_general', 'مستشفى الثورة العام بصنعاء', 'نهاية شارع الزبيري، صنعاء', 'حكومي', 'عام', 'hospital_1.png', true],
  ['sanaa_republican_teaching', 'هيئة مستشفى الجمهوري التعليمي', 'شارع الزبيري، صنعاء', 'حكومي', 'تعليمي', 'hospital_2.png', true],
  ['sanaa_koweit_university', 'مستشفى الكويت الجامعي', 'صنعاء', 'جامعي', 'جامعي', 'hospital_3.png', true],
  ['sanaa_sept70', 'مستشفى السبعين', 'صنعاء', 'حكومي', 'عام', 'hospital_4.png', true],
  ['sanaa_military_general', 'المستشفى العسكري العام', 'صنعاء', 'حكومي', 'عام', 'hospital_5.png', true],
  ['sanaa_48_model', 'مستشفى 48 النموذجي', 'صنعاء', 'حكومي', 'نموذجي', 'hospital_6.png', true],
  ['sanaa_police_model', 'مستشفى الشرطة النموذجي', 'صنعاء', 'حكومي', 'نموذجي', 'hospital_1.png', true],
  ['sanaa_palestine', 'مستشفى فلسطين', 'صنعاء', 'خاص', 'عام', 'hospital_2.png', false],
].map(([id, name, address, specialty, type, image, emergency]) => ({
  id, name, city: 'صنعاء', cityNormalized: 'صنعاء', location: 'صنعاء', address, specialty, type,
  imageUrl: `${imageBase}/images/hospitals/${image}`, emergency, isActive: true,
}));

const labs = [
  ['sanaa_aulaqi_main', 'مختبرات العولقي التخصصية - المركز الرئيسي', 'شارع الزبيري - أمام المستشفى الجمهوري', 'lab_1.jpg', true, '00967-1-211702'],
  ['sanaa_public_health_labs', 'المركز الوطني لمختبرات الصحة العامة المركزية', 'شارع الزراعة - أمام المعهد', 'lab_2.jpg', false, null],
  ['sanaa_newscan', 'نيوسكان التشخيصي أشعة ومختبرات', 'شارع الزبيري', 'lab_3.jpg', false, null],
  ['sanaa_samscan', 'سام سكان للأشعة التشخيصية', 'جولة عصر', 'lab_4.jpg', false, null],
  ['sanaa_beirut_modern', 'مختبرات بيروت الحديثة', 'جولة تعز - جوار مركز المأمون', 'lab_5.jpg', false, null],
  ['sanaa_international_hada', 'المختبرات الدولية - فرع حدة', 'شارع حدة - جولة ريماس', 'lab_6.jpg', false, null],
  ['sanaa_international_taiz', 'المختبرات الدولية الحديثة - شارع تعز', 'شارع تعز', 'lab_7.jpg', false, null],
  ['sanaa_althubhani', 'مختبرات الذبحاني الطبية التخصصية', 'جولة تعز - شارع تعز', 'lab_8.jpg', false, '+967776516024'],
].map(([id, name, address, image, homeService, phone]) => ({
  id, name, city: 'صنعاء', cityNormalized: 'صنعاء', location: address, address,
  imageUrl: `${imageBase}/images/labs/${image}`,
  homeService, isActive: true, ...(phone ? { phone } : {}),
}));

async function upsert(collection, records) {
  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();
  for (const { id, ...data } of records) {
    batch.set(db.collection(collection).doc(id), { ...data, updatedAt: now, createdAt: now }, { merge: true });
  }
  await batch.commit();
  console.log(`Upserted ${records.length} records into ${collection}`);
}

async function main() {
  await upsert('hospitals', hospitals);
  await upsert('labs', labs);
  const [h, l] = await Promise.all([
    db.collection('hospitals').where('cityNormalized', '==', 'صنعاء').get(),
    db.collection('labs').where('cityNormalized', '==', 'صنعاء').get(),
  ]);
  console.log(`Verified ${h.size} Sana'a hospitals and ${l.size} Sana'a labs in Firestore.`);
}

main().then(() => process.exit(0)).catch((error) => { console.error(error); process.exit(1); });
