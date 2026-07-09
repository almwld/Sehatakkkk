import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية للمجلدات
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
  // 🖼️ البانرات (Banners) - ✅ مطابقة لأسماء الملفات
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
    {'icon': '$_navigation/home.svg', 'label': 'الرئيسية'},
    {'icon': '$_navigation/doctor.svg', 'label': 'الأطباء'},
    {'icon': '$_navigation/pharmacy.svg', 'label': 'الصيدلية'},
    {'icon': '$_navigation/chat.svg', 'label': 'الدردشة'},
    {'icon': '$_navigation/calendar.svg', 'label': 'مواعيدي'},
    {'icon': '$_navigation/health_record.svg', 'label': 'صحتي'},
    {'icon': '$_navigation/more.svg', 'label': 'المزيد'},
  ];

  // ============================================================
  // 👨‍⚕️ صور الأطباء (Placeholder مؤقتاً)
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
  // 💊 صور الأدوية (Placeholder مؤقتاً)
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
  // 🏥 الصيدليات والمختبرات (Placeholder مؤقتاً)
  // ============================================================
  static const String pharmacy1 = '$_baseImages/placeholder.png';
  static const String pharmacy2 = '$_baseImages/placeholder.png';
  static const String lab1 = '$_baseImages/placeholder.png';

  // ============================================================
  // 📌 أيقونات SVG
  // ============================================================
  static String coreIcon(String name) => '$_core/$name.svg';
  static String navIcon(String name) => '$_navigation/$name.svg';
  static String specialtyIcon(String name) => '$_specialties/$name.svg';
  static String miniIcon(String name) => '$_miniSpecialties/$name.svg';
  static String socialIcon(String name) => '$_social/$name.svg';

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
