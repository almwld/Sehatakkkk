import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  // ============================================================
  // 📁 المسارات الأساسية
  // ============================================================
  static const String _coreIcons = 'assets/icons/core';
  static const String _navigationIcons = 'assets/icons/navigation';
  static const String _specialties = 'assets/icons/specialties';
  static const String _miniSpecialties = 'assets/icons/mini_specialties';
  static const String _social = 'assets/icons/social';
  static const String _banners = 'assets/images/banners';
  static const String _images = 'assets/images';

  // ============================================================
  // 🖼️ البانرات (الصور الموجودة)
  // ============================================================
  static const String banner1 = '$_banners/banner_1.png';
  static const String banner2 = '$_banners/banner_2.png';
  static const String banner3 = '$_banners/banner_3.png';
  static const String banner4 = '$_banners/banner_1.png';
  static const String banner5 = '$_banners/banner_2.png';

  // ✅ بيانات البانرات مع الصور
  static final List<Map<String, dynamic>> bannerData = [
    {'title': 'رعاية صحية متميزة', 'sub': 'احجز موعدك الآن مع أفضل الأطباء', 'image': banner1},
    {'title': 'صيدليتك في راحة يدك', 'sub': 'اطلب أدويتك وتصلك في أسرع وقت', 'image': banner2},
    {'title': 'مختبرات متطورة', 'sub': 'نتائج دقيقة وسريعة', 'image': banner3},
    {'title': 'استشارات طبية فورية', 'sub': 'تحدث مع طبيبك عبر الفيديو والصوت', 'image': banner1},
  ];

  // ============================================================
  // ✨ دالة Shimmer احترافية
  // ============================================================
  static Widget shimmerEffect({double? width, double? height, double borderRadius = 12}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  // ============================================================
  // 🖼️ عرض الصورة مع Shimmer (للبانرات)
  // ============================================================
  static Widget buildBannerCard(Map<String, dynamic> banner, {double? height}) {
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
            // ✅ الصورة مع Shimmer
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
                      ? shimmerEffect(height: height ?? 180)
                      : child,
                );
              },
            ),
            // ✅ التدرج في الأسفل
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // ✅ النص
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    banner['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    banner['sub'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
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
                ? shimmerEffect(width: width, height: height, borderRadius: borderRadius)
                : child,
          );
        },
      ),
    );
  }

  // ============================================================
  // 🖼️ صورة دائرية مع Shimmer (لأفاتار)
  // ============================================================
  static Widget avatarWithShimmer(
    String path, {
    double size = 50,
  }) {
    return ClipOval(
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.grey, size: 30),
        ),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: frame == null
                ? shimmerEffect(width: size, height: size, borderRadius: size / 2)
                : child,
          );
        },
      ),
    );
  }

  // ============================================================
  // 🎯 دالة واحدة موحدة لجميع الأيقونات (مثل مواعيدي)
  // ============================================================
  static Widget svgIcon(String path, {double width = 24, double height = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // ============================================================
  // 📌 أيقونات الشريط السفلي (Navigation)
  // ============================================================
  static Widget navIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_navigationIcons/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات الأساسية (Core)
  // ============================================================
  static Widget coreIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_coreIcons/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التخصصات
  // ============================================================
  static Widget specialtyIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_specialties/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التخصصات المصغرة
  // ============================================================
  static Widget miniSpecialtyIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_miniSpecialties/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التواصل الاجتماعي
  // ============================================================
  static Widget socialIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_social/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // ✅ دوال مساعدة للمسارات
  // ============================================================
  static String coreIconPath(String name) => '$_coreIcons/$name.svg';
  static String navIconPath(String name) => '$_navigationIcons/$name.svg';
  static String specialtyIconPath(String name) => '$_specialties/$name.svg';
  static String miniSpecialtyIconPath(String name) => '$_miniSpecialties/$name.svg';
  static String socialIconPath(String name) => '$_social/$name.svg';
}
