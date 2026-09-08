import 'package:flutter/material.dart';

/// Local asset icon used by the UI instead of Material Icons.
///
/// The widget deliberately has no IconData fallback: if an asset cannot be
/// rendered, it stays empty rather than silently reintroducing a Material icon.
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

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      color: color,
      semanticLabel: semanticLabel,
      errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
    );
  }
}
