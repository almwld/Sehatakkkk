import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية للمجلدات
  // ============================================================
  static const String _baseIcons = 'assets/icons';
  static const String _baseImages = 'assets/images';
  static const String _banners = '$_baseImages/banners';
  static const String _doctors = '$_baseImages/doctors';
  static const String _medicines = '$_baseImages/medicines';
  static const String _pharmacies = '$_baseImages/pharmacies';
  static const String _labs = '$_baseImages/labs';
  static const String _hospitals = '$_baseImages/hospitals';
  static const String _delivery = '$_baseImages/delivery';
  static const String _posts = '$_baseImages/posts';
  static const String _services = '$_baseIcons/services';

  // ============================================================
  // 🖼️ البانرات (Banners) - 4 صور
  // ============================================================
  static const String banner1 = '$_banners/banner_1.png';
  static const String banner2 = '$_banners/banner_2.png';
  static const String banner3 = '$_banners/banner_3.png';
  static const String banner4 = '$_banners/banner_4.png';

  static final List<String> bannerList = [banner1, banner2, banner3, banner4];

  static final List<Map<String, dynamic>> bannerData = [
    {'image': banner1},
    {'image': banner2},
    {'image': banner3},
    {'image': banner4},
  ];

  // ============================================================
  // 👨‍⚕️ صور الأطباء (Doctors) - Placeholder SVG
  // ============================================================
  static const String doctorPlaceholder = '$_doctors/doctor_placeholder.svg';
  static const String doctorFemalePlaceholder = '$_doctors/doctor_female_placeholder.svg';

  // ✅ صور الأطباء الافتراضية (تستخدم حتى يرفع الأطباء صورهم)
  static const String doctor1 = '$_doctors/doctor_1.png';
  static const String doctor2 = '$_doctors/doctor_2.png';
  static const String doctor3 = '$_doctors/doctor_3.png';
  static const String doctor4 = '$_doctors/doctor_4.png';
  static const String doctor5 = '$_doctors/doctor_5.png';

  static final List<String> doctorList = [
    doctor1, doctor2, doctor3, doctor4, doctor5,
  ];

  // ============================================================
  // 💊 صور الأدوية (Medicines) - 4 صور
  // ============================================================
  static const String medicine1 = '$_medicines/medicine_1.png';
  static const String medicine2 = '$_medicines/medicine_2.png';
  static const String medicine3 = '$_medicines/medicine_3.png';
  static const String medicine4 = '$_medicines/medicine_4.png';

  static final List<String> medicineList = [
    medicine1, medicine2, medicine3, medicine4,
  ];

  // ============================================================
  // 💊 صور الصيدليات (Pharmacies) - 3 صور
  // ============================================================
  static const String pharmacy1 = '$_pharmacies/pharmacy_1.png';
  static const String pharmacy2 = '$_pharmacies/pharmacy_2.png';
  static const String pharmacy3 = '$_pharmacies/pharmacy_3.png';

  static final List<String> pharmacyList = [
    pharmacy1, pharmacy2, pharmacy3,
  ];

  // ============================================================
  // 🔬 صور المختبرات (Labs) - 3 صور
  // ============================================================
  static const String lab1 = '$_labs/lab_1.png';
  static const String lab2 = '$_labs/lab_2.png';
  static const String lab3 = '$_labs/lab_3.png';

  static final List<String> labList = [
    lab1, lab2, lab3,
  ];

  // ============================================================
  // 🏥 صور المستشفيات (Hospitals) - 9 صور
  // ============================================================
  static const String hospital1 = '$_hospitals/hospital_1.png';
  static const String hospital2 = '$_hospitals/hospital_2.png';
  static const String hospital3 = '$_hospitals/hospital_3.png';
  static const String hospital4 = '$_hospitals/hospital_4.png';
  static const String hospital5 = '$_hospitals/hospital_5.png';
  static const String hospital6 = '$_hospitals/hospital_6.png';
  static const String hospital7 = '$_hospitals/hospital_7.png';
  static const String hospital8 = '$_hospitals/hospital_8.png';
  static const String hospital9 = '$_hospitals/hospital_9.png';

  static final List<String> hospitalList = [
    hospital1, hospital2, hospital3, hospital4, hospital5,
    hospital6, hospital7, hospital8, hospital9,
  ];

  // ============================================================
  // 🚚 صور التوصيل (Delivery) - 4 صور
  // ============================================================
  static const String delivery1 = '$_delivery/delivery_1.png';
  static const String delivery2 = '$_delivery/delivery_2.png';
  static const String delivery3 = '$_delivery/delivery_3.png';
  static const String delivery4 = '$_delivery/delivery_4.png';

  static final List<String> deliveryList = [
    delivery1, delivery2, delivery3, delivery4,
  ];

  // ============================================================
  // 📝 منشورات الأطباء (Posts) - 5 صور
  // ============================================================
  static const String post1 = '$_posts/post_1.png';
  static const String post2 = '$_posts/post_2.png';
  static const String post3 = '$_posts/post_3.png';
  static const String post4 = '$_posts/post_4.png';
  static const String post5 = '$_posts/post_5.png';

  static final List<String> postList = [
    post1, post2, post3, post4, post5,
  ];

  // ============================================================
  // 🎨 أيقونات الخدمات (Services Icons) - 12 أيقونة
  // ============================================================
  static const String iconDoctors = '$_services/doctors.png';
  static const String iconPharmacy = '$_services/pharmacy.png';
  static const String iconNearby = '$_services/nearby.png';
  static const String iconInsurance = '$_services/insurance.png';
  static const String iconRating = '$_services/rating.png';
  static const String iconHeartHealth = '$_services/heart_health.png';
  static const String iconYourDoctor = '$_services/your_doctor.png';
  static const String iconVideoChat = '$_services/video_chat.png';
  static const String iconWallet = '$_services/wallet.png';
  static const String iconLabs = '$_services/labs.png';
  static const String iconMessages = '$_services/messages.png';
  static const String iconAppointments = '$_services/appointments.png';

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
  // 🧭 الشريط السفلي - 7 أيقونات (SVG)
  // ============================================================
  static final List<Map<String, dynamic>> navItems = [
    {'icon': 'assets/icons/navigation/home.svg', 'label': 'الرئيسية'},
    {'icon': 'assets/icons/navigation/doctor.svg', 'label': 'الأطباء'},
    {'icon': 'assets/icons/navigation/pharmacy.svg', 'label': 'الصيدلية'},
    {'icon': 'assets/icons/navigation/chat.svg', 'label': 'الدردشة'},
    {'icon': 'assets/icons/navigation/calendar.svg', 'label': 'مواعيدي'},
    {'icon': 'assets/icons/navigation/health_record.svg', 'label': 'صحتي'},
    {'icon': 'assets/icons/navigation/more.svg', 'label': 'المزيد'},
  ];

  // ============================================================
  // 💳 أيقونات الدفع (Payment Icons)
  // ============================================================
  static const String payJawaliSvg = 'assets/icons/payment/jawali.svg';
  static const String payFloosakSvg = 'assets/icons/payment/floosak.svg';
  static const String payJeebSvg = 'assets/icons/payment/jeeb.svg';
  static const String payKashSvg = 'assets/icons/payment/kash.svg';
  static const String payEasySvg = 'assets/icons/payment/easy.svg';

  static const String iconJawaliPng = 'assets/icons/payment/Jawali_icon.png';
  static const String iconYemenWalletPng = 'assets/icons/payment/Yemen Wallet_icon.png';
  static const String iconFloosakPng = 'assets/icons/payment/floosak_icon.png';
  static const String iconKuraimiPng = 'assets/icons/payment/الكريمي جوال_icon.png';
  static const String iconEasyPng = 'assets/icons/payment/ايزي_icon.png';
  static const String iconJeebPng = 'assets/icons/payment/جيب_icon.png';
  static const String iconKashOnePng = 'assets/icons/payment/كاش ONE_icon.png';
  static const String iconKashPng = 'assets/icons/payment/كاش_icon.png';
  static const String iconMobileMoneyPng = 'assets/icons/payment/موبايل موني انترنت_icon.png';

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

  static Widget coreIcon(String name) {
    return svgIcon('assets/icons/core/$name.svg');
  }

  static Widget navIcon(String name) {
    return svgIcon('assets/icons/navigation/$name.svg');
  }

  static Widget specialtyIcon(String name) {
    return svgIcon('assets/icons/specialties/$name.svg');
  }

  static Widget miniSpecialtyIcon(String name) {
    return svgIcon('assets/icons/mini_specialties/$name.svg');
  }

  static Widget socialIcon(String name) {
    return svgIcon('assets/icons/social/$name.svg');
  }
}
