import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية
  // ============================================================
  static const String _baseIcons = 'assets/icons';
  static const String _baseImages = 'assets/images';

  // ============================================================
  // 🖼️ البانرات (Banners) - 4 صور
  // ============================================================
  static const String banner1 = '$_baseImages/banners/banner_1.png';
  static const String banner2 = '$_baseImages/banners/banner_2.png';
  static const String banner3 = '$_baseImages/banners/banner_3.png';
  static const String banner4 = '$_baseImages/banners/banner_4.png';

  static final List<String> bannerList = [banner1, banner2, banner3, banner4];

  static final List<Map<String, dynamic>> bannerData = [
    {'image': banner1},
    {'image': banner2},
    {'image': banner3},
    {'image': banner4},
  ];

  // ============================================================
  // 👨‍⚕️ صور الأطباء (Doctors)
  // ============================================================
  static const String doctor1 = '$_baseImages/doctors/doctor_1.png';
  static const String doctor2 = '$_baseImages/doctors/doctor_2.png';
  static const String doctor3 = '$_baseImages/doctors/doctor_3.png';
  static const String doctor4 = '$_baseImages/doctors/doctor_4.png';
  static const String doctor5 = '$_baseImages/doctors/doctor_5.png';
  static const String doctorPlaceholder = '$_baseImages/doctors/doctor_placeholder.svg';
  static const String doctorFemalePlaceholder = '$_baseImages/doctors/doctor_female_placeholder.svg';

  static final List<String> doctorList = [doctor1, doctor2, doctor3, doctor4, doctor5];

  // ============================================================
  // 💊 صور الأدوية (Medicines)
  // ============================================================
  static const String medicine1 = '$_baseImages/medicines/medicine_1.png';
  static const String medicine2 = '$_baseImages/medicines/medicine_2.png';
  static const String medicine3 = '$_baseImages/medicines/medicine_3.png';
  static const String medicine4 = '$_baseImages/medicines/medicine_4.png';
  static const String medicine5 = '$_baseImages/medicines/medicine_1.png';
  static const String medicine6 = '$_baseImages/medicines/medicine_2.png';
  static const String medicine7 = '$_baseImages/medicines/medicine_3.png';
  static const String medicine8 = '$_baseImages/medicines/medicine_4.png';
  static const String medicine9 = '$_baseImages/medicines/medicine_1.png';
  static const String medicine10 = '$_baseImages/medicines/medicine_2.png';

  static final List<String> medicineList = [
    medicine1, medicine2, medicine3, medicine4,
    medicine5, medicine6, medicine7, medicine8,
    medicine9, medicine10,
  ];

  // ============================================================
  // 💊 صور الصيدليات (Pharmacies)
  // ============================================================
  static const String pharmacy1 = '$_baseImages/pharmacies/pharmacy_1.png';
  static const String pharmacy2 = '$_baseImages/pharmacies/pharmacy_2.png';
  static const String pharmacy3 = '$_baseImages/pharmacies/pharmacy_3.png';
  static final List<String> pharmacyList = [pharmacy1, pharmacy2, pharmacy3];

  // ============================================================
  // 🔬 صور المختبرات (Labs)
  // ============================================================
  static const String lab1 = '$_baseImages/labs/lab_1.png';
  static const String lab2 = '$_baseImages/labs/lab_2.png';
  static const String lab3 = '$_baseImages/labs/lab_3.png';
  static final List<String> labList = [lab1, lab2, lab3];

  // ============================================================
  // 🏥 صور المستشفيات (Hospitals)
  // ============================================================
  static const String hospital1 = '$_baseImages/hospitals/hospital_1.png';
  static const String hospital2 = '$_baseImages/hospitals/hospital_2.png';
  static const String hospital3 = '$_baseImages/hospitals/hospital_3.png';
  static const String hospital4 = '$_baseImages/hospitals/hospital_4.png';
  static const String hospital5 = '$_baseImages/hospitals/hospital_5.png';
  static const String hospital6 = '$_baseImages/hospitals/hospital_6.png';
  static const String hospital7 = '$_baseImages/hospitals/hospital_7.png';
  static const String hospital8 = '$_baseImages/hospitals/hospital_8.png';
  static const String hospital9 = '$_baseImages/hospitals/hospital_9.png';
  static final List<String> hospitalList = [
    hospital1, hospital2, hospital3, hospital4, hospital5,
    hospital6, hospital7, hospital8, hospital9,
  ];

  // ============================================================
  // 🚚 صور التوصيل (Delivery)
  // ============================================================
  static const String delivery1 = '$_baseImages/delivery/delivery_1.png';
  static const String delivery2 = '$_baseImages/delivery/delivery_2.png';
  static const String delivery3 = '$_baseImages/delivery/delivery_3.png';
  static const String delivery4 = '$_baseImages/delivery/delivery_4.png';
  static final List<String> deliveryList = [delivery1, delivery2, delivery3, delivery4];

  // ============================================================
  // 📝 منشورات الأطباء (Posts)
  // ============================================================
  static const String post1 = '$_baseImages/posts/post_1.png';
  static const String post2 = '$_baseImages/posts/post_2.png';
  static const String post3 = '$_baseImages/posts/post_3.png';
  static const String post4 = '$_baseImages/posts/post_4.png';
  static const String post5 = '$_baseImages/posts/post_5.png';
  static final List<String> postList = [post1, post2, post3, post4, post5];

  // ============================================================
  // 🎨 أيقونات الخدمات (Services Icons) - 12 أيقونة
  // ============================================================
  static const String iconDoctors = '$_baseIcons/services/أطباء.png';
  static const String iconPharmacy = '$_baseIcons/services/ادويه.png';
  static const String iconNearby = '$_baseIcons/services/بالقرب مني .png';
  static const String iconInsurance = '$_baseIcons/services/تامين.png';
  static const String iconRating = '$_baseIcons/services/تقييم.png';
  static const String iconHeartHealth = '$_baseIcons/services/صحةالقلب.png';
  static const String iconYourDoctor = '$_baseIcons/services/طبيبك.png';
  static const String iconVideoChat = '$_baseIcons/services/محادثات للمعارف.png';
  static const String iconWallet = '$_baseIcons/services/محفظ.png';
  static const String iconLabs = '$_baseIcons/services/مخابر.png';
  static const String iconMessages = '$_baseIcons/services/مراسلات.png';
  static const String iconAppointments = '$_baseIcons/services/مواعيد.png';

  static final List<Map<String, String>> serviceIcons = [
    {'path': iconDoctors, 'label': 'أطباء'},
    {'path': iconPharmacy, 'label': 'صيدلية'},
    {'path': iconLabs, 'label': 'مختبرات'},
    {'path': iconNearby, 'label': 'بالقرب مني'},
    {'path': iconInsurance, 'label': 'تأمين'},
    {'path': iconRating, 'label': 'تقييم'},
    {'path': iconHeartHealth, 'label': 'صحة القلب'},
    {'path': iconYourDoctor, 'label': 'طبيبك'},
    {'path': iconVideoChat, 'label': 'محادثات'},
    {'path': iconWallet, 'label': 'محفظة'},
    {'path': iconMessages, 'label': 'مراسلات'},
    {'path': iconAppointments, 'label': 'مواعيد'},
  ];

  // ============================================================
  // 🧭 الشريط السفلي - أيقونات التنقل (SVG)
  // ============================================================
  static const String navHome = '$_baseIcons/navigation/home.svg';
  static const String navDoctor = '$_baseIcons/navigation/doctor.svg';
  static const String navPharmacy = '$_baseIcons/navigation/pharmacy.svg';
  static const String navChat = '$_baseIcons/navigation/chat.svg';
  static const String navCalendar = '$_baseIcons/navigation/calendar.svg';
  static const String navHealthRecord = '$_baseIcons/navigation/health_record.svg';
  static const String navMore = '$_baseIcons/navigation/more.svg';
  static const String navBlood = '$_baseIcons/navigation/blood.svg';
  static const String navEmergency = '$_baseIcons/navigation/emergency.svg';
  static const String navVideoCall = '$_baseIcons/navigation/video_call.svg';

  static final List<Map<String, dynamic>> navItems = [
    {'icon': navHome, 'label': 'الرئيسية'},
    {'icon': navDoctor, 'label': 'الأطباء'},
    {'icon': navPharmacy, 'label': 'الصيدلية'},
    {'icon': navChat, 'label': 'الدردشة'},
    {'icon': navCalendar, 'label': 'مواعيدي'},
    {'icon': navHealthRecord, 'label': 'صحتي'},
    {'icon': navMore, 'label': 'المزيد'},
  ];

  // ============================================================
  // ⚡ أيقونات النواة (Core) - جميع الأيقونات
  // ============================================================
  static const String coreHome = '$_baseIcons/core/home.svg';
  static const String coreDoctor = '$_baseIcons/core/doctor.svg';
  static const String corePharmacy = '$_baseIcons/core/pharmacy.svg';
  static const String coreChat = '$_baseIcons/core/text_chat.svg';
  static const String coreVideoCall = '$_baseIcons/core/video_call.svg';
  static const String coreAppointments = '$_baseIcons/core/appointments.svg';
  static const String coreBloodTest = '$_baseIcons/core/blood_test.svg';
  static const String coreEmergency = '$_baseIcons/core/emergency.svg';
  static const String coreHealthRecord = '$_baseIcons/core/health_record.svg';
  static const String coreMoreMenu = '$_baseIcons/core/more_menu.svg';
  static const String coreNotifications = '$_baseIcons/core/notifications_active.svg';

  // ============================================================
  // 🔬 أيقونات التخصصات (Specialties)
  // ============================================================
  static const String specCardiology = '$_baseIcons/specialties/cardiology.svg';
  static const String specDentistry = '$_baseIcons/specialties/dentistry.svg';
  static const String specDermatology = '$_baseIcons/specialties/dermatology.svg';
  static const String specGastroenterology = '$_baseIcons/specialties/gastroenterology.svg';
  static const String specNeurology = '$_baseIcons/specialties/neurology.svg';
  static const String specNutrition = '$_baseIcons/specialties/nutrition.svg';
  static const String specOncology = '$_baseIcons/specialties/oncology.svg';
  static const String specOphthalmology = '$_baseIcons/specialties/ophthalmology.svg';
  static const String specOrthopedic = '$_baseIcons/specialties/orthopedic.svg';
  static const String specPediatrics = '$_baseIcons/specialties/pediatrics.svg';
  static const String specPsychiatry = '$_baseIcons/specialties/psychiatry.svg';
  static const String specPulmonology = '$_baseIcons/specialties/pulmonology.svg';
  static const String specRadiology = '$_baseIcons/specialties/radiology.svg';
  static const String specUrology = '$_baseIcons/specialties/urology.svg';

  // ============================================================
  // 🧬 أيقونات التخصصات المصغرة (Mini Specialties)
  // ============================================================
  static const String miniBaby = '$_baseIcons/mini_specialties/baby.svg';
  static const String miniBone = '$_baseIcons/mini_specialties/bone.svg';
  static const String miniBrain = '$_baseIcons/mini_specialties/brain.svg';
  static const String miniDna = '$_baseIcons/mini_specialties/dna.svg';
  static const String miniEye = '$_baseIcons/mini_specialties/eye.svg';
  static const String miniHeart = '$_baseIcons/mini_specialties/heart.svg';
  static const String miniKidney = '$_baseIcons/mini_specialties/kidney.svg';
  static const String miniLungs = '$_baseIcons/mini_specialties/lungs.svg';
  static const String miniPill = '$_baseIcons/mini_specialties/pill.svg';
  static const String miniStomach = '$_baseIcons/mini_specialties/stomach.svg';
  static const String miniSyringe = '$_baseIcons/mini_specialties/syringe.svg';
  static const String miniTooth = '$_baseIcons/mini_specialties/tooth.svg';

  // ============================================================
  // 📱 أيقونات التواصل الاجتماعي (Social)
  // ============================================================
  static const String socialFacebook = '$_baseIcons/social/facebook.svg';
  static const String socialInstagram = '$_baseIcons/social/instagram.svg';
  static const String socialTwitter = '$_baseIcons/social/twitter.svg';
  static const String socialXTwitter = '$_baseIcons/social/x_twitter.svg';
  static const String socialWhatsapp = '$_baseIcons/social/whatsapp.svg';
  static const String socialLinkedin = '$_baseIcons/social/linkedin.svg';
  static const String socialDiscord = '$_baseIcons/social/discord.svg';
  static const String socialChatModern = '$_baseIcons/social/chat_modern.svg';

  // ============================================================
  // 💰 أيقونات العروض (Offers)
  // ============================================================
  static const String offerDiscount = '$_baseIcons/offers/discount.svg';
  static const String offerFamily = '$_baseIcons/offers/family_offer.svg';
  static const String offerHealthCheck = '$_baseIcons/offers/health_check.svg';

  // ============================================================
  // 🏷️ أيقونات الخطط (Plans)
  // ============================================================
  static const String planFree = '$_baseIcons/plans/free.svg';
  static const String planSilver = '$_baseIcons/plans/silver.svg';
  static const String planGold = '$_baseIcons/plans/gold.svg';
  static const String planPlatinum = '$_baseIcons/plans/platinum.svg';
  static const String planFamily = '$_baseIcons/plans/family.svg';

  // ============================================================
  // 💳 أيقونات الدفع (Payment) - SVG
  // ============================================================
  static const String payJawaliSvg = '$_baseIcons/payment/jawali.svg';
  static const String payFloosakSvg = '$_baseIcons/payment/floosak.svg';
  static const String payJeebSvg = '$_baseIcons/payment/jeeb.svg';
  static const String payKashSvg = '$_baseIcons/payment/kash.svg';
  static const String payEasySvg = '$_baseIcons/payment/easy.svg';

  // ============================================================
  // 💳 أيقونات الدفع (Payment) - PNG
  // ============================================================
  static const String iconJawaliPng = '$_baseIcons/payment/Jawali_icon.png';
  static const String iconYemenWalletPng = '$_baseIcons/payment/Yemen Wallet_icon.png';
  static const String iconFloosakPng = '$_baseIcons/payment/floosak_icon.png';
  static const String iconKuraimiPng = '$_baseIcons/payment/الكريمي جوال_icon.png';
  static const String iconEasyPng = '$_baseIcons/payment/ايزي_icon.png';
  static const String iconJeebPng = '$_baseIcons/payment/جيب_icon.png';
  static const String iconKashOnePng = '$_baseIcons/payment/كاش ONE_icon.png';
  static const String iconKashPng = '$_baseIcons/payment/كاش_icon.png';
  static const String iconMobileMoneyPng = '$_baseIcons/payment/موبايل موني انترنت_icon.png';

  // ============================================================
  // 📋 قائمة الدفع الكاملة (للأستخدام المباشر)
  // ============================================================
  static final List<Map<String, dynamic>> payments = [
    {'id': 'floosak', 'name': 'فلوسك', 'icon': iconFloosakPng, 'color': AppColors.primary},
    {'id': 'jawali', 'name': 'جوالي', 'icon': iconJawaliPng, 'color': AppColors.teal},
    {'id': 'cash', 'name': 'كاش', 'icon': iconKashPng, 'color': AppColors.warning},
    {'id': 'jeeb', 'name': 'جيب', 'icon': iconJeebPng, 'color': AppColors.purple},
    {'id': 'easy', 'name': 'إيزي', 'icon': iconEasyPng, 'color': AppColors.info},
    {'id': 'yemen_wallet', 'name': 'يمن وولت', 'icon': iconYemenWalletPng, 'color': AppColors.success},
    {'id': 'mobile_money', 'name': 'موبايل موني', 'icon': iconMobileMoneyPng, 'color': AppColors.orange},
    {'id': 'cash_one', 'name': 'كاش ONE', 'icon': iconKashOnePng, 'color': AppColors.indigo},
    {'id': 'alkarimi', 'name': 'الكريمي', 'icon': iconKuraimiPng, 'color': AppColors.pink},
  ];

  // ============================================================
  // 🛠️ دوال البناء (Builders)
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

  // ============================================================
  // 🧭 دوال مساعدة للأيقونات
  // ============================================================
  static Widget coreIcon(String name) {
    return svgIcon('$_baseIcons/core/$name.svg');
  }

  static Widget navIcon(String name) {
    return svgIcon('$_baseIcons/navigation/$name.svg');
  }

  static Widget specialtyIcon(String name) {
    return svgIcon('$_baseIcons/specialties/$name.svg');
  }

  static Widget miniSpecialtyIcon(String name) {
    return svgIcon('$_baseIcons/mini_specialties/$name.svg');
  }

  static Widget socialIcon(String name) {
    return svgIcon('$_baseIcons/social/$name.svg');
  }

  static Widget planIcon(String name) {
    return svgIcon('$_baseIcons/plans/$name.svg');
  }

  static Widget offerIcon(String name) {
    return svgIcon('$_baseIcons/offers/$name.svg');
  }

  static Widget paymentIcon(String name) {
    return svgIcon('$_baseIcons/payment/$name.svg');
  }

  static Widget paymentImage(String name) {
    return Image.asset('$_baseIcons/payment/$name', width: 40, height: 40);
  }
}
