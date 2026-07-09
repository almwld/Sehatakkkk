import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية للمجلدات (Base Paths)
  // ============================================================
  static const String _baseIcons = 'assets/icons';
  static const String _baseImages = 'assets/images';

  static const String _consultations = '$_baseIcons/consultations';
  static const String _core = '$_baseIcons/core';
  static const String _miniSpecialties = '$_baseIcons/mini_specialties';
  static const String _navigation = '$_baseIcons/navigation';
  static const String _offers = '$_baseIcons/offers';
  static const String _payment = '$_baseIcons/payment';
  static const String _plans = '$_baseIcons/plans';
  static const String _pngCore = '$_baseIcons/png_core';
  static const String _pngSpecialties = '$_baseIcons/png_specialties';
  static const String _social = '$_baseIcons/social';
  static const String _specialties = '$_baseIcons/specialties';
  static const String _banners = '$_baseImages/banners';

  // ============================================================
  // 🖼️ الصور والبانرات الأساسية
  // ============================================================
  static const String appIcon = '$_baseIcons/app_icon.png';
  static const String placeholder = '$_baseImages/placeholder.png';
  static const String chatBackground = '$_baseImages/chat_background.svg';

  static const String banner1 = '$_banners/banner_1.png';
  static const String banner2 = '$_banners/banner_2.png';
  static const String banner3 = '$_banners/banner_3.png';

  static final List<Map<String, dynamic>> bannerData = [
    {'image': banner1},
    {'image': banner2},
    {'image': banner3},
  ];

  // ============================================================
  // 🧭 قائمة الشريط السفلي - 7 أيقونات (✅ تم التحديث)
  // ============================================================
  static final List<Map<String, dynamic>> navItems = [
    {'icon': '$_navigation/home.svg', 'label': 'الرئيسية'},      // 1️⃣
    {'icon': '$_navigation/doctor.svg', 'label': 'الأطباء'},     // 2️⃣
    {'icon': '$_navigation/pharmacy.svg', 'label': 'الصيدلية'},  // 3️⃣
    {'icon': '$_navigation/chat.svg', 'label': 'الدردشة'},       // 4️⃣ ✅ جديدة
    {'icon': '$_navigation/calendar.svg', 'label': 'مواعيدي'},   // 5️⃣
    {'icon': '$_navigation/health_record.svg', 'label': 'صحتي'}, // 6️⃣ ✅ جديدة
    {'icon': '$_navigation/more.svg', 'label': 'المزيد'},        // 7️⃣
  ];

  // ============================================================
  // 🩺 أيقونات الاستشارات
  // ============================================================
  static const String iconAudio = '$_consultations/audio.svg';
  static const String iconCheckup = '$_consultations/checkup.svg';
  static const String iconEmergencyConsult = '$_consultations/emergency.svg';
  static const String iconHomeVisit = '$_consultations/home_visit.svg';
  static const String iconText = '$_consultations/text.svg';
  static const String iconVideo = '$_consultations/video.svg';

  // ============================================================
  // 🧪 الأيقونات الأساسية
  // ============================================================
  static const String iconAppointments = '$_core/appointments.svg';
  static const String iconBloodTest = '$_core/blood_test.svg';
  static const String iconDoctorCore = '$_core/doctor.svg';
  static const String iconEmergencyCore = '$_core/emergency.svg';
  static const String iconHealthRecord = '$_core/health_record.svg';
  static const String iconHomeCore = '$_core/home.svg';
  static const String iconMoreMenu = '$_core/more_menu.svg';
  static const String iconNotificationsActive = '$_core/notifications_active.svg';
  static const String iconPharmacyCore = '$_core/pharmacy.svg';
  static const String iconTextChat = '$_core/text_chat.svg';
  static const String iconVideoCall = '$_core/video_call.svg';

  // ============================================================
  // 🧬 أيقونات التخصصات المصغرة
  // ============================================================
  static const String miniBaby = '$_miniSpecialties/baby.svg';
  static const String miniBlood = '$_miniSpecialties/blood.svg';
  static const String miniBone = '$_miniSpecialties/bone.svg';
  static const String miniBrain = '$_miniSpecialties/brain.svg';
  static const String miniChat = '$_miniSpecialties/chat.svg';
  static const String miniDna = '$_miniSpecialties/dna.svg';
  static const String miniEye = '$_miniSpecialties/eye.svg';
  static const String miniHealthRecord = '$_miniSpecialties/health_record.svg';
  static const String miniHeart = '$_miniSpecialties/heart.svg';
  static const String miniKidney = '$_miniSpecialties/kidney.svg';
  static const String miniLungs = '$_miniSpecialties/lungs.svg';
  static const String miniPharmacy = '$_miniSpecialties/pharmacy.svg';
  static const String miniPill = '$_miniSpecialties/pill.svg';
  static const String miniStomach = '$_miniSpecialties/stomach.svg';
  static const String miniSyringe = '$_miniSpecialties/syringe.svg';
  static const String miniTooth = '$_miniSpecialties/tooth.svg';

  // ============================================================
  // 🎁 أيقونات العروض
  // ============================================================
  static const String offerDiscount = '$_offers/discount.svg';
  static const String offerFamily = '$_offers/family_offer.svg';
  static const String offerHealthCheck = '$_offers/health_check.svg';

  // ============================================================
  // 💳 أيقونات بوابات الدفع اليمنية
  // ============================================================
  static const String payEasySvg = '$_payment/easy.svg';
  static const String payFloosakSvg = '$_payment/floosak.svg';
  static const String payJawaliSvg = '$_payment/jawali.svg';
  static const String payJeebSvg = '$_payment/jeeb.svg';
  static const String payKashSvg = '$_payment/kash.svg';
  
  static const String iconJawaliPng = '$_payment/Jawali_icon.png';
  static const String iconYemenWalletPng = '$_payment/Yemen Wallet_icon.png';
  static const String iconFloosakPng = '$_payment/floosak_icon.png';
  static const String iconKuraimiPng = '$_payment/الكريمي جوال_icon.png';
  static const String iconEasyPng = '$_payment/ايزي_icon.png';
  static const String iconJeebPng = '$_payment/جيب_icon.png';
  static const String iconKashOnePng = '$_payment/كاش ONE_icon.png';
  static const String iconKashPng = '$_payment/كاش_icon.png';
  static const String iconMobileMoneyPng = '$_payment/موبايل موني انترنت_icon.png';

  // ============================================================
  // 💎 أيقونات باقات التأمين
  // ============================================================
  static const String planFamily = '$_plans/family.svg';
  static const String planFree = '$_plans/free.svg';
  static const String planGold = '$_plans/gold.svg';
  static const String planPlatinum = '$_plans/platinum.svg';
  static const String planSilver = '$_plans/silver.svg';

  // ============================================================
  // 📸 PNG Core
  // ============================================================
  static const String pngBloodTest = '$_pngCore/blood_test.png';
  static const String pngDoctor = '$_pngCore/doctor.png';
  static const String pngEmergency = '$_pngCore/emergency.png';
  static const String pngHealthRecord = '$_pngCore/health_record.png';
  static const String pngHome = '$_pngCore/home.png';
  static const String pngMoreMenu = '$_pngCore/more_menu.png';
  static const String pngNotificationsActive = '$_pngCore/notifications_active.png';
  static const String pngPharmacy = '$_pngCore/pharmacy.png';
  static const String pngTextChat = '$_pngCore/text_chat.png';
  static const String pngVideoCall = '$_pngCore/video_call.png';

  // ============================================================
  // 🩺 PNG Specialties
  // ============================================================
  static const String pngSpecCardiology = '$_pngSpecialties/cardiology.png';
  static const String pngSpecDentistry = '$_pngSpecialties/dentistry.png';
  static const String pngSpecDermatology = '$_pngSpecialties/dermatology.png';
  static const String pngSpecGastroenterology = '$_pngSpecialties/gastroenterology.png';
  static const String pngSpecNeurology = '$_pngSpecialties/neurology.png';
  static const String pngSpecNutrition = '$_pngSpecialties/nutrition.png';
  static const String pngSpecOncology = '$_pngSpecialties/oncology.png';
  static const String pngSpecOphthalmology = '$_pngSpecialties/ophthalmology.png';
  static const String pngSpecOrthopedic = '$_pngSpecialties/orthopedic.png';
  static const String pngSpecPediatrics = '$_pngSpecialties/pediatrics.png';
  static const String pngSpecPsychiatry = '$_pngSpecialties/psychiatry.png';
  static const String pngSpecPulmonology = '$_pngSpecialties/pulmonology.png';
  static const String pngSpecRadiology = '$_pngSpecialties/radiology.png';
  static const String pngSpecUrology = '$_pngSpecialties/urology.png';

  // ============================================================
  // 🌐 أيقونات التواصل الاجتماعي
  // ============================================================
  static const String socialChatModern = '$_social/chat_modern.svg';
  static const String socialDiscord = '$_social/discord.svg';
  static const String socialFacebook = '$_social/facebook.svg';
  static const String socialInstagram = '$_social/instagram.svg';
  static const String socialLinkedin = '$_social/linkedin.svg';
  static const String socialTwitter = '$_social/twitter.svg';
  static const String socialWhatsapp = '$_social/whatsapp.svg';
  static const String socialXTwitter = '$_social/x_twitter.svg';

  // ============================================================
  // ⚕️ SVG Specialties
  // ============================================================
  static const String svgSpecCardiology = '$_specialties/cardiology.svg';
  static const String svgSpecDentistry = '$_specialties/dentistry.svg';
  static const String svgSpecDermatology = '$_specialties/dermatology.svg';
  static const String svgSpecGastroenterology = '$_specialties/gastroenterology.svg';
  static const String svgSpecNeurology = '$_specialties/neurology.svg';
  static const String svgSpecNutrition = '$_specialties/nutrition.svg';
  static const String svgSpecOncology = '$_specialties/oncology.svg';
  static const String svgSpecOphthalmology = '$_specialties/ophthalmology.svg';
  static const String svgSpecOrthopedic = '$_specialties/orthopedic.svg';
  static const String svgSpecPediatric = '$_specialties/pediatric.svg';
  static const String svgSpecPediatrics = '$_specialties/pediatrics.svg';
  static const String svgSpecPsychiatry = '$_specialties/psychiatry.svg';
  static const String svgSpecPulmonology = '$_specialties/pulmonology.svg';
  static const String svgSpecRadiology = '$_specialties/radiology.svg';
  static const String svgSpecUrology = '$_specialties/urology.svg';

  // ============================================================
  // 👨‍⚕️ صور الأطباء (Placeholder مؤقتاً)
  // ============================================================
  static const String doctor1 = '$placeholderBase/doctors/doctor1.jpg';
  static const String doctor2 = '$placeholderBase/doctors/doctor2.jpg';
  static const String doctor3 = '$placeholderBase/doctors/doctor3.jpg';
  static const String doctor4 = '$placeholderBase/doctors/doctor4.jpg';
  static const String doctor5 = '$placeholderBase/doctors/doctor5.jpg';
  static const String doctor6 = '$placeholderBase/doctors/doctor6.jpg';
  static const String doctor7 = '$placeholderBase/doctors/doctor7.jpg';
  static const String doctor8 = '$placeholderBase/doctors/doctor8.jpg';

  // ============================================================
  // 💊 صور الأدوية (Placeholder مؤقتاً)
  // ============================================================
  static const String medicine1 = '$placeholderBase/medications/medicine1.jpg';
  static const String medicine2 = '$placeholderBase/medications/medicine2.jpg';
  static const String medicine3 = '$placeholderBase/medications/medicine3.jpg';
  static const String medicine4 = '$placeholderBase/medications/medicine4.jpg';
  static const String medicine5 = '$placeholderBase/medications/medicine5.jpg';
  static const String medicine6 = '$placeholderBase/medications/medicine6.jpg';
  static const String medicine7 = '$placeholderBase/medications/medicine7.jpg';
  static const String medicine8 = '$placeholderBase/medications/medicine8.jpg';
  static const String medicine9 = '$placeholderBase/medications/medicine9.jpg';
  static const String medicine10 = '$placeholderBase/medications/medicine10.jpg';

  // ============================================================
  // 🏥 الصيدليات والمختبرات (Placeholder مؤقتاً)
  // ============================================================
  static const String pharmacy1 = '$placeholderBase/pharmacies/pharmacy1.jpg';
  static const String pharmacy2 = '$placeholderBase/pharmacies/pharmacy2.jpg';
  static const String lab1 = '$placeholderBase/labs/lab1.jpg';

  // ============================================================
  // 🛠️ دوال البناء
  // ============================================================

  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget imageWithShimmer(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 12,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
        ),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return frame == null
              ? Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.grey.shade300,
                  ),
                )
              : child;
        },
      ),
    );
  }

  static Widget buildBanner(Map<String, dynamic> banner, {double? height}) {
    return imageWithShimmer(
      banner['image'] as String,
      height: height ?? 180,
      borderRadius: 16,
    );
  }
}
