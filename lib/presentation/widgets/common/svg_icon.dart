import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final String? path;
  final double? width;
  final double? height;
  final double size;
  final Color? color;
  const SvgIcon({super.key, String? assetPath, this.path, this.width, this.height, this.size = 24, this.color}) : assetPath = assetPath ?? path ?? '';
  @override Widget build(BuildContext context) {
    if (assetPath.isEmpty) return SizedBox(width: width ?? size, height: height ?? size);
    return SvgPicture.asset(assetPath, width: width ?? size, height: height ?? size, colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn));
  }
}
