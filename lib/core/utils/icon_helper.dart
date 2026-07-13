import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class IconHelper {
  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
      // ✅ إضافة errorBuilder
    );
  }
  
  // ✅ دالة جديدة مع fallback
  static Widget safeSvgIcon(String path, {double size = 24, Color? color, IconData? fallbackIcon}) {
    try {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        fit: BoxFit.contain,
      );
    } catch (e) {
      return Icon(fallbackIcon ?? Icons.circle, size: size, color: color ?? Colors.grey);
    }
  }
  
  static Widget pngIcon(String path, {double size = 24, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: size, color: Colors.grey),
    );
  }

  static Widget serviceIcon(String path, {double size = 26, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.medical_services, size: size, color: color ?? AppColors.primary),
    );
  }

  static Widget navIcon(String path, {double size = 22, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
    );
  }

  static Widget doctorIcon(String path, {double size = 50}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.person, size: size, color: Colors.grey),
    );
  }

  static Widget paymentIcon(String path, {double size = 30}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.payment, size: size, color: Colors.grey),
    );
  }
}
