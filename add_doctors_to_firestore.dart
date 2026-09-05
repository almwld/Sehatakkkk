import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  final doctors = [
    {
      'name': 'د. أحمد المولد',
      'specialty': 'باطنية',
      'rating': 4.9,
      'reviewsCount': 328,
      'consultationFee': 150,
      'isAvailable': true,
      'isOnline': true,
      'experienceYears': 15,
      'hospital': 'مستشفى 22 مايو',
      'about': 'استشاري باطنية وأمراض القلب، خبرة 15 سنة.',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor1.jpg',
    },
    {
      'name': 'د. خالد النخلاني',
      'specialty': 'قلبية',
      'rating': 4.8,
      'reviewsCount': 256,
      'consultationFee': 200,
      'isAvailable': true,
      'isOnline': true,
      'experienceYears': 12,
      'hospital': 'مستشفى آزال',
      'about': 'استشاري أمراض القلب والقسطرة.',
      'photoUrl': 'https://ik.imagekit.io/sehatak/doctors/doctor2.jpg',
    },
  ];

  for (final doctor in doctors) {
    await firestore.collection('doctors').add(doctor);
    print('✅ تم إضافة: ${doctor['name']}');
  }

  print('✅ تم إضافة جميع الأطباء!');
}
