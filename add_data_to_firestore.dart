import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('══════════════════════════════════════════════════════════════════');
  print('🔥 بدء إضافة البيانات إلى Firestore');
  print('══════════════════════════════════════════════════════════════════');
  print('');

  // ============================================================
  // 1️⃣ إضافة الأطباء
  // ============================================================
  print('📋 1️⃣ إضافة الأطباء...');
  print('──────────────────────────────────────────────────────────────────');

  final doctors = [
    {
      'name': 'د. أحمد المولد',
      'specialty': 'باطنية',
      'subspecialty': 'أمراض القلب',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor1.jpg',
      'rating': 4.9,
      'reviewsCount': 328,
      'consultationFee': 150,
      'isAvailable': true,
      'isOnline': true,
      'experienceYears': 15,
      'hospital': 'مستشفى 22 مايو',
      'about': 'استشاري باطنية وأمراض القلب، خبرة 15 سنة في المستشفيات الكبرى. حاصل على شهادة البورد العربي في الباطنية.',
      'isVerified': true,
      'isFeatured': true,
      'languages': ['العربية', 'الإنجليزية'],
      'services': ['استشارة طبية', 'متابعة الحالة', 'تقييم الأعراض'],
      'workingHours': {
        'السبت': '09:00 - 17:00',
        'الأحد': '09:00 - 17:00',
        'الإثنين': '09:00 - 17:00',
        'الثلاثاء': '09:00 - 17:00',
        'الأربعاء': '09:00 - 14:00',
        'الخميس': '09:00 - 14:00',
        'الجمعة': 'مغلق',
      },
      'education': [
        {'degree': 'بكالوريوس الطب والجراحة - جامعة صنعاء'},
        {'degree': 'ماجستير الباطنية - جامعة القاهرة'},
        {'degree': 'زمالة أمراض القلب - مستشفى كليفلاند'},
      ],
      'certifications': [
        {'name': 'البورد العربي في الباطنية'},
        {'name': 'شهادة ACLS المتقدمة'},
      ],
      'reviews': [
        {'user': 'مريض 1', 'rating': 5, 'comment': 'طبيب ممتاز وأخلاق عالية'},
        {'user': 'مريض 2', 'rating': 4, 'comment': 'خبرة كبيرة في مجال القلب'},
      ],
      'patientsCount': 450,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'د. خالد النخلاني',
      'specialty': 'قلبية',
      'subspecialty': 'قسطرة قلبية',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor2.jpg',
      'rating': 4.8,
      'reviewsCount': 256,
      'consultationFee': 200,
      'isAvailable': true,
      'isOnline': true,
      'experienceYears': 12,
      'hospital': 'مستشفى آزال',
      'about': 'استشاري أمراض القلب والقسطرة، حاصل على زمالة أوروبية في أمراض القلب التداخلية.',
      'isVerified': true,
      'isFeatured': true,
      'languages': ['العربية', 'الإنجليزية', 'الفرنسية'],
      'services': ['قسطرة قلبية', 'استشارة قلبية', 'متابعة ضغط الدم'],
      'workingHours': {
        'السبت': '10:00 - 18:00',
        'الأحد': '10:00 - 18:00',
        'الإثنين': '10:00 - 18:00',
        'الثلاثاء': '10:00 - 18:00',
        'الأربعاء': '10:00 - 15:00',
        'الخميس': '10:00 - 15:00',
        'الجمعة': 'مغلق',
      },
      'education': [
        {'degree': 'بكالوريوس الطب - جامعة صنعاء'},
        {'degree': 'دكتوراه أمراض القلب - جامعة لندن'},
        {'degree': 'زمالة القسطرة القلبية - ألمانيا'},
      ],
      'certifications': [
        {'name': 'الزمالة الأوروبية لأمراض القلب'},
        {'name': 'شهادة القسطرة التداخلية'},
      ],
      'reviews': [
        {'user': 'مريض 1', 'rating': 5, 'comment': 'أفضل دكتور قلب في اليمن'},
        {'user': 'مريض 2', 'rating': 4, 'comment': 'شرح الحالة بشكل ممتاز'},
      ],
      'patientsCount': 380,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'د. أسماء الهندي',
      'specialty': 'أطفال',
      'subspecialty': 'حديثي الولادة',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor3.jpg',
      'rating': 4.7,
      'reviewsCount': 189,
      'consultationFee': 120,
      'isAvailable': true,
      'isOnline': false,
      'experienceYears': 10,
      'hospital': 'مستشفى السبعين',
      'about': 'استشارية طب الأطفال وحديثي الولادة، خبيرة في تطور الطفل ورعاية الأطفال الخدج.',
      'isVerified': true,
      'isFeatured': false,
      'languages': ['العربية', 'الإنجليزية'],
      'services': ['فحص الأطفال', 'تطعيمات', 'متابعة النمو'],
      'workingHours': {
        'السبت': '08:00 - 16:00',
        'الأحد': '08:00 - 16:00',
        'الإثنين': '08:00 - 16:00',
        'الثلاثاء': '08:00 - 16:00',
        'الأربعاء': '08:00 - 13:00',
        'الخميس': '08:00 - 13:00',
        'الجمعة': 'مغلق',
      },
      'education': [
        {'degree': 'بكالوريوس الطب - جامعة صنعاء'},
        {'degree': 'ماجستير طب الأطفال - جامعة الأردن'},
        {'degree': 'زمالة حديثي الولادة - مستشفى الأطفال كندا'},
      ],
      'certifications': [
        {'name': 'البورد العربي في طب الأطفال'},
        {'name': 'شهادة NRP'},
      ],
      'reviews': [
        {'user': 'أم مريض', 'rating': 5, 'comment': 'تعامل رائع مع الأطفال'},
        {'user': 'أب مريض', 'rating': 4, 'comment': 'متابعة ممتازة للحالة'},
      ],
      'patientsCount': 280,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'د. محمد العلاي',
      'specialty': 'أنف وأذن وحنجرة',
      'subspecialty': 'جراحة الأنف',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor4.jpg',
      'rating': 4.6,
      'reviewsCount': 89,
      'consultationFee': 180,
      'isAvailable': false,
      'isOnline': false,
      'experienceYears': 8,
      'hospital': 'مستشفى الكويت',
      'about': 'استشاري جراحة الأنف والأذن والحنجرة، خبرة في عمليات تجميل الأنف والجراحات الدقيقة.',
      'isVerified': true,
      'isFeatured': false,
      'languages': ['العربية', 'الإنجليزية'],
      'services': ['جراحة الأنف', 'علاج اللوزتين', 'مناظير الأنف'],
      'workingHours': {
        'السبت': '09:00 - 17:00',
        'الأحد': '09:00 - 17:00',
        'الإثنين': '09:00 - 17:00',
        'الثلاثاء': '09:00 - 17:00',
        'الأربعاء': '09:00 - 14:00',
        'الخميس': '09:00 - 14:00',
        'الجمعة': 'مغلق',
      },
      'education': [
        {'degree': 'بكالوريوس الطب - جامعة صنعاء'},
        {'degree': 'ماجستير الأنف والأذن والحنجرة - جامعة القاهرة'},
      ],
      'certifications': [
        {'name': 'البورد العربي في الأنف والأذن والحنجرة'},
      ],
      'reviews': [
        {'user': 'مريض 1', 'rating': 5, 'comment': 'عملية ناجحة ومتابعة ممتازة'},
      ],
      'patientsCount': 150,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'د. فاطمة صديقي',
      'specialty': 'نساء وولادة',
      'subspecialty': 'عقم وأطفال أنابيب',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor5.jpg',
      'rating': 4.8,
      'reviewsCount': 210,
      'consultationFee': 160,
      'isAvailable': true,
      'isOnline': true,
      'experienceYears': 14,
      'hospital': 'المستشفى الجمهوري',
      'about': 'استشارية أمراض النساء والولادة، خبرة في عمليات المناظير وعلاج العقم.',
      'isVerified': true,
      'isFeatured': true,
      'languages': ['العربية', 'الإنجليزية', 'الفرنسية'],
      'services': ['ولادة طبيعية', 'ولادة قيصرية', 'علاج العقم', 'مناظير'],
      'workingHours': {
        'السبت': '09:00 - 17:00',
        'الأحد': '09:00 - 17:00',
        'الإثنين': '09:00 - 17:00',
        'الثلاثاء': '09:00 - 17:00',
        'الأربعاء': '09:00 - 14:00',
        'الخميس': '09:00 - 14:00',
        'الجمعة': 'مغلق',
      },
      'education': [
        {'degree': 'بكالوريوس الطب - جامعة صنعاء'},
        {'degree': 'ماجستير النساء والولادة - جامعة القاهرة'},
        {'degree': 'زمالة العقم وأطفال الأنابيب - الأردن'},
      ],
      'certifications': [
        {'name': 'البورد العربي في النساء والولادة'},
        {'name': 'شهادة علاج العقم'},
      ],
      'reviews': [
        {'user': 'مريضة 1', 'rating': 5, 'comment': 'ولادة طبيعية سهلة بفضل الله ثم بفضل الدكتورة'},
        {'user': 'مريضة 2', 'rating': 5, 'comment': 'أفضل دكتورة نساء في صنعاء'},
      ],
      'patientsCount': 520,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'د. سليمان الحكيم',
      'specialty': 'جلدية',
      'subspecialty': 'تجميل الجلد',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor6.jpg',
      'rating': 4.5,
      'reviewsCount': 145,
      'consultationFee': 130,
      'isAvailable': true,
      'isOnline': false,
      'experienceYears': 9,
      'hospital': 'مركز الجلدية التخصصي',
      'about': 'استشاري الأمراض الجلدية والتجميل، خبير في علاج حب الشباب وعلامات التقدم في السن.',
      'isVerified': true,
      'isFeatured': false,
      'languages': ['العربية', 'الإنجليزية'],
      'services': ['علاج حب الشباب', 'تقشير الجلد', 'علاج التصبغات'],
      'workingHours': {
        'السبت': '10:00 - 18:00',
        'الأحد': '10:00 - 18:00',
        'الإثنين': '10:00 - 18:00',
        'الثلاثاء': '10:00 - 18:00',
        'الأربعاء': '10:00 - 15:00',
        'الخميس': '10:00 - 15:00',
        'الجمعة': 'مغلق',
      },
      'education': [
        {'degree': 'بكالوريوس الطب - جامعة صنعاء'},
        {'degree': 'ماجستير الأمراض الجلدية - جامعة الأردن'},
      ],
      'certifications': [
        {'name': 'البورد العربي في الجلدية'},
      ],
      'reviews': [
        {'user': 'مريض 1', 'rating': 4, 'comment': 'علاج ممتاز لحب الشباب'},
      ],
      'patientsCount': 220,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  for (final doctor in doctors) {
    try {
      final docRef = await firestore.collection('doctors').add(doctor);
      print('  ✅ ${doctor['name']} - ${docRef.id}');
    } catch (e) {
      print('  ❌ فشل إضافة ${doctor['name']}: $e');
    }
  }

  print('');

  // ============================================================
  // 2️⃣ إضافة المستخدمين (إذا لزم الأمر)
  // ============================================================
  print('📋 2️⃣ إضافة المستخدمين...');
  print('──────────────────────────────────────────────────────────────────');

  // ✅ يمكن إضافة مستخدمين تجريبيين هنا
  print('  ℹ️ يمكن إضافة المستخدمين يدوياً من Firebase Console');

  print('');
  print('══════════════════════════════════════════════════════════════════');
  print('✅ ✅ ✅ تم إضافة جميع البيانات بنجاح! ✅ ✅ ✅');
  print('══════════════════════════════════════════════════════════════════');
  print('');
  print('📊 ملخص البيانات المضافة:');
  print('  👨‍⚕️ أطباء: ${doctors.length}');
  print('');
  print('🚀 الآن افتح التطبيق واختبر شاشة الأطباء!');
}
