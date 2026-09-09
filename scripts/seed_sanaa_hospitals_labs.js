const admin = require('firebase-admin');

/**
 * Seed the production Firestore facilities used by HomeTab.
 *
 * Authentication:
 *   - Prefer Application Default Credentials (gcloud / CI workload identity).
 *   - Or set GOOGLE_APPLICATION_CREDENTIALS to a local service-account JSON.
 *
 * This script intentionally does not invent phone numbers, opening hours,
 * beds, or ratings when a reliable source is unavailable.
 */

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID || 'sehatak-platform',
  });
}

const db = admin.firestore();

const imageBase = 'https://ik.imagekit.io/fqcynk86c';

const hospitals = [
  {
    id: 'sanaa_thawra_general',
    name: 'مستشفى الثورة العام بصنعاء',
    city: 'صنعاء',
    location: 'صنعاء',
    address: 'نهاية شارع الزبيري، صنعاء',
    specialty: 'حكومي',
    type: 'عام',
    imageUrl: `${imageBase}/images/hospitals/hospital_1.png`,
    emergency: true,
    open: true,
    isActive: true,
    sourceNote: 'اسم المنشأة وموقعها العام متوافقان مع دليل صنعاء الطبي.',
  },
  {
    id: 'sanaa_republican_teaching',
    name: 'هيئة مستشفى الجمهوري التعليمي',
    city: 'صنعاء',
    location: 'صنعاء',
    address: 'شارع الزبيري، صنعاء',
    specialty: 'حكومي',
    type: 'تعليمي',
    imageUrl: `${imageBase}/images/hospitals/hospital_2.png`,
    emergency: true,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_koweit_university',
    name: 'مستشفى الكويت الجامعي',
    city: 'صنعاء',
    location: 'صنعاء',
    specialty: 'جامعي',
    type: 'جامعي',
    imageUrl: `${imageBase}/images/hospitals/hospital_3.png`,
    emergency: true,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_sept70',
    name: 'مستشفى السبعين',
    city: 'صنعاء',
    location: 'صنعاء',
    specialty: 'حكومي',
    type: 'عام',
    imageUrl: `${imageBase}/images/hospitals/hospital_4.png`,
    emergency: true,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_military_general',
    name: 'المستشفى العسكري العام',
    city: 'صنعاء',
    location: 'صنعاء',
    specialty: 'حكومي',
    type: 'عام',
    imageUrl: `${imageBase}/images/hospitals/hospital_5.png`,
    emergency: true,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_48_model',
    name: 'مستشفى 48 النموذجي',
    city: 'صنعاء',
    location: 'صنعاء',
    specialty: 'حكومي',
    type: 'نموذجي',
    imageUrl: `${imageBase}/images/hospitals/hospital_6.png`,
    emergency: true,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_police_model',
    name: 'مستشفى الشرطة النموذجي',
    city: 'صنعاء',
    location: 'صنعاء',
    specialty: 'حكومي',
    type: 'نموذجي',
    imageUrl: `${imageBase}/images/hospitals/hospital_1.png`,
    emergency: true,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_palestine',
    name: 'مستشفى فلسطين',
    city: 'صنعاء',
    location: 'صنعاء',
    specialty: 'خاص',
    type: 'عام',
    imageUrl: `${imageBase}/images/hospitals/hospital_2.png`,
    emergency: false,
    open: true,
    isActive: true,
  },
];

const labs = [
  {
    id: 'sanaa_aulaqi_main',
    name: 'مختبرات العولقي التخصصية - المركز الرئيسي',
    city: 'صنعاء',
    location: 'شارع الزبيري - أمام المستشفى الجمهوري',
    address: 'صنعاء - شارع الزبيري - أمام المستشفى الجمهوري',
    imageUrl: `${imageBase}/images/labs/lab_1.jpg`,
    specialties: ['تحاليل عامة', 'هرمونات', 'فيتامينات', 'ميكروبيولوجي'],
    homeService: true,
    open: true,
    isActive: true,
    phone: '00967-1-211702',
  },
  {
    id: 'sanaa_public_health_labs',
    name: 'المركز الوطني لمختبرات الصحة العامة المركزية',
    city: 'صنعاء',
    location: 'شارع الزراعة - أمام المعهد',
    address: 'صنعاء - شارع الزراعة - أمام المعهد',
    imageUrl: `${imageBase}/images/labs/lab_2.jpg`,
    specialties: ['تحاليل عامة', 'ميكروبيولوجي', 'جينية'],
    homeService: false,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_newscan',
    name: 'نيوسكان التشخيصي أشعة ومختبرات',
    city: 'صنعاء',
    location: 'شارع الزبيري',
    address: 'صنعاء - شارع الزبيري',
    imageUrl: `${imageBase}/images/labs/lab_3.jpg`,
    specialties: ['أشعة', 'تحاليل عامة'],
    homeService: false,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_samscan',
    name: 'سام سكان للأشعة التشخيصية',
    city: 'صنعاء',
    location: 'جولة عصر',
    address: 'صنعاء - جولة عصر',
    imageUrl: `${imageBase}/images/labs/lab_4.jpg`,
    specialties: ['أشعة'],
    homeService: false,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_beirut_modern',
    name: 'مختبرات بيروت الحديثة',
    city: 'صنعاء',
    location: 'جولة تعز',
    address: 'صنعاء - جولة تعز - جوار مركز المأمون',
    imageUrl: `${imageBase}/images/labs/lab_5.jpg`,
    specialties: ['تحاليل عامة', 'هرمونات', 'فيتامينات'],
    homeService: false,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_international_hada',
    name: 'المختبرات الدولية - فرع حدة',
    city: 'صنعاء',
    location: 'شارع حدة - جولة ريماس',
    address: 'صنعاء - شارع حدة - جولة ريماس',
    imageUrl: `${imageBase}/images/labs/lab_6.jpg`,
    specialties: ['تحاليل عامة', 'هرمونات'],
    homeService: false,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_international_taiz',
    name: 'المختبرات الدولية الحديثة - شارع تعز',
    city: 'صنعاء',
    location: 'شارع تعز',
    address: 'صنعاء - شارع تعز',
    imageUrl: `${imageBase}/images/labs/lab_7.jpg`,
    specialties: ['تحاليل عامة', 'ميكروبيولوجي'],
    homeService: false,
    open: true,
    isActive: true,
  },
  {
    id: 'sanaa_althubhani',
    name: 'مختبرات الذبحاني الطبية التخصصية',
    city: 'صنعاء',
    location: 'جولة تعز - شارع تعز',
    address: 'صنعاء - جولة تعز - شارع تعز',
    imageUrl: `${imageBase}/images/labs/lab_8.jpg`,
    specialties: ['تحاليل عامة', 'هرمونات', 'فيتامينات', 'ميكروبيولوجي'],
    homeService: false,
    open: true,
    isActive: true,
    phone: '+967776516024',
  },
];

async function upsert(collection, records) {
  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  for (const record of records) {
    const { id, ...data } = record;
    const ref = db.collection(collection).doc(id);
    batch.set(
      ref,
      {
        ...data,
        cityNormalized: 'صنعاء',
        updatedAt: now,
        createdAt: now,
      },
      { merge: true },
    );
  }

  await batch.commit();
  console.log(`Upserted ${records.length} records into ${collection}`);
}

async function main() {
  await upsert('hospitals', hospitals);
  await upsert('labs', labs);

  const [hospitalSnap, labSnap] = await Promise.all([
    db.collection('hospitals').where('cityNormalized', '==', 'صنعاء').get(),
    db.collection('labs').where('cityNormalized', '==', 'صنعاء').get(),
  ]);

  console.log(`Verified ${hospitalSnap.size} Sana'a hospitals.`);
  console.log(`Verified ${labSnap.size} Sana'a labs.`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
