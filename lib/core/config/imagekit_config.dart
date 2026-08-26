// ============================================================
// 📁 lib/core/config/imagekit_config.dart
// ☁️ ImageKit - فقط للصور الديناميكية (الأطباء، المستشفيات، إلخ)
// ============================================================

class ImageKitConfig {
  // ✅ عنوان URL الأساسي لـ ImageKit
  static const String baseUrl = 'https://ik.imagekit.io/fqcynk86c';

  // ✅ مجلدات الصور الديناميكية (ستعرض من ImageKit)
  static const String doctors = '$baseUrl/images/doctors';
  static const String hospitals = '$baseUrl/images/hospitals';
  static const String labs = '$baseUrl/images/labs';
  static const String medicines = '$baseUrl/images/medicines';
  static const String pharmacies = '$baseUrl/images/pharmacies';
  static const String posts = '$baseUrl/images/posts';
  static const String banners = '$baseUrl/images/banners';
  static const String delivery = '$baseUrl/images/delivery';

  // ✅ صور الأطباء
  static const String doctor1 = '$doctors/doctor_1.png';
  static const String doctor2 = '$doctors/doctor_2.png';
  static const String doctor3 = '$doctors/doctor_3.png';
  static const String doctor4 = '$doctors/doctor_4.png';
  static const String doctor5 = '$doctors/doctor_5.png';
  static const String doctor6 = '$doctors/doctor_6.png';

  // ✅ صور المستشفيات
  static const String hospital1 = '$hospitals/hospital_1.png';
  static const String hospital2 = '$hospitals/hospital_2.png';
  static const String hospital3 = '$hospitals/hospital_3.png';
  static const String hospital4 = '$hospitals/hospital_4.png';
  static const String hospital5 = '$hospitals/hospital_5.png';
  static const String hospital6 = '$hospitals/hospital_6.png';

  // ✅ صور المختبرات
  static const String lab1 = '$labs/lab_1.png';
  static const String lab2 = '$labs/lab_2.png';
  static const String lab3 = '$labs/lab_3.png';

  // ✅ صور الأدوية
  static const String medicine1 = '$medicines/medicine_1.png';
  static const String medicine2 = '$medicines/medicine_2.png';
  static const String medicine3 = '$medicines/medicine_3.png';
  static const String medicine4 = '$medicines/medicine_4.png';

  // ✅ صور الصيدليات
  static const String pharmacy1 = '$pharmacies/pharmacy_1.png';
  static const String pharmacy2 = '$pharmacies/pharmacy_2.png';
  static const String pharmacy3 = '$pharmacies/pharmacy_3.png';

  // ✅ صور المنشورات
  static const String morningWalk = '$posts/morning_walk.png';
  static const String immuneBoost = '$posts/immune_boost.png';
  static const String sleepTips = '$posts/sleep_tips.png';
  static const String skinCare = '$posts/skin_care.png';
  static const String nutritionTips = '$posts/nutrition_tips.png';

  // ✅ البانرات
  static const String banner1 = '$banners/banner_1.png';
  static const String banner2 = '$banners/banner_2.png';
  static const String banner3 = '$banners/banner_3.png';
  static const String banner4 = '$banners/banner_4.png';
  static const List<String> bannerList = [banner1, banner2, banner3, banner4];

  // ✅ صور التوصيل
  static const String delivery1 = '$delivery/delivery_1.png';
  static const String delivery2 = '$delivery/delivery_2.png';
  static const String delivery3 = '$delivery/delivery_3.png';
  static const String delivery4 = '$delivery/delivery_4.png';
}
