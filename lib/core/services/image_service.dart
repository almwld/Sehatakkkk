import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية للمجلدات
  // ============================================================
  static const String _banners = 'assets/images/banners';
  static const String _images = 'assets/images';
  static const String _iconsCore = 'assets/icons/core';
  static const String _iconsNav = 'assets/icons/navigation';
  static const String _iconsSpecialties = 'assets/icons/specialties';
  static const String _iconsMini = 'assets/icons/mini_specialties';
  static const String _iconsSocial = 'assets/icons/social';

  // ============================================================
  // 🖼️ البانرات (Banners) - الصور الموجودة
  // ============================================================
  static const String banner1 = '$_banners/banner_1.png';
  static const String banner2 = '$_banners/banner_2.png';
  static const String banner3 = '$_banners/banner_3.png';

  static final List<Map<String, dynamic>> bannerData = [
    {'image': banner1},
    {'image': banner2},
    {'image': banner3},
    {'image': banner1},
  ];

  // ============================================================
  // 👨‍⚕️ صور الأطباء (Doctor Avatars)
  // ============================================================
  static const String doctor1 = '$_images/doctors/doctor1.jpg';
  static const String doctor2 = '$_images/doctors/doctor2.jpg';
  static const String doctor3 = '$_images/doctors/doctor3.jpg';
  static const String doctor4 = '$_images/doctors/doctor4.jpg';
  static const String doctor5 = '$_images/doctors/doctor5.jpg';
  static const String doctor6 = '$_images/doctors/doctor6.jpg';
  static const String doctor7 = '$_images/doctors/doctor7.jpg';
  static const String doctor8 = '$_images/doctors/doctor8.jpg';

  static List<String> get doctorImages => [
    doctor1, doctor2, doctor3, doctor4,
    doctor5, doctor6, doctor7, doctor8
  ];

  // ============================================================
  // 💊 صور الأدوية والمنتجات
  // ============================================================
  static const String medicine1 = '$_images/medications/medicine1.jpg';
  static const String medicine2 = '$_images/medications/medicine2.jpg';
  static const String medicine3 = '$_images/medications/medicine3.jpg';
  static const String medicine4 = '$_images/medications/medicine4.jpg';
  static const String medicine5 = '$_images/medications/medicine5.jpg';
  static const String medicine6 = '$_images/medications/medicine6.jpg';
  static const String medicine7 = '$_images/medications/medicine7.jpg';
  static const String medicine8 = '$_images/medications/medicine8.jpg';
  static const String medicine9 = '$_images/medications/medicine9.jpg';
  static const String medicine10 = '$_images/medications/medicine10.jpg';

  // ============================================================
  // 🏥 الصيدليات والمختبرات
  // ============================================================
  static const String pharmacy1 = '$_images/pharmacies/pharmacy1.jpg';
  static const String pharmacy2 = '$_images/pharmacies/pharmacy2.jpg';
  static const String lab1 = '$_images/labs/lab1.jpg';

  // ============================================================
  // 📌 أيقونات SVG
  // ============================================================
  static String coreIcon(String name) => '$_iconsCore/$name.svg';
  static String navIcon(String name) => '$_iconsNav/$name.svg';
  static String specialtyIcon(String name) => '$_iconsSpecialties/$name.svg';
  static String miniIcon(String name) => '$_iconsMini/$name.svg';
  static String socialIcon(String name) => '$_iconsSocial/$name.svg';

  // ============================================================
  // 🎯 عرض البانر مع Shimmer
  // ============================================================
  static Widget buildBanner(Map<String, dynamic> banner, {double? height}) {
    return Container(
      height: height ?? 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              banner['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
              ),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: frame == null
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: height ?? 180,
                            color: Colors.grey.shade300,
                          ),
                        )
                      : child,
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📸 صورة مع Shimmer (للاستخدام العام)
  // ============================================================
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
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
        ),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: frame == null
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                  )
                : child,
          );
        },
      ),
    );
  }

  // ============================================================
  // 🖼️ أيقونة SVG مع لون
  // ============================================================
  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // ============================================================
  // 🖼️ أيقونة Navigation (للشريط السفلي)
  // ============================================================
  static Widget navIcon(String name, {double size = 24, Color? color}) {
    return svgIcon('$_iconsNav/$name.svg', size: size, color: color);
  }

  // ============================================================
  // 🖼️ أيقونة Core
  // ============================================================
  static Widget coreIcon(String name, {double size = 24, Color? color}) {
    return svgIcon('$_iconsCore/$name.svg', size: size, color: color);
  }
}
