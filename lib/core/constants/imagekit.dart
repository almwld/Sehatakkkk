class ImageKit {
  // ✅ الرابط الأساسي لـ ImageKit
  static const String base = "https://ik.imagekit.io/fqcynk86c";
  
  // ✅ المجلدات
  static const String imagesBase = "$base/images";
  static const String assetsBase = "$base/assets";
  
  // ✅ دوال مساعدة لبناء الروابط
  static String doctor(String name) => "$imagesBase/doctors/$name";
  static String hospital(String name) => "$imagesBase/hospitals/$name";
  static String pharmacy(String name) => "$imagesBase/pharmacies/$name";
  static String lab(String name) => "$imagesBase/labs/$name";
  static String medicine(String name) => "$imagesBase/medicines/$name";
  static String banner(String name) => "$imagesBase/banners/$name";
  static String icon(String name) => "$imagesBase/icons/$name";
  
  // ✅ قائمة البانرات (4 صور)
  static List<String> get bannerList => [
    banner("banner_1.png"),
    banner("banner_2.png"),
    banner("banner_3.png"),
    banner("banner_4.png"),
  ];
  
  // ✅ روابط ثابتة للصور - الأطباء
  static String get doctor1 => doctor("doctor_1.png");
  static String get doctor2 => doctor("doctor_2.png");
  static String get doctor3 => doctor("doctor_3.png");
  static String get doctor4 => doctor("doctor_4.png");
  static String get doctor5 => doctor("doctor_5.png");
  
  // ✅ روابط ثابتة للصور - المستشفيات
  static String get hospital1 => hospital("hospital_1.png");
  static String get hospital2 => hospital("hospital_2.png");
  static String get hospital3 => hospital("hospital_3.png");
  static String get hospital4 => hospital("hospital_4.png");
  static String get hospital5 => hospital("hospital_5.png");
  static String get hospital6 => hospital("hospital_6.png");
  
  // ✅ روابط ثابتة للصور - المختبرات
  static String get lab1 => lab("lab_1.png");
  static String get lab2 => lab("lab_2.png");
  static String get lab3 => lab("lab_3.png");
  
  // ✅ روابط ثابتة للصور - الصيدليات
  static String get pharmacy1 => pharmacy("pharmacy_1.png");
  static String get pharmacy2 => pharmacy("pharmacy_2.png");
  static String get pharmacy3 => pharmacy("pharmacy_3.png");
  
  // ✅ روابط ثابتة للصور - الأدوية
  static String get medicine1 => medicine("medicine_1.png");
  static String get medicine2 => medicine("medicine_2.png");
  static String get medicine3 => medicine("medicine_3.png");
  static String get medicine4 => medicine("medicine_4.png");
  
  // ✅ روابط ثابتة للصور - المقالات
  static String get morningWalk => "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop";
  static String get immuneBoost => "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=300&fit=crop";
  static String get sleepTips => "https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=400&h=300&fit=crop";
  static String get skinCare => "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=300&fit=crop";
  static String get nutritionTips => "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop";
  
  // ✅ أيقونات SVG
  static String get pharmacyIcon => "$assetsBase/svg/pharmacy.svg";
  static String get emergencyIcon => "$assetsBase/svg/emergency.svg";
  static String get homeMedical => "$assetsBase/svg/home_medical.svg";
  static String get donateBlood => "$assetsBase/svg/donate_blood.svg";
  static String get maleDoctorIcon => "$assetsBase/svg/male_doctor.svg";
  static String get medicalIcon => "$assetsBase/svg/medical.svg";
  static String get notificationsIcon => "$assetsBase/svg/notifications.svg";
  static String get placeholder => "$assetsBase/svg/placeholder.svg";
  static String get cartIcon => "$assetsBase/svg/cart.svg";
  static String get searchIcon => "$assetsBase/svg/search.svg";
  static String get micIcon => "$assetsBase/svg/mic.svg";
}
