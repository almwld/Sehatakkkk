// ============================================================
// 📁 lib/core/config/imagekit_config.dart
// 🖼️ إعدادات ImageKit لاستضافة الصور
// ============================================================

class ImageKitConfig {
  // ✅ عنوان URL الأساسي لـ ImageKit
  static const String baseUrl = 'https://ik.imagekit.io/fqcynk86c';

  // ✅ مجلدات التخزين
  static const String images = '$baseUrl/images';
  static const String doctors = '$images/doctors';
  static const String hospitals = '$images/hospitals';
  static const String labs = '$images/labs';
  static const String medicines = '$images/medicines';
  static const String pharmacies = '$images/pharmacies';
  static const String posts = '$images/posts';
  static const String banners = '$images/banners';
  static const String chat = '$images/chat';
  static const String delivery = '$images/delivery';
  static const String icons = '$baseUrl/icons';
  static const String payment = '$baseUrl/payment';
  static const String ui = '$baseUrl/ui';
  static const String tracking = '$baseUrl/tracking';
  static const String services = '$baseUrl/services';
  static const String wallets = '$baseUrl/wallets';
  static const String social = '$baseUrl/social';

  // ✅ صورة placeholder افتراضية
  static const String defaultPlaceholder = '$images/placeholder.png';

  // ============================================================
  // 🖼️ صور الأطباء
  // ============================================================
  static const String doctor1 = '$doctors/doctor_1.png';
  static const String doctor2 = '$doctors/doctor_2.png';
  static const String doctor3 = '$doctors/doctor_3.png';
  static const String doctor4 = '$doctors/doctor_4.png';
  static const String doctor5 = '$doctors/doctor_5.png';
  static const String doctor6 = '$doctors/doctor_6.png';
  static const String doctorPlaceholder = '$doctors/doctor_placeholder.svg';
  static const String doctorFemalePlaceholder = '$doctors/doctor_female_placeholder.svg';

  // ============================================================
  // 🏥 صور المستشفيات
  // ============================================================
  static const String hospital1 = '$hospitals/hospital_1.png';
  static const String hospital2 = '$hospitals/hospital_2.png';
  static const String hospital3 = '$hospitals/hospital_3.png';
  static const String hospital4 = '$hospitals/hospital_4.png';
  static const String hospital5 = '$hospitals/hospital_5.png';
  static const String hospital6 = '$hospitals/hospital_6.png';
  static const String hospital7 = '$hospitals/hospital_7.png';
  static const String hospital8 = '$hospitals/hospital_8.png';
  static const String hospital9 = '$hospitals/hospital_9.png';

  // ============================================================
  // 🔬 صور المختبرات
  // ============================================================
  static const String lab1 = '$labs/lab_1.png';
  static const String lab2 = '$labs/lab_2.png';
  static const String lab3 = '$labs/lab_3.png';
  static const String labRazi = '$labs/مختبرات الرازي .png';
  static const String labAlawli = '$labs/مختبرات العولقي.png';
  static const String labAlmamoon = '$labs/مختبرات المأمون.png';

  // ============================================================
  // 💊 صور الأدوية
  // ============================================================
  static const String medicine1 = '$medicines/medicine_1.png';
  static const String medicine2 = '$medicines/medicine_2.png';
  static const String medicine3 = '$medicines/medicine_3.png';
  static const String medicine4 = '$medicines/medicine_4.png';

  // ============================================================
  // 🏪 صور الصيدليات
  // ============================================================
  static const String pharmacy1 = '$pharmacies/pharmacy_1.png';
  static const String pharmacy2 = '$pharmacies/pharmacy_2.png';
  static const String pharmacy3 = '$pharmacies/pharmacy_3.png';

  // ============================================================
  // 📰 صور المنشورات الصحية
  // ============================================================
  static const String morningWalk = '$posts/morning_walk.png';
  static const String immuneBoost = '$posts/immune_boost.png';
  static const String sleepTips = '$posts/sleep_tips.png';
  static const String skinCare = '$posts/skin_care.png';
  static const String nutritionTips = '$posts/nutrition_tips.png';

  // ============================================================
  // 📸 البانرات
  // ============================================================
  static const String banner1 = '$banners/banner_1.png';
  static const String banner2 = '$banners/banner_2.png';
  static const String banner3 = '$banners/banner_3.png';
  static const String banner4 = '$banners/banner_4.png';
  static const List<String> bannerList = [banner1, banner2, banner3, banner4];

  // ============================================================
  // 💬 أيقونات الدردشة
  // ============================================================
  static const String chatPhoneCall = '$chat/phone_call.png';
  static const String chatVideoCall = '$chat/video_call.png';
  static const String chatBubble = '$chat/chat_bubble.png';
  static const String chatCalendarBooking = '$chat/calendar_booking.png';
  static const String chatMicrophone = '$chat/microphone.png';
  static const String chatAudioRecord = '$chat/audio_record.png';
  static const String chatPlayButton = '$chat/play_button.png';
  static const String chatAiAssistant = '$chat/ai_assistant.png';

  // ============================================================
  // 🚚 أيقونات التوصيل
  // ============================================================
  static const String deliverySehatak = '$delivery/delivery_1.png';
  static const String deliveryNas = '$delivery/delivery_2.png';
  static const String deliveryTasheel = '$delivery/delivery_3.png';
  static const String deliveryOther = '$delivery/delivery_4.png';

  // ============================================================
  // 💳 أيقونات المحافظ
  // ============================================================
  static const String walletJeeb = '$payment/jeeb.png';
  static const String walletJawali = '$payment/jawali.png';
  static const String walletKash = '$payment/kash.png';
  static const String walletKashOne = '$payment/kash_one.png';
  static const String walletEasy = '$payment/easy.png';
  static const String walletFloosak = '$payment/floosak.png';
  static const String walletKremi = '$payment/kremi.png';
  static const String walletMobileMoney = '$payment/mobile_money.png';
  static const String walletYemenWallet = '$payment/yemen_wallet.png';

  // ============================================================
  // 📷 صور الواجهة
  // ============================================================
  static const String uiAboutApp = '$ui/about_app.png';
  static const String uiAllServices = '$ui/all_services.png';
  static const String uiPrivacy = '$ui/privacy.png';
  static const String uiContactUs = '$ui/contact_us.png';
  static const String uiHelpCenter = '$ui/help_center.png';
  static const String uiDownloadData = '$ui/download_data.png';
  static const String uiReportProblem = '$ui/report_problem.png';
  static const String uiShareApp = '$ui/share_app.png';
  static const String uiRateApp = '$ui/rate_app.png';
  static const String uiTermsConditions = '$ui/terms_conditions.png';
  static const String uiUserProfile = '$ui/user_profile.png';
  static const String uiSettingsGear = '$ui/settings_gear.png';
  static const String uiLikeButton = '$ui/like_button.png';
  static const String uiEditButton = '$ui/edit_button.png';

  // ============================================================
  // 📷 صور التتبع
  // ============================================================
  static const String trackingAge = '$tracking/age.png';
  static const String trackingBloodPressure = '$tracking/blood_pressure.png';
  static const String trackingBloodSugar = '$tracking/blood_sugar.png';
  static const String trackingWeight = '$tracking/weight_tracking.png';
  static const String trackingWalking = '$tracking/walking.png';
  static const String trackingFruits = '$tracking/fruits.png';
  static const String trackingSleep = '$tracking/sleep_tracking.png';
  static const String trackingWater = '$tracking/water_drinking.png';
  static const String trackingFitness = '$tracking/fitness.png';
  static const String trackingNutrition = '$tracking/nutrition.png';

  // ============================================================
  // 📷 صور الخدمات
  // ============================================================
  static const String servicePharmacy = '$services/pharmacy.png';
  static const String serviceHospital = '$services/hospital.png';
  static const String serviceLaboratory = '$services/laboratory.png';
  static const String serviceBloodDonation = '$services/blood_donation.png';
  static const String serviceFirstAid = '$services/first_aid.png';
  static const String serviceMedicalArticles = '$services/medical_articles.png';
  static const String servicePackages = '$services/packages.png';
  static const String serviceWomensHealth = '$services/womens_health.png';
  static const String serviceHealthInsurance = '$services/health_insurance.png';
  static const String serviceHealthTips = '$services/health_tips.png';
  static const String serviceMedicalCommunity = '$services/medical_community.png';
  static const String serviceMedicalRecords = '$services/medical_records.png';
  static const String serviceMedications = '$services/medications.png';
  static const String serviceNotifications = '$services/notifications.png';
  static const String serviceVideoConsultation = '$services/video_consultation.png';
  static const String serviceWallet = '$services/wallet.png';
  static const String serviceConsultation = '$services/consultation.png';
  static const String serviceEmergency = '$services/emergency.png';
  static const String serviceMapLocation = '$services/map_location.png';
  static const String serviceCalendarBooking = '$services/calendar_booking.png';
  static const String serviceAiAssistant = '$services/ai_assistant.png';

  // ============================================================
  // 📷 أيقونات التواصل الاجتماعي
  // ============================================================
  static const String socialFacebook = '$social/facebook.png';
  static const String socialInstagram = '$social/instagram.png';
  static const String socialGoogle = '$social/google.png';
  static const String socialApple = '$social/apple.png';
  static const String socialTiktok = '$social/tiktok.png';
  static const String socialYoutube = '$social/youtube.png';
  static const String socialXTwitter = '$social/x_twitter.png';

  // ============================================================
  // 📷 أيقونات المحافظ
  // ============================================================
  static const String walletPayments = '$wallets/payments.png';
  static const String wallet = '$wallets/wallet.png';

  // ============================================================
  // 🖼️ أيقونات SVG
  // ============================================================
  static const String chatWallpaperAuto = '$baseUrl/images/sehatak_chat_wallpaper_auto.svg';
  static const String chatWallpaperDark = '$baseUrl/images/sehatak_chat_wallpaper_dark.svg';
  static const String chatWallpaperLight = '$baseUrl/images/sehatak_chat_wallpaper_light.svg';
}
