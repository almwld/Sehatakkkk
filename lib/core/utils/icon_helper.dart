import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Central icon rendering helpers for the app.
///
/// UI fallbacks intentionally remain asset-based/empty; Material IconData is
/// never used as an automatic visual fallback.
class IconHelper {
  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }

  static Widget safeSvgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }

  static Widget pngIcon(String path, {double size = 24, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }

  static Widget serviceIcon(String path, {double size = 26, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }

  static Widget navIcon(String path, {double size = 22, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }

  static Widget doctorIcon(String path, {double size = 50}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }

  static Widget paymentIcon(String path, {double size = 30}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }
}
