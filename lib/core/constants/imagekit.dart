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
  // 🎨 أيقونات الدردشة (Chat) - 7 أيقونات PNG
  // ============================================================
  static String get chatAudioRecord => "$imagesBase/chat/audio_record.png";
  static String get chatCalendarBooking => "$imagesBase/chat/calendar_booking.png";
  static String get chatBubble => "$imagesBase/chat/chat_bubble.png";
  static String get chatMicrophone => "$imagesBase/chat/microphone.png";
  static String get chatPhoneCall => "$imagesBase/chat/phone_call.png";
  static String get chatPlayButton => "$imagesBase/chat/play_button.png";
  static String get chatVideoCall => "$imagesBase/chat/video_call.png";
  
  // ============================================================
  // 🎨 أيقونات الخدمات (Services) - 16 أيقونة PNG
  // ============================================================
  static String get serviceAiAssistant => "$imagesBase/services/ai_assistant.png";
  static String get serviceBloodDonation => "$imagesBase/services/blood_donation.png";
  static String get serviceCalendarBooking => "$imagesBase/services/calendar_booking.png";
  static String get serviceConsultation => "$imagesBase/services/consultation.png";
  static String get serviceEmergency => "$imagesBase/services/emergency.png";
  static String get serviceHealthInsurance => "$imagesBase/services/health_insurance.png";
  static String get serviceHealthTips => "$imagesBase/services/health_tips.png";
  static String get serviceLaboratory => "$imagesBase/services/laboratory.png";
  static String get serviceMapLocation => "$imagesBase/services/map_location.png";
  static String get serviceMedicalCommunity => "$imagesBase/services/medical_community.png";
  static String get serviceMedicalRecords => "$imagesBase/services/medical_records.png";
  static String get serviceMedications => "$imagesBase/services/medications.png";
  static String get serviceNotifications => "$imagesBase/services/notifications.png";
  static String get servicePharmacy => "$imagesBase/services/pharmacy.png";
  static String get serviceVideoConsultation => "$imagesBase/services/video_consultation.png";
  static String get serviceWallet => "$imagesBase/services/wallet.png";
  
  // ============================================================
  // 🎨 أيقونات السوشيال ميديا (Social) - 7 أيقونات PNG
  // ============================================================
  static String get socialGoogle => "$imagesBase/social/google.png";
  static String get socialApple => "$imagesBase/social/apple.png";
  static String get socialInstagram => "$imagesBase/social/instagram.png";
  static String get socialTwitter => "$imagesBase/social/x_twitter.png";
  static String get socialFacebook => "$imagesBase/social/facebook.png";
  static String get socialYoutube => "$imagesBase/social/youtube.png";
  static String get socialTiktok => "$imagesBase/social/tiktok.png";
  
  // ============================================================
  // 🎨 أيقونات التتبع (Tracking) - 9 أيقونات PNG
  // ============================================================
  static String get trackingAmbulance => "$imagesBase/tracking/ambulance.png";
  static String get trackingBloodPressure => "$imagesBase/tracking/blood_pressure.png";
  static String get trackingBloodSugar => "$imagesBase/tracking/blood_sugar.png";
  static String get trackingFitness => "$imagesBase/tracking/fitness.png";
  static String get trackingMedicalReport => "$imagesBase/tracking/medical_report.png";
  static String get trackingMentalHealth => "$imagesBase/tracking/mental_health.png";
  static String get trackingNutrition => "$imagesBase/tracking/nutrition.png";
  static String get trackingVaccination => "$imagesBase/tracking/vaccination.png";
  static String get trackingWeight => "$imagesBase/tracking/weight_tracking.png";
  
  // ============================================================
  // 🎨 الخدمات السريعة (Quick Services) - استخدام PNG بدلاً من SVG
  // ============================================================
  static String get quickPharmacy => "$imagesBase/services/pharmacy.png";
  static String get quickEmergency => "$imagesBase/services/emergency.png";
  static String get quickBloodDonation => "$imagesBase/services/blood_donation.png";
  static String get quickConsultation => "$imagesBase/services/consultation.png";
  static String get quickLaboratory => "$imagesBase/services/laboratory.png";
  static String get quickMedicalRecords => "$imagesBase/services/medical_records.png";
  static String get quickMedications => "$imagesBase/services/medications.png";
  static String get quickNotifications => "$imagesBase/services/notifications.png";
  static String get quickWallet => "$imagesBase/services/wallet.png";
  static String get quickHealthTips => "$imagesBase/services/health_tips.png";
  static String get quickMedicalCommunity => "$imagesBase/services/medical_community.png";
  static String get quickVideoConsultation => "$imagesBase/services/video_consultation.png";
  
  // ============================================================
  // 🎨 الأيقونات القديمة (محفوظة للتوافق)
  // ============================================================
  static String get pharmacyIcon => "$imagesBase/services/pharmacy.png";
  static String get emergencyIcon => "$imagesBase/services/emergency.png";
  static String get homeMedical => "$imagesBase/services/medical_community.png";
  static String get donateBlood => "$imagesBase/services/blood_donation.png";
  static String get maleDoctorIcon => "$imagesBase/services/consultation.png";
  static String get medicalIcon => "$imagesBase/services/medical_records.png";
  static String get notificationIcon => "$imagesBase/services/notifications.png";
  static String get placeholder => "$imagesBase/services/health_tips.png";
  static String get cartIcon => "$imagesBase/services/wallet.png";
  static String get searchIcon => "$imagesBase/services/medical_records.png";
  static String get micIcon => "$imagesBase/services/consultation.png";
  
  // ✅ أيقونات الخدمات السريعة (تم تحديثها إلى PNG)
  static String get fastPharmacy => "$imagesBase/services/pharmacy.png";
  static String get fastEmergency => "$imagesBase/services/emergency.png";
  static String get fastHomeServices => "$imagesBase/services/medical_community.png";
  static String get fastDonateBlood => "$imagesBase/services/blood_donation.png";
  static String get serviceDoctors => "$imagesBase/services/consultation.png";
  static String get serviceLabs => "$imagesBase/services/laboratory.png";
  static String get serviceHealth => "$imagesBase/services/health_tips.png";
  static String get serviceWallet => "$imagesBase/services/wallet.png";
  static String get serviceAppointments => "$imagesBase/services/calendar_booking.png";
  static String get serviceNearby => "$imagesBase/services/map_location.png";
  static String get serviceInsurance => "$imagesBase/services/health_insurance.png";
  static String get serviceConsultation => "$imagesBase/services/video_consultation.png";
}
