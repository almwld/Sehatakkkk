import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/services/cache_service.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final CacheService _cache = CacheService();
  
  Widget cachedImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Duration cacheDuration = const Duration(days: 7),
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      cacheKey: url,
      cacheManager: CustomCacheManager(
        maxAge: cacheDuration,
        maxNrOfCacheObjects: 100,
      ),
      placeholder: (context, url) => _buildPlaceholder(width, height),
      errorWidget: (context, url, error) => _buildErrorWidget(width, height),
      imageBuilder: (context, imageProvider) {
        if (borderRadius != null) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: Image(image: imageProvider, fit: fit, width: width, height: height),
          );
        }
        return Image(image: imageProvider, fit: fit, width: width, height: height);
      },
    );
  }

  Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
    );
  }
}

class CustomCacheManager extends BaseCacheManager {
  CustomCacheManager({
    required Duration maxAge,
    required int maxNrOfCacheObjects,
  }) : super(
    key: 'custom_cache',
    maxAge: maxAge,
    maxNrOfCacheObjects: maxNrOfCacheObjects,
  );
}
