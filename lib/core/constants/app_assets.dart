import 'package:flutter/material.dart';

class AppAssets {
  // ============================================================
  // 📁 المسارات الأساسية
  // ============================================================
  static const String _iconsPath = 'assets/icons/';
  static const String _imagesPath = 'assets/images/';
  
  // ============================================================
  // 🎨 أيقونات SVG (محفوظة للتوافق)
  // ============================================================
  // سيتم استبدالها تدريجياً بـ PNG
  static const String homeIcon = '${_iconsPath}home.svg';
  static const String doctorIcon = '${_iconsPath}doctor.svg';
  static const String pharmacyIcon = '${_iconsPath}pharmacy.svg';
  static const String labIcon = '${_iconsPath}lab.svg';
  static const String appointmentIcon = '${_iconsPath}appointment.svg';
  static const String healthFileIcon = '${_iconsPath}health_file.svg';
  static const String moreIcon = '${_iconsPath}more.svg';
  static const String notificationIcon = '${_iconsPath}notification.svg';
  static const String searchIcon = '${_iconsPath}search.svg';
  static const String filterIcon = '${_iconsPath}filter.svg';
  static const String menuIcon = '${_iconsPath}menu.svg';
  static const String backIcon = '${_iconsPath}back.svg';
  static const String arrowRightIcon = '${_iconsPath}arrow_right.svg';
  static const String heartIcon = '${_iconsPath}heart.svg';
  static const String heartFilledIcon = '${_iconsPath}heart_filled.svg';
  static const String starIcon = '${_iconsPath}star.svg';
  static const String starFilledIcon = '${_iconsPath}star_filled.svg';
  static const String calendarIcon = '${_iconsPath}calendar.svg';
  static const String clockIcon = '${_iconsPath}clock.svg';
  static const String locationIcon = '${_iconsPath}location.svg';
  static const String phoneIcon = '${_iconsPath}phone.svg';
  static const String emailIcon = '${_iconsPath}email.svg';
  static const String passwordIcon = '${_iconsPath}password.svg';
  static const String userIcon = '${_iconsPath}user.svg';
  static const String editIcon = '${_iconsPath}edit.svg';
  static const String deleteIcon = '${_iconsPath}delete.svg';
  static const String shareIcon = '${_iconsPath}share.svg';
  static const String downloadIcon = '${_iconsPath}download.svg';
  static const String uploadIcon = '${_iconsPath}upload.svg';
  static const String cameraIcon = '${_iconsPath}camera.svg';
  static const String galleryIcon = '${_iconsPath}gallery.svg';
  static const String checkIcon = '${_iconsPath}check.svg';
  static const String closeIcon = '${_iconsPath}close.svg';
  static const String addIcon = '${_iconsPath}add.svg';
  static const String removeIcon = '${_iconsPath}remove.svg';
  static const String cartIcon = '${_iconsPath}cart.svg';
  static const String walletIcon = '${_iconsPath}wallet.svg';
  static const String creditCardIcon = '${_iconsPath}credit_card.svg';
  static const String insuranceIcon = '${_iconsPath}insurance.svg';
  static const String emergencyIcon = '${_iconsPath}emergency.svg';
  static const String sosIcon = '${_iconsPath}sos.svg';
  static const String firstAidIcon = '${_iconsPath}first_aid.svg';
  static const String settingsIcon = '${_iconsPath}settings.svg';
  static const String logoutIcon = '${_iconsPath}logout.svg';
  static const String helpIcon = '${_iconsPath}help.svg';
  static const String aboutIcon = '${_iconsPath}about.svg';
  static const String languageIcon = '${_iconsPath}language.svg';
  static const String themeIcon = '${_iconsPath}theme.svg';
  static const String notificationBellIcon = '${_iconsPath}notification_bell.svg';
  static const String medicineIcon = '${_iconsPath}medicine.svg';
  static const String pillIcon = '${_iconsPath}pil l.svg';
  static const String syringeIcon = '${_iconsPath}syringe.svg';
  static const String bloodPressureIcon = '${_iconsPath}blood_pressure.svg';
  static const String heartRateIcon = '${_iconsPath}heart_rate.svg';
  static const String bloodSugarIcon = '${_iconsPath}blood_sugar.svg';
  static const String weightIcon = '${_iconsPath}weight.svg';
  static const String heightIcon = '${_iconsPath}height.svg';
  static const String waterIcon = '${_iconsPath}water.svg';
  static const String sleepIcon = '${_iconsPath}sleep.svg';
  static const String stepsIcon = '${_iconsPath}steps.svg';
  static const String caloriesIcon = '${_iconsPath}calories.svg';
  static const String reportIcon = '${_iconsPath}report.svg';
  static const String pdfIcon = '${_iconsPath}pdf.svg';
  static const String excelIcon = '${_iconsPath}excel.svg';
  static const String printIcon = '${_iconsPath}print.svg';
  static const String scanIcon = '${_iconsPath}scan.svg';
  static const String qrIcon = '${_iconsPath}qr.svg';
  static const String verifyIcon = '${_iconsPath}verify.svg';
  static const String shieldIcon = '${_iconsPath}shield.svg';
  static const String lockIcon = '${_iconsPath}lock.svg';
  static const String unlockIcon = '${_iconsPath}unlock.svg';
  static const String fingerprintIcon = '${_iconsPath}fingerprint.svg';
  static const String faceIdIcon = '${_iconsPath}face_id.svg';
  static const String infoIcon = '${_iconsPath}info.svg';
  static const String warningIcon = '${_iconsPath}warning.svg';
  static const String errorIcon = '${_iconsPath}error.svg';
  static const String successIcon = '${_iconsPath}success.svg';
  static const String refreshIcon = '${_iconsPath}refresh.svg';
  static const String filterSlidersIcon = '${_iconsPath}filter_sliders.svg';
  static const String sortIcon = '${_iconsPath}sort.svg';
  static const String mapIcon = '${_iconsPath}map.svg';
  static const String directionsIcon = '${_iconsPath}directions.svg';
  static const String callIcon = '${_iconsPath}call.svg';
  static const String videoCallIcon = '${_iconsPath}video_call.svg';
  static const String audioCallIcon = '${_iconsPath}audio_call.svg';
  static const String chatIcon = '${_iconsPath}chat.svg';
  static const String sendIcon = '${_iconsPath}send.svg';
  static const String attachmentIcon = '${_iconsPath}attachment.svg';
  static const String microphoneIcon = '${_iconsPath}microphone.svg';
  static const String playIcon = '${_iconsPath}play.svg';
  static const String pauseIcon = '${_iconsPath}pause.svg';
  static const String stopIcon = '${_iconsPath}stop.svg';
  static const String nextIcon = '${_iconsPath}next.svg';
  static const String previousIcon = '${_iconsPath}previous.svg';
  static const String volumeUpIcon = '${_iconsPath}volume_up.svg';
  static const String volumeDownIcon = '${_iconsPath}volume_down.svg';
  static const String muteIcon = '${_iconsPath}mute.svg';
  static const String fullScreenIcon = '${_iconsPath}fullscreen.svg';
  static const String exitFullScreenIcon = '${_iconsPath}exit_fullscreen.svg';
  static const String rotateIcon = '${_iconsPath}rotate.svg';
  
  // ============================================================
  // 📸 أيقونات PNG الجديدة (من مجلد images/)
  // ============================================================
  
  // ✅ أيقونات الخدمات
  static const String servicePharmacy = '${_imagesPath}services/pharmacy.png';
  static const String serviceEmergency = '${_imagesPath}services/emergency.png';
  static const String serviceMedicalCommunity = '${_imagesPath}services/medical_community.png';
  static const String serviceBloodDonation = '${_imagesPath}services/blood_donation.png';
  static const String serviceConsultation = '${_imagesPath}services/consultation.png';
  static const String serviceMedicalRecords = '${_imagesPath}services/medical_records.png';
  static const String serviceNotifications = '${_imagesPath}services/notifications.png';
  static const String serviceWallet = '${_imagesPath}services/wallet.png';
  static const String serviceHealthTips = '${_imagesPath}services/health_tips.png';
  static const String serviceLaboratory = '${_imagesPath}services/laboratory.png';
  static const String serviceMapLocation = '${_imagesPath}services/map_location.png';
  static const String serviceCalendarBooking = '${_imagesPath}services/calendar_booking.png';
  static const String serviceHealthInsurance = '${_imagesPath}services/health_insurance.png';
  static const String serviceVideoConsultation = '${_imagesPath}services/video_consultation.png';
  static const String serviceAiAssistant = '${_imagesPath}services/ai_assistant.png';
  
  // ✅ أيقونات الدردشة
  static const String chatAudioRecord = '${_imagesPath}chat/audio_record.png';
  static const String chatCalendarBooking = '${_imagesPath}chat/calendar_booking.png';
  static const String chatBubble = '${_imagesPath}chat/chat_bubble.png';
  static const String chatMicrophone = '${_imagesPath}chat/microphone.png';
  static const String chatPhoneCall = '${_imagesPath}chat/phone_call.png';
  static const String chatPlayButton = '${_imagesPath}chat/play_button.png';
  static const String chatVideoCall = '${_imagesPath}chat/video_call.png';
  
  // ✅ أيقونات السوشيال ميديا
  static const String socialGoogle = '${_imagesPath}social/google.png';
  static const String socialApple = '${_imagesPath}social/apple.png';
  static const String socialInstagram = '${_imagesPath}social/instagram.png';
  static const String socialTwitter = '${_imagesPath}social/x_twitter.png';
  static const String socialFacebook = '${_imagesPath}social/facebook.png';
  static const String socialYoutube = '${_imagesPath}social/youtube.png';
  static const String socialTiktok = '${_imagesPath}social/tiktok.png';
  
  // ✅ أيقونات التتبع
  static const String trackingAmbulance = '${_imagesPath}tracking/ambulance.png';
  static const String trackingBloodPressure = '${_imagesPath}tracking/blood_pressure.png';
  static const String trackingBloodSugar = '${_imagesPath}tracking/blood_sugar.png';
  static const String trackingFitness = '${_imagesPath}tracking/fitness.png';
  static const String trackingMedicalReport = '${_imagesPath}tracking/medical_report.png';
  static const String trackingMentalHealth = '${_imagesPath}tracking/mental_health.png';
  static const String trackingNutrition = '${_imagesPath}tracking/nutrition.png';
  static const String trackingVaccination = '${_imagesPath}tracking/vaccination.png';
  static const String trackingWeight = '${_imagesPath}tracking/weight_tracking.png';
  
  // ============================================================
  // 🏥 صور الأطباء والمستشفيات
  // ============================================================
  static const String doctor1 = '${_imagesPath}doctors/doctor_1.png';
  static const String doctor2 = '${_imagesPath}doctors/doctor_2.png';
  static const String doctor3 = '${_imagesPath}doctors/doctor_3.png';
  static const String doctor4 = '${_imagesPath}doctors/doctor_4.png';
  static const String doctor5 = '${_imagesPath}doctors/doctor_5.png';
  
  static const String hospital1 = '${_imagesPath}hospitals/hospital_1.png';
  static const String hospital2 = '${_imagesPath}hospitals/hospital_2.png';
  static const String hospital3 = '${_imagesPath}hospitals/hospital_3.png';
  static const String hospital4 = '${_imagesPath}hospitals/hospital_4.png';
  static const String hospital5 = '${_imagesPath}hospitals/hospital_5.png';
  static const String hospital6 = '${_imagesPath}hospitals/hospital_6.png';
  static const String hospital7 = '${_imagesPath}hospitals/hospital_7.png';
  static const String hospital8 = '${_imagesPath}hospitals/hospital_8.png';
  static const String hospital9 = '${_imagesPath}hospitals/hospital_9.png';
  
  // ============================================================
  // 💊 صور الأدوية والصيدليات والمختبرات
  // ============================================================
  static const String medicine1 = '${_imagesPath}medicines/medicine_1.png';
  static const String medicine2 = '${_imagesPath}medicines/medicine_2.png';
  static const String medicine3 = '${_imagesPath}medicines/medicine_3.png';
  static const String medicine4 = '${_imagesPath}medicines/medicine_4.png';
  
  static const String pharmacy1 = '${_imagesPath}pharmacies/pharmacy_1.png';
  static const String pharmacy2 = '${_imagesPath}pharmacies/pharmacy_2.png';
  static const String pharmacy3 = '${_imagesPath}pharmacies/pharmacy_3.png';
  
  static const String lab1 = '${_imagesPath}labs/lab_1.png';
  static const String lab2 = '${_imagesPath}labs/lab_2.png';
  static const String lab3 = '${_imagesPath}labs/lab_3.png';
  
  // ============================================================
  // 🖼️ البانرات والمنشورات
  // ============================================================
  static const String banner1 = '${_imagesPath}banners/banner_1.png';
  static const String banner2 = '${_imagesPath}banners/banner_2.png';
  static const String banner3 = '${_imagesPath}banners/banner_3.png';
  static const String banner4 = '${_imagesPath}banners/banner_4.png';
  
  static const String postMorningWalk = '${_imagesPath}posts/morning_walk.png';
  static const String postImmuneBoost = '${_imagesPath}posts/immune_boost.png';
  static const String postSleepTips = '${_imagesPath}posts/sleep_tips.png';
  static const String postSkinCare = '${_imagesPath}posts/skin_care.png';
  static const String postNutritionTips = '${_imagesPath}posts/nutrition_tips.png';
}
