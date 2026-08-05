class ImageKit {
  // ✅ الرابط الأساسي
  static const String base = "https://ik.imagekit.io/fqcynk86c";
  
  // ✅ المجلدات
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
  static String get hospital7 => hospital("hospital_7.png");  // ✅ تمت الإضافة
  static String get hospital8 => hospital("hospital_8.png");  // ✅ تمت الإضافة
  static String get hospital9 => hospital("hospital_9.png");  // ✅ تمت الإضافة
  
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
  // 🎨 الأيقونات (SVG)
  // ============================================================
  static String get pharmacyIcon => svg("pharmacy.svg");
  static String get emergencyIcon => svg("emergency.svg");
  static String get homeMedical => svg("home_medical.svg");
  static String get donateBlood => svg("donate_blood.svg");
  static String get maleDoctorIcon => svg("male_doctor.svg");
  static String get medicalIcon => svg("medical.svg");
  static String get notificationIcon => svg("notifications.svg");  // ✅ بدون s
  static String get notificationsIcon => svg("notifications.svg"); // ✅ للتوافق (مع s)
  static String get placeholder => svg("placeholder.svg");
  static String get cartIcon => svg("cart.svg");
  static String get searchIcon => svg("search.svg");
  static String get micIcon => svg("mic.svg");
  
  // ✅ أيقونات الخدمات السريعة
  static String get fastPharmacy => svg("fast_services/pharmacy.svg");
  static String get fastEmergency => svg("fast_services/emergency.svg");
  static String get fastHomeServices => svg("fast_services/home_services.svg");
  static String get fastDonateBlood => svg("fast_services/donate_blood.svg");
  static String get serviceDoctors => svg("fast_services/doctors.svg");
  static String get serviceLabs => svg("fast_services/labs.svg");
  static String get serviceHealth => svg("fast_services/health.svg");
  static String get serviceWallet => svg("fast_services/wallet.svg");
  static String get serviceAppointments => svg("fast_services/appointments.svg");
  static String get serviceNearby => svg("fast_services/nearby.svg");
  static String get serviceInsurance => svg("fast_services/insurance.svg");
  static String get serviceConsultation => svg("fast_services/consultation.svg");
}
