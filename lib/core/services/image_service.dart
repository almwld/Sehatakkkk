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

  // ============================================================
  // 🖼️ البانرات
  // ============================================================
  static const String banner1 = '$_banners/banner_1.png';
  static const String banner2 = '$_banners/banner_2.png';
  static const String banner3 = '$_banners/banner_3.png';

  static final List<Map<String, dynamic>> bannerData = [
    {'image': banner1},
    {'image': banner2},
    {'image': banner3},
  ];

  // ============================================================
  // 🧭 الشريط السفلي - 7 أيقونات
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
  // 👨‍⚕️ صور الأطباء (Placeholder)
  // ============================================================
  static const String doctor1 = '$_baseImages/placeholder.png';
  static const String doctor2 = '$_baseImages/placeholder.png';
  static const String doctor3 = '$_baseImages/placeholder.png';
  static const String doctor4 = '$_baseImages/placeholder.png';
  static const String doctor5 = '$_baseImages/placeholder.png';
  static const String doctor6 = '$_baseImages/placeholder.png';
  static const String doctor7 = '$_baseImages/placeholder.png';
  static const String doctor8 = '$_baseImages/placeholder.png';

  // ============================================================
  // 💊 صور الأدوية (Placeholder)
  // ============================================================
  static const String medicine1 = '$_baseImages/placeholder.png';
  static const String medicine2 = '$_baseImages/placeholder.png';
  static const String medicine3 = '$_baseImages/placeholder.png';
  static const String medicine4 = '$_baseImages/placeholder.png';
  static const String medicine5 = '$_baseImages/placeholder.png';
  static const String medicine6 = '$_baseImages/placeholder.png';
  static const String medicine7 = '$_baseImages/placeholder.png';
  static const String medicine8 = '$_baseImages/placeholder.png';
  static const String medicine9 = '$_baseImages/placeholder.png';
  static const String medicine10 = '$_baseImages/placeholder.png';

  // ============================================================
  // 🏥 الصيدليات والمختبرات (Placeholder)
  // ============================================================
  static const String pharmacy1 = '$_baseImages/placeholder.png';
  static const String pharmacy2 = '$_baseImages/placeholder.png';
  static const String lab1 = '$_baseImages/placeholder.png';

  // ============================================================
  // 💳 أيقونات الدفع (Payment Icons)
  // ============================================================
  static const String payJawaliSvg = 'assets/icons/payment/jawali.svg';
  static const String payFloosakSvg = 'assets/icons/payment/floosak.svg';
  static const String payJeebSvg = 'assets/icons/payment/jeeb.svg';
  static const String payKashSvg = 'assets/icons/payment/kash.svg';
  static const String payEasySvg = 'assets/icons/payment/easy.svg';
  
  // ✅ PNG icons - إضافة الثوابت المفقودة
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

  // ✅ دالة مساعدة للأيقونات
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
