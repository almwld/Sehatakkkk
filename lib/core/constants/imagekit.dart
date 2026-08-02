class ImageKit {
  // ✅ الرابط الأساسي
  static const String base = "https://ik.imagekit.io/fqcynk86c";
  
  // ✅ المجلدات
  static const String imagesBase = "$base/images";
  static const String assetsBase = "$base/assets";
  
  // ✅ دوال مساعدة
  static String doctor(String name) => "$imagesBase/doctors/$name";
  static String hospital(String name) => "$imagesBase/hospitals/$name";
  static String pharmacy(String name) => "$imagesBase/pharmacies/$name";
  static String lab(String name) => "$imagesBase/labs/$name";
  static String medicine(String name) => "$imagesBase/medicines/$name";
  static String delivery(String name) => "$imagesBase/delivery/$name";
  static String post(String name) => "$imagesBase/posts/$name";
  static String banner(String name) => "$imagesBase/banners/$name";
  static String icon(String name) => "$imagesBase/icons/$name";
  static String svg(String name) => "$assetsBase/svg/$name";
  
  // ✅ تحسين الصور (ImageKit Transformations)
  static String optimize({
    required String url,
    int width = 300,
    int height = 300,
    int quality = 80,
    String format = 'webp',
  }) {
    // ✅ تجاهل SVG
    if (url.endsWith('.svg')) return url;
    return "$url?tr=w-$width,h-$height,q-$quality,f-$format";
  }
  
  // ✅ قائمة البانرات
  static List<String> get bannerList => [
    banner("banner_1.png"),
    banner("banner_2.png"),
    banner("banner_3.png"),
    banner("banner_4.png"),
  ];
  
  // ============================================================
  // 📸 روابط ثابتة للصور (Getters)
  // ============================================================
  
  // 👨‍⚕️ الأطباء
  static String get doctor1 => doctor("doctor_1.png");
  static String get doctor2 => doctor("doctor_2.png");
  static String get doctor3 => doctor("doctor_3.png");
  static String get doctor4 => doctor("doctor_4.png");
  static String get doctor5 => doctor("doctor_5.png");
  static String get doctorPlaceholder => doctor("doctor_placeholder.svg");
  static String get doctorFemalePlaceholder => doctor("doctor_female_placeholder.svg");
  
  // 🏥 المستشفيات
  static String get hospital1 => hospital("hospital_1.png");
  static String get hospital2 => hospital("hospital_2.png");
  static String get hospital3 => hospital("hospital_3.png");
  static String get hospital4 => hospital("hospital_4.png");
  static String get hospital5 => hospital("hospital_5.png");
  static String get hospital6 => hospital("hospital_6.png");
  static String get hospital7 => hospital("hospital_7.png");
  static String get hospital8 => hospital("hospital_8.png");
  static String get hospital9 => hospital("hospital_9.png");
  
  // 💊 الصيدليات
  static String get pharmacy1 => pharmacy("pharmacy_1.png");
  static String get pharmacy2 => pharmacy("pharmacy_2.png");
  static String get pharmacy3 => pharmacy("pharmacy_3.png");
  
  // 🔬 المختبرات
  static String get lab1 => lab("lab_1.png");
  static String get lab2 => lab("lab_2.png");
  static String get lab3 => lab("lab_3.png");
  
  // 💊 الأدوية
  static String get medicine1 => medicine("medicine_1.png");
  static String get medicine2 => medicine("medicine_2.png");
  static String get medicine3 => medicine("medicine_3.png");
  static String get medicine4 => medicine("medicine_4.png");
  
  // 🚚 التوصيل
  static String get delivery1 => delivery("delivery_1.png");
  static String get delivery2 => delivery("delivery_2.png");
  static String get delivery3 => delivery("delivery_3.png");
  static String get delivery4 => delivery("delivery_4.png");
  
  // 📰 المنشورات
  static String get immuneBoost => post("immune_boost.png");
  static String get morningWalk => post("morning_walk.png");
  static String get skinCare => post("skin_care.png");
  static String get nutritionTips => post("nutrition_tips.png");
  static String get sleepTips => post("sleep_tips.png");
  
  // 🎨 الأيقونات
  static String get maleDoctorIcon => icon("doctors/Male doctor.png");
  static String get femaleDoctorIcon => icon("doctors/female doctor.png");
  static String get searchIcon => icon("search/Search button.png");
  static String get notificationsIcon => icon("top_bar/notifications.png");
  static String get cartIcon => icon("top_bar/Shopping cart.png");
  static String get donateBlood => icon("fast_services/Donate blood.png");
  static String get pharmacyIcon => icon("fast_services/Pharmacy.png");
  static String get emergencyIcon => icon("fast_services/Emergency.png");
  static String get homeMedical => icon("fast_services/Home medical services.png");
  
  // ✅ أيقونات SVG محلية (Asset)
  static String get chatBackground => "assets/images/chat_background.svg";
  static String get notificationsButton => "assets/svg/زر اشعارات.svg";
  static String get searchButton => "assets/svg/ايقونه زر البحث.svg";
  static String get cartButton => "assets/svg/زر السله.svg";
  static String get medicalIcon => "assets/svg/icon_medical.svg";
  static String get doctorPerfect => "assets/svg/صور الاطباء الافتراضيه /doctor_perfect.svg";
  
  // ✅ صورة افتراضية
  static String get placeholder => "$imagesBase/placeholder.png";
}
