import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class AppImage extends StatelessWidget {
  final String url;
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
    required this.url,
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
    Widget child;

    final isNetwork = url.startsWith('http');
    final isSvgFile = url.endsWith('.svg') || isSvg;
    final isAsset = !isNetwork && !isSvgFile;

    if (isSvgFile) {
      // ✅ SVG
      if (isNetwork) {
        child = SvgPicture.network(
          url,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (_) => placeholder ?? _buildPlaceholder(),
        );
      } else {
        child = SvgPicture.asset(
          url,
          width: width,
          height: height,
          fit: fit,
        );
      }
    } else if (isNetwork) {
      // ✅ PNG/JPG من الإنترنت
      child = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        maxWidthDiskCache: maxWidthDiskCache,
        maxHeightDiskCache: maxHeightDiskCache,
        filterQuality: FilterQuality.medium,
        placeholder: (context, _) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, _, __) => errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 150),
      );
    } else {
      // ✅ Asset محلي
      child = Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? _buildErrorWidget(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width ?? 50,
      height: height ?? 50,
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width ?? 50,
      height: height ?? 50,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey.shade400,
        size: (width ?? 50) * 0.4,
      ),
    );
  }
}

// ✅ DoctorImage
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
    final defaultImage = gender == 'female'
        ? ImageKit.doctorFemalePlaceholder
        : ImageKit.doctorPlaceholder;

    final url = imagePath?.isNotEmpty == true ? imagePath! : defaultImage;

    // ✅ تحسين الصورة
    final optimizedUrl = url.startsWith('http')
        ? ImageKit.optimize(
            url: url,
            width: size.toInt(),
            height: size.toInt(),
          )
        : url;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AppImage(
        url: optimizedUrl,
        width: size,
        height: size,
        isSvg: url.endsWith('.svg'),
        errorWidget: Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.person,
            color: Colors.grey.shade400,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

// ✅ HospitalImage
class HospitalImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const HospitalImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageKit.optimize(
      url: imagePath,
      width: (width ?? 300).toInt(),
      height: (height ?? 200).toInt(),
    );

    return AppImage(
      url: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

// ✅ BannerImage
class BannerImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const BannerImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageKit.optimize(
      url: imagePath,
      width: 1200,
      height: 500,
    );

    return AppImage(
      url: optimizedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(16),
      memCacheWidth: 1200,
      memCacheHeight: 600,
    );
  }
}

// ✅ MedicineImage
class MedicineImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const MedicineImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageKit.optimize(
      url: imagePath,
      width: (width ?? 200).toInt(),
      height: (height ?? 200).toInt(),
    );

    return AppImage(
      url: optimizedUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

// ✅ LabImage
class LabImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LabImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageKit.optimize(
      url: imagePath,
      width: (width ?? 300).toInt(),
      height: (height ?? 200).toInt(),
    );

    return AppImage(
      url: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

// ✅ PharmacyImage
class PharmacyImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PharmacyImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageKit.optimize(
      url: imagePath,
      width: (width ?? 300).toInt(),
      height: (height ?? 200).toInt(),
    );

    return AppImage(
      url: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
