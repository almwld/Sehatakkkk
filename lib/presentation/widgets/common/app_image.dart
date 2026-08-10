import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final String? placeholderAsset;
  final Widget? errorWidget;
  final Duration cacheDuration;
  final bool isCircle;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderAsset,
    this.errorWidget,
    this.cacheDuration = const Duration(days: 7),
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.zero;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildErrorPlaceholder(effectiveBorderRadius);
    }

    final Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      maxHeightDiskCache: 1000,
      maxWidthDiskCache: 1000,
      placeholder: (context, url) => _buildShimmerLoader(effectiveBorderRadius),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildErrorPlaceholder(effectiveBorderRadius),
    );

    if (isCircle) {
      return ClipOval(child: imageWidget);
    }

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: imageWidget,
    );
  }

  Widget _buildShimmerLoader(BorderRadiusGeometry radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BorderRadiusGeometry radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: radius,
      ),
      child: placeholderAsset != null
          ? Image.asset(placeholderAsset!, fit: fit)
          : Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey[500],
              size: (height != null && height! < 50) ? 20 : 32,
            ),
    );
  }
}
