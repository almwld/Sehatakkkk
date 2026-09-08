import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_assets.dart';

/// Local asset icon used by the UI instead of Material Icons.
/// Supports both verified PNG/JPG assets and local SVG assets.
class LocalAssetIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  final BoxFit fit;
  final String? semanticLabel;

  const LocalAssetIcon(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  String get _resolvedPath {
    if (assetPath == 'assets/images/tracking/heart_rate.png') return AppAssets.heartRateIcon;
    return assetPath;
  }

  @override
  Widget build(BuildContext context) {
    final path = _resolvedPath;
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        fit: fit,
        colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
        semanticsLabel: semanticLabel,
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: fit,
      color: color,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }
}
