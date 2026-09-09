/**
 * Sehatakkkk — Firestore bootstrap / seed
 *
 * IMPORTANT:
 * Firestore does not have SQL-style tables. A collection exists only when it
 * contains at least one document. This script therefore does NOT manufacture
 * fake patient/financial/medical transactions just to make empty collections
 * appear. It registers the complete schema list and seeds only safe public
 * catalog data plus verified facility records supplied for the app.
 *
 * Authentication:
 *   1) GOOGLE_APPLICATION_CREDENTIALS=/path/service-account.json node create_all_collections.js
 *   OR
 *   2) FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}' node create_all_collections.js
 *
 * Optional:
 *   FIREBASE_PROJECT_ID=your-project-id node create_all_collections.js
 */

const admin = require('firebase-admin');

function getCredential() {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    const json = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    return admin.credential.cert(json);
  }
  return admin.credential.applicationDefault();
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: getCredential(),
    projectId: process.env.FIREBASE_PROJECT_ID || undefined,
  });
}

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const now = FieldValue.serverTimestamp();

// Complete logical collection registry used by Sehatakkkk.
const COLLECTIONS = [
  // الصحة
  'vitals','health_stats','health_goals','health_records','medical_history','allergies','chronic_diseases',
  // الأدوية
  'medications','medication_reminders','medication_history',
  // العائلة
  'family_members','family_connections','family_appointments','family_health_records','family_medications',
  // المختبرات
  'labs','lab_tests','lab_categories','lab_bookings','lab_results','lab_packages','lab_equipment',
  // الصيدلية
  'pharmacies','products','product_inventory','product_categories','product_reviews','pharmacy_orders','pharmacy_staff',
  // المستشفيات
  'hospitals','hospital_reviews','hospital_departments','hospital_staff',
  // الطلبات
  'orders','order_items','invoices',
  // المدفوعات
  'payments','payment_methods','wallets','wallet_transactions','refunds',
  // المواعيد
  'appointments',
  // المحتوى
  'articles','videos','recipes','tips','diet_plans','stories','ads',
  // المجتمع
  'community_posts','comments','reactions','groups','group_members',
  // الطوارئ
  'emergency_contacts','ambulance_requests','ambulance_locations','emergency_alerts','sos_history',
  // التبرع
  'blood_donors','blood_requests','blood_banks','donation_history',
  // التأمين
  'insurance_plans','insurance_providers','insurance_claims','insurance_policies',
  // الباقات
  'packages','subscriptions','subscription_history','promo_codes','offers',
  // المفضلة
  'favorites','favorite_doctors','favorite_hospitals','favorite_products','favorite_articles',
  // السلة
  'cart_items',
  // المستخدمين
  'users','roles','user_permissions',
  // التفضيلات
  'user_preferences','language_preferences','theme_preferences','location_preferences',
  // الإشعارات
  'notifications','notification_preferences','push_tokens',
  // التقارير
  'reports','report_templates','report_history',
  // الطقس
  'weather_data','health_alerts','air_quality','pollution_data',
  // الذكاء الاصطناعي
  'ai_recommendations','health_insights','symptom_checker','symptom_history','diagnoses',
  // التحليلات
  'analytics','activity_logs','usage_stats',
  // الإعدادات
  'app_settings','notification_settings','regions','cities','specialties',
  // المواقع
  'locations','nearby_services','poi',
  // المصادقة
  'sessions','login_attempts','password_resets',
  // المكالمات
  'calls','call_history','call_settings',
  // المحادثات
  'chats','messages',
];

if (COLLECTIONS.length !== 98) {
  throw new Error(`Expected 98 collections, found ${COLLECTIONS.length}`);
}

// Public facility seed. Values intentionally avoid claiming live opening
// status or unverifiable phone/rating information as facts.
const HOSPITALS = [
  {
    id: 'sanaa_thawra_general',
    name: 'مستشفى الثورة العام بصنعاء',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'عام', ownership: 'حكومي',
    address: 'نهاية شارع الزبيري، صنعاء',
    emergency: true, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
  {
    id: 'sanaa_republican_teaching',
    name: 'هيئة مستشفى الجمهوري التعليمي',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'تعليمي', ownership: 'حكومي',
    address: 'شارع الزبيري، صنعاء',
    emergency: true, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
  {
    id: 'sanaa_koweit_university',
    name: 'مستشفى الكويت الجامعي',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'جامعي', ownership: 'حكومي',
    address: 'صنعاء',
    emergency: true, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
  {
    id: 'sanaa_sept70',
    name: 'مستشفى السبعين',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'عام', ownership: 'حكومي',
    address: 'صنعاء',
    emergency: true, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
  {
    id: 'sanaa_military_general',
    name: 'المستشفى العسكري العام',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'عام', ownership: 'حكومي',
    address: 'صنعاء',
    emergency: true, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
  {
    id: 'sanaa_48_model',
    name: 'مستشفى 48 النموذجي',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'نموذجي', ownership: 'حكومي',
    address: 'صنعاء',
    emergency: true, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
  {
    id: 'sanaa_police_model',
    name: 'مستشفى الشرطة النموذجي',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'نموذجي', ownership: 'حكومي',
    address: 'صنعاء',
    emergency: true, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
  {
    id: 'sanaa_palestine',
    name: 'مستشفى فلسطين',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    type: 'عام', ownership: 'خاص',
    address: 'صنعاء',
    emergency: false, isPublished: true, isActive: true,
    verificationStatus: 'pending', isVerified: false,
    source: 'manual_seed',
  },
];

const LABS = [
  {
    id: 'sanaa_aulaqi_main', name: 'مختبرات العولقي التخصصية - المركز الرئيسي',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'شارع الزبيري أمام الجمهوري', homeService: true,
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
  {
    id: 'sanaa_public_health_labs', name: 'المركز الوطني لمختبرات الصحة العامة المركزية',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'شارع الزراعة', homeService: false,
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
  {
    id: 'sanaa_newscan', name: 'نيوسكان التشخيصي أشعة ومختبرات',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'شارع الزبيري', homeService: false,
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
  {
    id: 'sanaa_samscan', name: 'سام سكان للأشعة التشخيصية',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'جولة عصر', homeService: false,
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
  {
    id: 'sanaa_beirut_modern', name: 'مختبرات بيروت الحديثة',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'جولة تعز', homeService: false,
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
  {
    id: 'sanaa_international_hada', name: 'المختبرات الدولية - فرع حدة',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'حدة، صنعاء', homeService: false,
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
  {
    id: 'sanaa_international_taiz', name: 'المختبرات الدولية الحديثة - شارع تعز',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'شارع تعز، صنعاء', homeService: false,
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
  {
    id: 'sanaa_althubhani', name: 'مختبرات الذبحاني الطبية التخصصية',
    city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن',
    address: 'جولة تعز - شارع تعز', homeService: false,
    phone: '+967776516024',
    isPublished: true, isActive: true, isVerified: false,
    verificationStatus: 'pending', source: 'manual_seed',
  },
];

const STATIC_DOCS = {
  roles: [
    { id: 'user', name: 'مستخدم', nameEn: 'User', isActive: true },
    { id: 'doctor', name: 'طبيب', nameEn: 'Doctor', isActive: true },
    { id: 'nurse', name: 'ممرض', nameEn: 'Nurse', isActive: true },
    { id: 'pharmacist', name: 'صيدلي', nameEn: 'Pharmacist', isActive: true },
    { id: 'lab', name: 'مختبر', nameEn: 'Laboratory', isActive: true },
    { id: 'admin', name: 'مدير', nameEn: 'Administrator', isActive: true },
  ],
  regions: [
    { id: 'amanat_al_asimah', name: 'أمانة العاصمة', country: 'اليمن', isActive: true },
  ],
  cities: [
    { id: 'sanaa', name: 'صنعاء', normalizedName: 'صنعاء', regionId: 'amanat_al_asimah', country: 'اليمن', isActive: true },
  ],
  specialties: [
    { id: 'general_medicine', name: 'طب عام', isActive: true },
    { id: 'internal_medicine', name: 'باطنية', isActive: true },
    { id: 'pediatrics', name: 'أطفال', isActive: true },
    { id: 'cardiology', name: 'قلب', isActive: true },
    { id: 'dermatology', name: 'جلدية', isActive: true },
    { id: 'dentistry', name: 'أسنان', isActive: true },
    { id: 'ophthalmology', name: 'عيون', isActive: true },
  ],
  lab_categories: [
    { id: 'hematology', name: 'أمراض الدم', isActive: true },
    { id: 'biochemistry', name: 'كيمياء حيوية', isActive: true },
    { id: 'microbiology', name: 'أحياء دقيقة', isActive: true },
    { id: 'hormones', name: 'هرمونات', isActive: true },
    { id: 'immunology', name: 'مناعة', isActive: true },
  ],
  hospital_departments: [
    { id: 'emergency', name: 'الطوارئ', isActive: true },
    { id: 'internal', name: 'الباطنية', isActive: true },
    { id: 'surgery', name: 'الجراحة', isActive: true },
    { id: 'pediatrics', name: 'الأطفال', isActive: true },
    { id: 'obstetrics', name: 'النساء والولادة', isActive: true },
  ],
  app_settings: [
    { id: 'production', appName: 'صحتك', appNameEn: 'Sehatak', country: 'اليمن', defaultCity: 'صنعاء', primaryColor: '#0A8F83', updatedAt: now },
  ],
  notification_settings: [
    { id: 'global', enabled: true, updatedAt: now },
  ],
};

async function setDocs(collection, docs) {
  const batch = db.batch();
  for (const item of docs) {
    const { id, ...data } = item;
    batch.set(db.collection(collection).doc(id), {
      ...data,
      createdAt: data.createdAt || now,
      updatedAt: now,
    }, { merge: true });
  }
  if (docs.length) await batch.commit();
}

async function main() {
  console.log(`Sehatakkkk Firestore bootstrap — ${COLLECTIONS.length} logical collections`);
  console.log(`Project: ${admin.app().options.projectId || 'default credentials project'}`);

  // Registry makes the complete schema auditable without polluting every
  // business collection with fake documents.
  await db.collection('_system').doc('collection_registry').set({
    project: 'Sehatakkkk',
    version: 1,
    collectionCount: COLLECTIONS.length,
    collections: COLLECTIONS,
    generatedAt: now,
  }, { merge: true });

  // Real public facility records used by the Home screen.
  await setDocs('hospitals', HOSPITALS);
  await setDocs('labs', LABS);

  // Safe static catalogs.
  for (const [collection, docs] of Object.entries(STATIC_DOCS)) {
    await setDocs(collection, docs);
  }

  console.log(`✓ hospitals: ${HOSPITALS.length}`);
  console.log(`✓ labs: ${LABS.length}`);
  console.log(`✓ static catalogs: ${Object.entries(STATIC_DOCS).reduce((n, [, d]) => n + d.length, 0)} documents`);
  console.log('✓ collection registry: 98 logical collections');
  console.log('NOTE: user/medical/financial/transaction collections are intentionally not filled with fake records.');
  console.log('DONE');
}

main().catch((error) => {
  console.error('SEED FAILED');
  console.error(error && error.stack ? error.stack : error);
  process.exitCode = 1;
});
