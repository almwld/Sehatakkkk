import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  // 📌 أيقونات الشريط السفلي (Navigation) - نفس آلية مواعيدي
  // ============================================================
  static Widget navIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_navigationIcons/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات الأساسية (Core) - نفس آلية مواعيدي
  // ============================================================
  static Widget coreIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_coreIcons/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التخصصات - نفس آلية مواعيدي
  // ============================================================
  static Widget specialtyIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_specialties/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التخصصات المصغرة - نفس آلية مواعيدي
  // ============================================================
  static Widget miniSpecialtyIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_miniSpecialties/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 📌 أيقونات التواصل الاجتماعي - نفس آلية مواعيدي
  // ============================================================
  static Widget socialIcon(String name, {double width = 24, double height = 24, Color? color}) {
    return svgIcon('$_social/$name.svg', width: width, height: height, color: color);
  }

  // ============================================================
  // 🖼️ البانرات (صور) - تستخدم Image.asset
  // ============================================================
  static Widget bannerImage(String name, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      '$_banners/$name',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
      ),
    );
  }

  // ============================================================
  // 🖼️ صور عامة - تستخدم Image.asset
  // ============================================================
  static Widget image(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
      ),
    );
  }

  // ============================================================
  // ✅ دوال مساعدة للوصول إلى المسارات (للحالات النادرة)
  // ============================================================
  static String coreIconPath(String name) => '$_coreIcons/$name.svg';
  static String navIconPath(String name) => '$_navigationIcons/$name.svg';
  static String specialtyIconPath(String name) => '$_specialties/$name.svg';
  static String miniSpecialtyIconPath(String name) => '$_miniSpecialties/$name.svg';
  static String socialIconPath(String name) => '$_social/$name.svg';
  static String bannerPath(String name) => '$_banners/$name';
}
