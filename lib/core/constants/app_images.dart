// ============================================================
// 📁 lib/core/constants/app_images.dart
// 📋 جميع مسارات الصور - محلي + ImageKit
// ============================================================

import 'package:sehatak/core/config/imagekit_config.dart';

class AppImages {
  // ============================================================
  // ☁️ ImageKit - صور ديناميكية (سحابية)
  // ============================================================
  
  // 🖼️ صور الأطباء
  static const String doctor1 = ImageKitConfig.doctor1;
  static const String doctor2 = ImageKitConfig.doctor2;
  static const String doctor3 = ImageKitConfig.doctor3;
  static const String doctor4 = ImageKitConfig.doctor4;
  static const String doctor5 = ImageKitConfig.doctor5;
  static const String doctor6 = ImageKitConfig.doctor6;

  // 🏥 صور المستشفيات
  static const String hospital1 = ImageKitConfig.hospital1;
  static const String hospital2 = ImageKitConfig.hospital2;
  static const String hospital3 = ImageKitConfig.hospital3;
  static const String hospital4 = ImageKitConfig.hospital4;
  static const String hospital5 = ImageKitConfig.hospital5;
  static const String hospital6 = ImageKitConfig.hospital6;

  // 🔬 صور المختبرات
  static const String lab1 = ImageKitConfig.lab1;
  static const String lab2 = ImageKitConfig.lab2;
  static const String lab3 = ImageKitConfig.lab3;

  // 💊 صور الأدوية
  static const String medicine1 = ImageKitConfig.medicine1;
  static const String medicine2 = ImageKitConfig.medicine2;
  static const String medicine3 = ImageKitConfig.medicine3;
  static const String medicine4 = ImageKitConfig.medicine4;

  // 🏪 صور الصيدليات
  static const String pharmacy1 = ImageKitConfig.pharmacy1;
  static const String pharmacy2 = ImageKitConfig.pharmacy2;
  static const String pharmacy3 = ImageKitConfig.pharmacy3;

  // 📰 صور المنشورات
  static const String morningWalk = ImageKitConfig.morningWalk;
  static const String immuneBoost = ImageKitConfig.immuneBoost;
  static const String sleepTips = ImageKitConfig.sleepTips;
  static const String skinCare = ImageKitConfig.skinCare;
  static const String nutritionTips = ImageKitConfig.nutritionTips;

  // 📸 البانرات
  static const String banner1 = ImageKitConfig.banner1;
  static const String banner2 = ImageKitConfig.banner2;
  static const String banner3 = ImageKitConfig.banner3;
  static const String banner4 = ImageKitConfig.banner4;
  static const List<String> bannerList = ImageKitConfig.bannerList;

  // 🚚 صور التوصيل
  static const String delivery1 = ImageKitConfig.delivery1;
  static const String delivery2 = ImageKitConfig.delivery2;
  static const String delivery3 = ImageKitConfig.delivery3;
  static const String delivery4 = ImageKitConfig.delivery4;

  // ============================================================
  // 📁 محلي (assets) - أيقونات ثابتة
  // ============================================================

  // 🖼️ أيقونات الخريطة (SVG)
  static const String mapClinic = 'assets/icons/map_pins/clinic.svg';
  static const String mapHospital = 'assets/icons/map_pins/hospital.svg';
  static const String mapLaboratory = 'assets/icons/map_pins/laboratory.svg';
  static const String mapMedical = 'assets/icons/map_pins/medical.svg';
  static const String mapPharmacy = 'assets/icons/map_pins/pharmacy.svg';

  // 🖼️ أيقونات التواصل الاجتماعي (SVG)
  static const String socialChatModern = 'assets/icons/social/chat_modern.svg';
  static const String socialDiscord = 'assets/icons/social/discord.svg';
  static const String socialFacebookSvg = 'assets/icons/social/facebook.svg';
  static const String socialInstagramSvg = 'assets/icons/social/instagram.svg';
  static const String socialLinkedin = 'assets/icons/social/linkedin.svg';
  static const String socialTwitter = 'assets/icons/social/twitter.svg';
  static const String socialWhatsapp = 'assets/icons/social/whatsapp.svg';
  static const String socialXTwitterSvg = 'assets/icons/social/x_twitter.svg';

  // 🖼️ أيقونات الدردشة (PNG)
  static const String chatAiAssistant = 'assets/images/chat/ai_assistant.png';
  static const String chatAudioRecord = 'assets/images/chat/audio_record.png';
  static const String chatAudioRecord3d = 'assets/images/chat/audio_record_3d.png';
  static const String chatCalendarBooking = 'assets/images/chat/calendar_booking.png';
  static const String chatBubble = 'assets/images/chat/chat_bubble.png';
  static const String chatMicrophone = 'assets/images/chat/microphone.png';
  static const String chatPhoneCall = 'assets/images/chat/phone_call.png';
  static const String chatPlayButton = 'assets/images/chat/play_button.png';
  static const String chatVideoCall = 'assets/images/chat/video_call.png';
  static const String chatUnsupported = 'assets/images/chat/unsupported-message.svg';

  // 🖼️ أيقونات الأطباء (PNG)
  static const String doctorMale = 'assets/images/icons/doctors/doctor_male.png';
  static const String doctorFemale = 'assets/images/icons/doctors/doctor_female.png';

  // 🖼️ أيقونات البحث والشريط العلوي (PNG)
  static const String searchButton = 'assets/images/icons/search/Search button.png';
  static const String topBarCart = 'assets/images/icons/top_bar/Shopping cart.png';
  static const String topBarNotifications = 'assets/images/icons/top_bar/notifications.png';

  // 🖼️ أيقونات المحافظ (PNG)
  static const String walletJeeb = 'assets/images/payment/jeeb.png';
  static const String walletJawali = 'assets/images/payment/jawali.png';
  static const String walletKash = 'assets/images/payment/kash.png';
  static const String walletKashOne = 'assets/images/payment/kash_one.png';
  static const String walletEasy = 'assets/images/payment/easy.png';
  static const String walletFloosak = 'assets/images/payment/floosak.png';
  static const String walletKremi = 'assets/images/payment/kremi.png';
  static const String walletMobileMoney = 'assets/images/payment/mobile_money.png';
  static const String walletYemenWallet = 'assets/images/payment/yemen_wallet.png';

  // 🖼️ أيقونات الخدمات (PNG)
  static const String serviceAiAssistant = 'assets/images/services/ai_assistant.png';
  static const String serviceBloodDonation = 'assets/images/services/blood_donation.png';
  static const String serviceCalendarBooking = 'assets/images/services/calendar_booking.png';
  static const String serviceConsultation = 'assets/images/services/consultation.png';
  static const String serviceDoctorsTeam = 'assets/images/services/doctors_team.png';
  static const String serviceEmergency = 'assets/images/services/emergency.png';
  static const String serviceFirstAid = 'assets/images/services/first_aid.png';
  static const String serviceHealthInsurance = 'assets/images/services/health_insurance.png';
  static const String serviceHealthTips = 'assets/images/services/health_tips.png';
  static const String serviceHospital = 'assets/images/services/hospital.png';
  static const String serviceLaboratory = 'assets/images/services/laboratory.png';
  static const String serviceMapLocation = 'assets/images/services/map_location.png';
  static const String serviceMedicalArticles = 'assets/images/services/medical_articles.png';
  static const String serviceMedicalCommunity = 'assets/images/services/medical_community.png';
  static const String serviceMedicalRecords = 'assets/images/services/medical_records.png';
  static const String serviceMedications = 'assets/images/services/medications.png';
  static const String serviceNearbyClinics = 'assets/images/services/nearby_clinics.png';
  static const String serviceNotifications = 'assets/images/services/notifications.png';
  static const String servicePackages = 'assets/images/services/packages.png';
  static const String servicePharmacy = 'assets/images/services/pharmacy.png';
  static const String serviceServicesLaboratory = 'assets/images/services/services_laboratory.png';
  static const String serviceVideoConsultation = 'assets/images/services/video_consultation.png';
  static const String serviceWallet = 'assets/images/services/wallet.png';
  static const String serviceWomensHealth = 'assets/images/services/womens_health.png';

  // 🖼️ أيقونات التواصل الاجتماعي (PNG)
  static const String socialApple = 'assets/images/social/apple.png';
  static const String socialFacebook = 'assets/images/social/facebook.png';
  static const String socialGoogle = 'assets/images/social/google.png';
  static const String socialInstagram = 'assets/images/social/instagram.png';
  static const String socialTiktok = 'assets/images/social/tiktok.png';
  static const String socialXTwitter = 'assets/images/social/x_twitter.png';
  static const String socialYoutube = 'assets/images/social/youtube.png';

  // 🖼️ أيقونات التتبع (PNG)
  static const String trackingAge = 'assets/images/tracking/age.png';
  static const String trackingAmbulance = 'assets/images/tracking/ambulance.png';
  static const String trackingBloodDonation = 'assets/images/tracking/blood_donation.png';
  static const String trackingBloodPressure = 'assets/images/tracking/blood_pressure.png';
  static const String trackingBloodSugar = 'assets/images/tracking/blood_sugar.png';
  static const String trackingCalendarBooking = 'assets/images/tracking/calendar_booking.png';
  static const String trackingFavorites = 'assets/images/tracking/favorites.png';
  static const String trackingFirstAid = 'assets/images/tracking/first_aid.png';
  static const String trackingFitness = 'assets/images/tracking/fitness.png';
  static const String trackingFruits = 'assets/images/tracking/fruits.png';
  static const String trackingHeightCm = 'assets/images/tracking/height_cm.png';
  static const String trackingMedicalRecords = 'assets/images/tracking/medical_records.png';
  static const String trackingMedicalReport = 'assets/images/tracking/medical_report.png';
  static const String trackingMentalHealth = 'assets/images/tracking/mental_health.png';
  static const String trackingNutrition = 'assets/images/tracking/nutrition.png';
  static const String trackingPatient = 'assets/images/tracking/patient.png';
  static const String trackingServicesBloodDonation = 'assets/images/tracking/services_blood_donation.png';
  static const String trackingServicesLaboratory = 'assets/images/tracking/services_laboratory.png';
  static const String trackingSleep = 'assets/images/tracking/sleep_tracking.png';
  static const String trackingTrackingBloodSugar = 'assets/images/tracking/tracking_blood_sugar.png';
  static const String trackingVaccination = 'assets/images/tracking/vaccination.png';
  static const String trackingWalking = 'assets/images/tracking/walking.png';
  static const String trackingWater = 'assets/images/tracking/water_drinking.png';
  static const String trackingWeight = 'assets/images/tracking/weight_tracking.png';

  // 🖼️ أيقونات الواجهة (PNG)
  static const String uiAboutApp = 'assets/images/ui/about_app.png';
  static const String uiAllServices = 'assets/images/ui/all_services.png';
  static const String uiAnalyses = 'assets/images/ui/analyses.png';
  static const String uiBloodSugar3d = 'assets/images/ui/blood_sugar_3d.png';
  static const String uiBloodType = 'assets/images/ui/blood_type.png';
  static const String uiChild = 'assets/images/ui/child.png';
  static const String uiCommentButton = 'assets/images/ui/comment_button.png';
  static const String uiContactUs = 'assets/images/ui/contact_us.png';
  static const String uiDoctorAvatar = 'assets/images/ui/doctor_avatar.png';
  static const String uiDoctorsTeam = 'assets/images/ui/doctors_team.png';
  static const String uiDownloadData = 'assets/images/ui/download_data.png';
  static const String uiEditButton = 'assets/images/ui/edit_button.png';
  static const String uiEmergency = 'assets/images/ui/emergency.png';
  static const String uiEmojiButton3d = 'assets/images/ui/emoji_button_3d.png';
  static const String uiExperience = 'assets/images/ui/experience.png';
  static const String uiFamily = 'assets/images/ui/family.png';
  static const String uiFavorites = 'assets/images/ui/favorites.png';
  static const String uiHeightCm = 'assets/images/ui/height_cm.png';
  static const String uiHelpCenter = 'assets/images/ui/help_center.png';
  static const String uiLab1 = 'assets/images/ui/lab1.png';
  static const String uiLikeButton = 'assets/images/ui/like_button.png';
  static const String uiLogout = 'assets/images/ui/logout.png';
  static const String uiMedicine10 = 'assets/images/ui/medicine10.png';
  static const String uiMedicine8 = 'assets/images/ui/medicine8.png';
  static const String uiMoreMenu = 'assets/images/ui/more_menu.png';
  static const String uiPackages = 'assets/images/ui/packages.png';
  static const String uiPackagesSubscriptions = 'assets/images/ui/packages_subscriptions.png';
  static const String uiPatient = 'assets/images/ui/patient.png';
  static const String uiPrivacy = 'assets/images/ui/privacy.png';
  static const String uiRateApp = 'assets/images/ui/rate_app.png';
  static const String uiReportProblem = 'assets/images/ui/report_problem.png';
  static const String uiSettings = 'assets/images/ui/settings.png';
  static const String uiSettingsGear = 'assets/images/ui/settings_gear.png';
  static const String uiShareApp = 'assets/images/ui/share_app.png';
  static const String uiSystemNotifications = 'assets/images/ui/system_notifications.png';
  static const String uiTermsConditions = 'assets/images/ui/terms_conditions.png';
  static const String uiUserProfile = 'assets/images/ui/user_profile.png';
  static const String uiVisits = 'assets/images/ui/visits.png';

  // 🖼️ أيقونات المحافظ (PNG)
  static const String walletPayments = 'assets/images/wallets/payments.png';
  static const String wallet = 'assets/images/wallets/wallet.png';

  // 🖼️ خلفيات الدردشة
  static const String chatWallpaperAuto = 'assets/images/sehatak_chat_wallpaper_auto.svg';
  static const String chatWallpaperDark = 'assets/images/sehatak_chat_wallpaper_dark.svg';
  static const String chatWallpaperDark1080 = 'assets/images/sehatak_chat_wallpaper_dark_1080x2160.png';
  static const String chatWallpaperLight = 'assets/images/sehatak_chat_wallpaper_light.svg';
  static const String chatWallpaperLight1080 = 'assets/images/sehatak_chat_wallpaper_light_1080x2160.png';

  // 🖼️ أيقونات إضافية
  static const String childhealth = 'assets/images/childhealth.png';
  static const String pregnancyFollowUp = 'assets/images/Pregnancyfollow-up.png';
}
