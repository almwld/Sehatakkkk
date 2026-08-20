import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    Widget child;
    
    final isNetwork = imageUrl.startsWith('http');
    final isSvgFile = imageUrl.endsWith('.svg') || isSvg;
    final isAsset = !isNetwork && !isSvgFile;

    if (isSvgFile) {
      if (isNetwork) {
        child = SvgPicture.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (_) => placeholder ?? _buildPlaceholder(),
        );
      } else {
        child = SvgPicture.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
        );
      }
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
        placeholder: (context, _) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, _, __) => errorWidget ?? _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 150),
      );
    } else {
      child = Image.asset(
        imageUrl,
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
    final isSvg = url.endsWith('.svg');
    
    final optimizedUrl = isSvg 
        ? url 
        : ImageKit.optimize(
            imageUrl: url,
            width: size.toInt(),
            height: size.toInt(),
            quality: 80,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AppImage(
        imageUrl: optimizedUrl,
        width: size,
        height: size,
        isSvg: isSvg,
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
      imageUrl: imagePath,
      width: (width ?? 300).toInt(),
      height: (height ?? 200).toInt(),
      quality: 80,
    );

    return AppImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

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
      imageUrl: imagePath,
      width: 1200,
      height: 600,
      quality: 85,
    );

    return AppImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(16),
      memCacheWidth: 1200,
      memCacheHeight: 600,
    );
  }
}

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
      imageUrl: imagePath,
      width: (width ?? 200).toInt(),
      height: (height ?? 200).toInt(),
      quality: 85,
    );

    return AppImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class LabImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const LabImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageKit.optimize(
      imageUrl: imagePath,
      width: (width ?? 300).toInt(),
      height: (height ?? 200).toInt(),
      quality: 80,
    );

    return AppImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class PharmacyImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;

  const PharmacyImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = ImageKit.optimize(
      imageUrl: imagePath,
      width: (width ?? 300).toInt(),
      height: (height ?? 200).toInt(),
      quality: 80,
    );

    return AppImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
