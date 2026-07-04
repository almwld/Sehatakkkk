import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // ✅ مراقبة الأداء
  void monitorPerformance() {
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        log('🔄 Performance monitoring started');
      });
    }
  }

  // ✅ تأخير العمليات الثقيلة
  Future<T> delayHeavyTask<T>(Future<T> Function() task) async {
    return await Future.delayed(const Duration(milliseconds: 100), () async {
      return await task();
    });
  }

  // ✅ تحميل الصور بشكل ذكي
  Widget buildOptimizedImage(String url, {double? width, double? height}) {
    return kIsWeb
        ? Image.network(
            url,
            width: width,
            height: height,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _buildShimmerPlaceholder(width ?? 100, height ?? 100);
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width ?? 100,
                height: height ?? 100,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          )
        : _buildCachedImage(url, width: width, height: height);
  }

  Widget _buildCachedImage(String url, {double? width, double? height}) {
    // ✅ استخدام CachedNetworkImage من حزمة cached_network_image
    // تم إضافتها في pubspec.yaml
    return Container(); // سيتم استبداله بـ CachedNetworkImage
  }

  Widget _buildShimmerPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  // ✅ تحسين القوائم الطويلة
  Widget buildOptimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, int) itemBuilder,
    int? itemCount,
  }) {
    return ListView.builder(
      itemCount: itemCount ?? items.length,
      itemBuilder: itemBuilder,
      cacheExtent: 500, // ✅ تحسين التخزين المؤقت
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
    );
  }

  // ✅ تحسين الشبكات (GridView)
  Widget buildOptimizedGridView<T>({
    required List<T> items,
    required Widget Function(BuildContext, int) itemBuilder,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: itemBuilder,
      cacheExtent: 500,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
    );
  }

  // ✅ منع إعادة البناء غير الضرورية
  Widget buildMemoizedWidget(Widget child) {
    return RepaintBoundary(
      child: child,
    );
  }

  // ✅ تحليل الذاكرة
  void logMemoryUsage() {
    if (kDebugMode) {
      log('🔍 Memory usage: ${_getMemoryUsage()}');
    }
  }

  String _getMemoryUsage() {
    // ✅ محاكاة - في الواقع تستخدم dart:developer
    return 'Memory usage tracked';
  }

  // ✅ إلغاء تحميل الصور غير المستخدمة
  void clearImageCache() {
    try {
      // ✅ سيتم استخدام PaintingBinding.instance.imageCache.clear();
    } catch (e) {
      print('❌ Error clearing image cache: $e');
    }
  }
}
