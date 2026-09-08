import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isSvg;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.isSvg = false,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache = 1200,
    this.maxHeightDiskCache = 1200,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = imageUrl.startsWith('http');
    final isSvgFile = imageUrl.endsWith('.svg') || isSvg;
    final Widget child;

    if (isSvgFile) {
      child = isNetwork
          ? SvgPicture.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              placeholderBuilder: (_) => placeholder ?? buildImageShimmer(context),
            )
          : SvgPicture.asset(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
            );
    } else if (isNetwork) {
      child = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        maxWidthDiskCache: maxWidthDiskCache,
        maxHeightDiskCache: maxHeightDiskCache,
        filterQuality: FilterQuality.medium,
        placeholder: (context, _) => placeholder ?? buildImageShimmer(context),
        errorWidget: (context, _, __) => errorWidget ?? buildImageError(context),
        fadeInDuration: const Duration(milliseconds: 320),
        fadeOutDuration: const Duration(milliseconds: 160),
      );
    } else {
      child = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? buildImageError(context),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget buildImageShimmer(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? const Color(0xFF1A2540) : const Color(0xFFE9EEF2);
    final highlight = dark ? const Color(0xFF263653) : const Color(0xFFF7FAFC);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: base,
      ),
    );
  }

  Widget buildImageError(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width ?? 50,
      height: height ?? 50,
      color: dark ? const Color(0xFF172033) : const Color(0xFFF1F4F6),
      alignment: Alignment.center,
      child: const SizedBox.shrink(),
    );
  }
}

Widget buildImageShimmer(BuildContext context, {double? width, double? height, BorderRadius? radius}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return ClipRRect(
    borderRadius: radius ?? BorderRadius.zero,
    child: Shimmer.fromColors(
      baseColor: dark ? const Color(0xFF1A2540) : const Color(0xFFE9EEF2),
      highlightColor: dark ? const Color(0xFF263653) : const Color(0xFFF7FAFC),
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        color: dark ? const Color(0xFF1A2540) : const Color(0xFFE9EEF2),
      ),
    ),
  );
}

class DoctorImage extends StatelessWidget {
  final String? imagePath;
  final double size;
  final String gender;

  const DoctorImage({
    super.key,
    this.imagePath,
    this.size = 55,
    this.gender = 'male',
  });

  @override
  Widget build(BuildContext context) {
    final defaultImage = gender == 'female' ? ImageKit.doctor3 : ImageKit.doctor1;
    final url = (imagePath?.isNotEmpty == true) ? imagePath! : defaultImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AppImage(
        imageUrl: url,
        width: size,
        height: size,
        errorWidget: Container(
          width: size,
          height: size,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF172033)
              : const Color(0xFFF1F4F6),
          alignment: Alignment.center,
          child: Text(
            gender == 'female' ? 'د' : 'د',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black45,
              fontSize: size * .34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class HospitalImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const HospitalImage({super.key, required this.imagePath, this.width, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) => AppImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        borderRadius: BorderRadius.circular(12),
      );
}

class BannerImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const BannerImage({super.key, required this.imagePath, this.width, this.height});

  @override
  Widget build(BuildContext context) => AppImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(16),
        memCacheWidth: 1200,
        memCacheHeight: 600,
      );
}

class MedicineImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const MedicineImage({super.key, required this.imagePath, this.width, this.height});

  @override
  Widget build(BuildContext context) => AppImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        borderRadius: BorderRadius.circular(12),
      );
}

class LabImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const LabImage({super.key, required this.imagePath, this.width, this.height});

  @override
  Widget build(BuildContext context) => AppImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
      );
}

class PharmacyImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const PharmacyImage({super.key, required this.imagePath, this.width, this.height});

  @override
  Widget build(BuildContext context) => AppImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
      );
}
