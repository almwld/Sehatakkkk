import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية
  // ============================================================
  static const String _banners = 'assets/images/banners';
  static const String _images = 'assets/images';
  static const String _iconsCore = 'assets/icons/core';
  static const String _iconsNav = 'assets/icons/navigation';
  static const String _iconsSpecialties = 'assets/icons/specialties';
  static const String _iconsMini = 'assets/icons/mini_specialties';
  static const String _iconsSocial = 'assets/icons/social';

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
    {'image': banner1},
  ];

  // ============================================================
  // 👨‍⚕️ صور الأطباء
  // ============================================================
  static const String doctor1 = '$_images/placeholder.png';
  static const String doctor2 = '$_images/placeholder.png';
  static const String doctor3 = '$_images/placeholder.png';
  static const String doctor4 = '$_images/placeholder.png';
  static const String doctor5 = '$_images/placeholder.png';
  static const String doctor6 = '$_images/placeholder.png';
  static const String doctor7 = '$_images/placeholder.png';
  static const String doctor8 = '$_images/placeholder.png';

  // ============================================================
  // 💊 صور الأدوية
  // ============================================================
  static const String medicine1 = '$_images/placeholder.png';
  static const String medicine2 = '$_images/placeholder.png';
  static const String medicine3 = '$_images/placeholder.png';
  static const String medicine4 = '$_images/placeholder.png';
  static const String medicine5 = '$_images/placeholder.png';
  static const String medicine6 = '$_images/placeholder.png';
  static const String medicine7 = '$_images/placeholder.png';
  static const String medicine8 = '$_images/placeholder.png';
  static const String medicine9 = '$_images/placeholder.png';
  static const String medicine10 = '$_images/placeholder.png';

  // ============================================================
  // 🏥 الصيدليات والمختبرات
  // ============================================================
  static const String pharmacy1 = '$_images/placeholder.png';
  static const String pharmacy2 = '$_images/placeholder.png';
  static const String lab1 = '$_images/placeholder.png';

  // ============================================================
  // 🖼️ أيقونات SVG مع حجم
  // ============================================================
  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // ✅ أيقونة Navigation مع حجم
  static Widget navIcon(String name, {double size = 24, Color? color}) {
    return svgIcon('$_iconsNav/$name.svg', size: size, color: color);
  }

  // ✅ أيقونة Core مع حجم
  static Widget coreIcon(String name, {double size = 24, Color? color}) {
    return svgIcon('$_iconsCore/$name.svg', size: size, color: color);
  }

  // ============================================================
  // 🎯 عرض البانر
  // ============================================================
  static Widget buildBanner(Map<String, dynamic> banner, {double? height}) {
    return Container(
      height: height ?? 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
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
                          child: Container(height: height ?? 180, color: Colors.grey.shade300),
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
                    colors: [Colors.black.withOpacity(0.4), Colors.transparent],
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
  // 📸 صورة مع Shimmer
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
}
