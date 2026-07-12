import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class IconHelper {
  // ============================================================
  // 🖼️ تحميل أيقونة PNG من assets
  // ============================================================
  static Widget pngIcon(String path, {double size = 24, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      errorBuilder: (_, __, ___) => Icon(
        Icons.broken_image,
        size: size,
        color: Colors.grey,
      ),
    );
  }

  // ============================================================
  // 🖼️ تحميل أيقونة SVG من assets
  // ============================================================
  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      errorBuilder: (_, __, ___) => Icon(
        Icons.broken_image,
        size: size,
        color: Colors.grey,
      ),
    );
  }

  // ============================================================
  // ⚡ أيقونة الخدمات السريعة (مع fallback)
  // ============================================================
  static Widget serviceIcon(String path, {double size = 26, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Icon(
        Icons.medical_services,
        size: size,
        color: color ?? AppColors.primary,
      ),
    );
  }

  // ============================================================
  // 🧭 أيقونة التنقل السفلي (مع fallback)
  // ============================================================
  static Widget navIcon(String path, {double size = 22, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      errorBuilder: (_, __, ___) => Icon(
        Icons.circle,
        size: size,
        color: color ?? Colors.grey,
      ),
    );
  }

  // ============================================================
  // 🩺 أيقونة التخصص (مع fallback)
  // ============================================================
  static Widget specialtyIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      errorBuilder: (_, __, ___) => Icon(
        Icons.medical_information,
        size: size,
        color: color ?? AppColors.primary,
      ),
    );
  }

  // ============================================================
  // 💳 أيقونة الدفع (مع fallback)
  // ============================================================
  static Widget paymentIcon(String path, {double size = 40, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Icon(
        Icons.payment,
        size: size,
        color: color ?? AppColors.primary,
      ),
    );
  }
}
