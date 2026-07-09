import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ImageService {
  // 📁 المسارات الأساسية
  static const String _banners = 'assets/images/banners';
  static const String _images = 'assets/images';
  static const String _iconsCore = 'assets/icons/core';
  static const String _iconsNav = 'assets/icons/navigation';

  // 🖼️ البانرات
  static const String banner1 = '$_banners/banner_1.png';
  static const String banner2 = '$_banners/banner_2.png';
  static const String banner3 = '$_banners/banner_3.png';

  static final List<Map<String, dynamic>> bannerData = [
    {'image': banner1},
    {'image': banner2},
    {'image': banner3},
  ];

  // صور الـ Placeholder
  static const String doctor1 = '$_images/placeholder.png';
  static const String doctor2 = '$_images/placeholder.png';
  static const String doctor3 = '$_images/placeholder.png';
  static const String medicine1 = '$_images/placeholder.png';
  static const String medicine2 = '$_images/placeholder.png';
  static const String medicine3 = '$_images/placeholder.png';
  static const String medicine4 = '$_images/placeholder.png';

  // 🎯 عرض البانر مع معالجة الأخطاء والـ Shimmer
  static Widget buildBanner(Map<String, dynamic> banner, {double? height}) {
    return Container(
      height: height ?? 180,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          banner['image'] as String,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
          ),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return frame == null
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(color: Colors.grey.shade300),
                  )
                : child;
          },
        ),
      ),
    );
  }

  // 📸 صورة مع Shimmer آمن
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

  // 🖼️ أيقونات SVG
  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget navIcon(String name, {double size = 24, Color? color}) {
    return svgIcon('$_iconsNav/$name.svg', size: size, color: color);
  }

  static Widget coreIcon(String name, {double size = 24, Color? color}) {
    return svgIcon('$_iconsCore/$name.svg', size: size, color: color);
  }
}
