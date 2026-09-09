const admin = require('firebase-admin');

// Sehatakkkk Firestore bootstrap.
// The inventory supplied for the project contains 119 collection names (not 98).
// Firestore creates a collection only when a document is written. We therefore
// seed only safe/public catalog data and keep user, medical and financial
// collections free of fabricated records.
//
// Auth:
//   GOOGLE_APPLICATION_CREDENTIALS=/path/service-account.json node create_all_collections.js
//   FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account",...}' node create_all_collections.js

const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_JSON
  ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)
  : null;

admin.initializeApp({
  credential: serviceAccount
    ? admin.credential.cert(serviceAccount)
    : admin.credential.applicationDefault(),
  projectId: process.env.FIREBASE_PROJECT_ID || undefined,
});

const db = admin.firestore();
const now = admin.firestore.FieldValue.serverTimestamp();

const COLLECTIONS = [
  'vitals','health_stats','health_goals','health_records','medical_history','allergies','chronic_diseases',
  'medications','medication_reminders','medication_history',
  'family_members','family_connections','family_appointments','family_health_records','family_medications',
  'labs','lab_tests','lab_categories','lab_bookings','lab_results','lab_packages','lab_equipment',
  'pharmacies','products','product_inventory','product_categories','product_reviews','pharmacy_orders','pharmacy_staff',
  'hospitals','hospital_reviews','hospital_departments','hospital_staff',
  'orders','order_items','invoices',
  'payments','payment_methods','wallets','wallet_transactions','refunds',
  'appointments',
  'articles','videos','recipes','tips','diet_plans','stories','ads',
  'community_posts','comments','reactions','groups','group_members',
  'emergency_contacts','ambulance_requests','ambulance_locations','emergency_alerts','sos_history',
  'blood_donors','blood_requests','blood_banks','donation_history',
  'insurance_plans','insurance_providers','insurance_claims','insurance_policies',
  'packages','subscriptions','subscription_history','promo_codes','offers',
  'favorites','favorite_doctors','favorite_hospitals','favorite_products','favorite_articles',
  'cart_items',
  'users','roles','user_permissions',
  'user_preferences','language_preferences','theme_preferences','location_preferences',
  'notifications','notification_preferences','push_tokens',
  'reports','report_templates','report_history',
  'weather_data','health_alerts','air_quality','pollution_data',
  'ai_recommendations','health_insights','symptom_checker','symptom_history','diagnoses',
  'analytics','activity_logs','usage_stats',
  'app_settings','notification_settings','regions','cities','specialties',
  'locations','nearby_services','poi',
  'sessions','login_attempts','password_resets',
  'calls','call_history','call_settings',
  'chats','messages',
];

if (COLLECTIONS.length !== 119) {
  throw new Error(`Collection inventory mismatch: expected 119, got ${COLLECTIONS.length}`);
}

const hospitals = [
  ['sanaa_thawra_general','مستشفى الثورة العام بصنعاء','نهاية شارع الزبيري، صنعاء','حكومي','عام',true],
  ['sanaa_republican_teaching','هيئة مستشفى الجمهوري التعليمي','شارع الزبيري، صنعاء','حكومي','تعليمي',true],
  ['sanaa_koweit_university','مستشفى الكويت الجامعي','صنعاء','حكومي','جامعي',true],
  ['sanaa_sept70','مستشفى السبعين','صنعاء','حكومي','عام',true],
  ['sanaa_military_general','المستشفى العسكري العام','صنعاء','حكومي','عام',true],
  ['sanaa_48_model','مستشفى 48 النموذجي','صنعاء','حكومي','نموذجي',true],
  ['sanaa_police_model','مستشفى الشرطة النموذجي','صنعاء','حكومي','نموذجي',true],
  ['sanaa_palestine','مستشفى فلسطين','صنعاء','خاص','عام',false],
];

const labs = [
  ['sanaa_aulaqi_main','مختبرات العولقي التخصصية - المركز الرئيسي','شارع الزبيري أمام الجمهوري',true],
  ['sanaa_public_health_labs','المركز الوطني لمختبرات الصحة العامة المركزية','شارع الزراعة',false],
  ['sanaa_newscan','نيوسكان التشخيصي أشعة ومختبرات','شارع الزبيري',false],
  ['sanaa_samscan','سام سكان للأشعة التشخيصية','جولة عصر',false],
  ['sanaa_beirut_modern','مختبرات بيروت الحديثة','جولة تعز',false],
  ['sanaa_international_hada','المختبرات الدولية - فرع حدة','حدة، صنعاء',false],
  ['sanaa_international_taiz','المختبرات الدولية الحديثة - شارع تعز','شارع تعز، صنعاء',false],
  ['sanaa_althubhani','مختبرات الذبحاني الطبية التخصصية','جولة تعز - شارع تعز',false],
];

const catalogs = {
  roles: [
    ['user','مستخدم'],['doctor','طبيب'],['nurse','ممرض'],['midwife','قابلة'],
    ['physiotherapist','أخصائي علاج طبيعي'],['pharmacist','صيدلي'],['lab','مختبر'],['paramedic','مسعف'],
    ['delivery','توصيل'],['admin','مدير'],
  ],
  regions: [['amanat_al_asimah','أمانة العاصمة']],
  cities: [['sanaa','صنعاء']],
  specialties: [
    ['general_medicine','طب عام'],['internal_medicine','باطنية'],['pediatrics','أطفال'],
    ['cardiology','قلب'],['dermatology','جلدية'],['dentistry','أسنان'],['ophthalmology','عيون'],
  ],
  lab_categories: [
    ['hematology','أمراض الدم'],['biochemistry','كيمياء حيوية'],['microbiology','أحياء دقيقة'],
    ['hormones','هرمونات'],['immunology','مناعة'],
  ],
};

async function writeCollectionDocs(collection, docs) {
  const batch = db.batch();
  for (const [id, data] of docs) {
    batch.set(db.collection(collection).doc(id), {
      ...data,
      createdAt: now,
      updatedAt: now,
    }, { merge: true });
  }
  if (docs.length) await batch.commit();
}

async function main() {
  // Auditable registry: all 119 logical collections are listed here without
  // contaminating transactional collections with fake patient/order/payment data.
  await db.collection('_system').doc('collection_registry').set({
    project: 'Sehatakkkk',
    collectionCount: 119,
    collections: COLLECTIONS,
    generatedAt: now,
  }, { merge: true });

  await writeCollectionDocs('hospitals', hospitals.map(([id,name,address,ownership,type,emergency]) => [id, {
    name, city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن', address,
    ownership, type, emergency, isPublished: true, isActive: true,
    isVerified: false, verificationStatus: 'pending', source: 'manual_seed',
  }]));

  await writeCollectionDocs('labs', labs.map(([id,name,address,homeService]) => [id, {
    name, city: 'صنعاء', cityNormalized: 'صنعاء', country: 'اليمن', address,
    homeService, isPublished: true, isActive: true,
    isVerified: false, verificationStatus: 'pending', source: 'manual_seed',
  }]));

  for (const [collection, values] of Object.entries(catalogs)) {
    await writeCollectionDocs(collection, values.map(([id,name]) => [id, {
      name, isActive: true,
      ...(collection === 'cities' ? { normalizedName: name, country: 'اليمن', regionId: 'amanat_al_asimah' } : {}),
      ...(collection === 'regions' ? { country: 'اليمن' } : {}),
    }]));
  }

  await writeCollectionDocs('app_settings', [['production', {
    appName: 'صحتك', appNameEn: 'Sehatak', country: 'اليمن', defaultCity: 'صنعاء',
    primaryColor: '#0A8F83', secondaryColor: '#FFFFFF', backgroundColor: '#F4F6F7',
    textColor: '#263238', isProduction: true,
  }]]);

  console.log('========================================');
  console.log('Sehatakkkk Firestore bootstrap completed');
  console.log(`Logical collections: ${COLLECTIONS.length}`);
  console.log(`Hospitals seeded: ${hospitals.length}`);
  console.log(`Labs seeded: ${labs.length}`);
  console.log('User/medical/financial transaction collections were NOT filled with fake records.');
  console.log('========================================');
}

main().catch((err) => {
  console.error('FIRESTORE BOOTSTRAP FAILED');
  console.error(err.stack || err);
  process.exit(1);
});
