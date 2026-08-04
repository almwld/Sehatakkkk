import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isSvg;
  final Color? color;
  final double? placeholderSize;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isSvg = false,
    this.color,
    this.placeholderSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    
    final isNetwork = url.startsWith('http');
    final isSvgFile = url.endsWith('.svg') || isSvg;

    if (isSvgFile) {
      // ✅ SVG من الإنترنت
      if (isNetwork) {
        child = SvgPicture.network(
          url,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: (_) => _buildPlaceholder(),
        );
      } else {
        // ✅ SVG من Assets
        child = SvgPicture.asset(
          url,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: (_) => _buildPlaceholder(),
        );
      }
    } else if (isNetwork) {
      // ✅ PNG/JPG من الإنترنت (ImageKit)
      child = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        color: color,
        placeholder: (context, _) => _buildPlaceholder(),
        errorWidget: (context, _, __) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        useOldImageOnUrlChange: true,
      );
    } else {
      // ✅ Asset محلي
      child = Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        color: color,
        errorBuilder: (context, _, __) => _buildErrorWidget(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? 40,
        height: height ?? 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width ?? 40,
      height: height ?? 40,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: placeholderSize ?? 24,
      ),
    );
  }
}
