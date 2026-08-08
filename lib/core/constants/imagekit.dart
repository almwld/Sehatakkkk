class ImageKit {
  // ✅ الرابط الأساسي
  static const String base = "https://ik.imagekit.io/fqcynk86c";
  static const String imagesBase = "$base/images";
  static const String assetsBase = "$base/assets";
  
  // ============================================================
  // 📁 دوال مساعدة لبناء الروابط
  // ============================================================
  static String doctor(String name) => "$imagesBase/doctors/$name";
  static String hospital(String name) => "$imagesBase/hospitals/$name";
  static String pharmacy(String name) => "$imagesBase/pharmacies/$name";
  static String lab(String name) => "$imagesBase/labs/$name";
  static String medicine(String name) => "$imagesBase/medicines/$name";
  static String banner(String name) => "$imagesBase/banners/$name";
  static String delivery(String name) => "$imagesBase/delivery/$name";
  static String post(String name) => "$imagesBase/posts/$name";
  static String icon(String name) => "$imagesBase/icons/$name";
  static String svg(String name) => "$assetsBase/svg/$name";
  
  // ============================================================
  // 📸 البانرات (4 صور)
  // ============================================================
  static List<String> get bannerList => [
    banner("banner_1.png"),
    banner("banner_2.png"),
    banner("banner_3.png"),
    banner("banner_4.png"),
  ];
  
  // ============================================================
  // 👨‍⚕️ الأطباء (5 صور)
  // ============================================================
  static String get doctor1 => doctor("doctor_1.png");
  static String get doctor2 => doctor("doctor_2.png");
  static String get doctor3 => doctor("doctor_3.png");
  static String get doctor4 => doctor("doctor_4.png");
  static String get doctor5 => doctor("doctor_5.png");
  
  // ============================================================
  // 🏥 المستشفيات (9 صور)
  // ============================================================
  static String get hospital1 => hospital("hospital_1.png");
  static String get hospital2 => hospital("hospital_2.png");
  static String get hospital3 => hospital("hospital_3.png");
  static String get hospital4 => hospital("hospital_4.png");
  static String get hospital5 => hospital("hospital_5.png");
  static String get hospital6 => hospital("hospital_6.png");
  static String get hospital7 => hospital("hospital_7.png");
  static String get hospital8 => hospital("hospital_8.png");
  static String get hospital9 => hospital("hospital_9.png");
  
  // ============================================================
  // 🧪 المختبرات (3 صور)
  // ============================================================
  static String get lab1 => lab("lab_1.png");
  static String get lab2 => lab("lab_2.png");
  static String get lab3 => lab("lab_3.png");
  
  // ============================================================
  // 💊 الصيدليات (3 صور)
  // ============================================================
  static String get pharmacy1 => pharmacy("pharmacy_1.png");
  static String get pharmacy2 => pharmacy("pharmacy_2.png");
  static String get pharmacy3 => pharmacy("pharmacy_3.png");
  
  // ============================================================
  // 💊 الأدوية (4 صور)
  // ============================================================
  static String get medicine1 => medicine("medicine_1.png");
  static String get medicine2 => medicine("medicine_2.png");
  static String get medicine3 => medicine("medicine_3.png");
  static String get medicine4 => medicine("medicine_4.png");
  
  // ============================================================
  // 📦 التوصيل (5 صور)
  // ============================================================
  static String get delivery1 => delivery("delivery_1.png");
  static String get delivery2 => delivery("delivery_2.png");
  static String get delivery3 => delivery("delivery_3.png");
  static String get delivery4 => delivery("delivery_4.png");
  static String get delivery5 => delivery("delivery_5.png");
  
  // ============================================================
  // 📝 المنشورات (5 صور)
  // ============================================================
  static String get post1 => post("post_1.png");
  static String get post2 => post("post_2.png");
  static String get post3 => post("post_3.png");
  static String get post4 => post("post_4.png");
  static String get post5 => post("post_5.png");
  
  // ============================================================
  // 📰 المقالات (صور من Unsplash)
  // ============================================================
  static String get morningWalk => "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop";
  static String get immuneBoost => "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=300&fit=crop";
  static String get sleepTips => "https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=400&h=300&fit=crop";
  static String get skinCare => "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400&h=300&fit=crop";
  static String get nutritionTips => "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop";
  
  // ============================================================
  // 🎨 أيقونات السوشيال ميديا (SVG من assets)
  // ============================================================
  // استخدام المسارات المحلية بدلاً من ImageKit
  static const String socialGoogle = 'assets/icons/social/google.svg';
  static const String socialApple = 'assets/icons/social/apple.svg';
  static const String socialInstagram = 'assets/icons/social/instagram.svg';
  static const String socialTwitter = 'assets/icons/social/x_twitter.svg';
  static const String socialFacebook = 'assets/icons/social/facebook.svg';
  static const String socialYoutube = 'assets/icons/social/youtube.svg';
  static const String socialTiktok = 'assets/icons/social/tiktok.svg';
}
