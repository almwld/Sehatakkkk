import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class IconHelper {
  static Widget pngIcon(String path, {double size = 24, Color? color}) {
    return Image.asset(path, width: size, height: size, color: color);
  }

  static Widget svgIcon(String path, {double size = 24, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget serviceIcon(String path, {double size = 26, Color? color}) {
    return Image.asset(path, width: size, height: size);
  }

  static Widget navIcon(String path, {double size = 22, Color? color}) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  static Widget doctorIcon(String path, {double size = 50}) {
    return Image.asset(path, width: size, height: size);
  }
}
