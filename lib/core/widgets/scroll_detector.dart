// ============================================================
// 📡 ScrollDetector - كاشف التمرير الذكي (النسخة البديلة)
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';

class ScrollDetector extends StatelessWidget {
  final Widget child;
  final GlobalScrollManager scrollManager;

  const ScrollDetector({
    super.key,
    required this.child,
    required this.scrollManager,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScroll(notification, context);
        return false;
      },
      child: child,
    );
  }

  void _handleScroll(ScrollNotification notification, BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? 'home';
    
    if (scrollManager.isExcludedRoute(route)) {
      return;
    }

    // ✅ استخدام ScrollUpdateNotification
    if (notification is ScrollUpdateNotification) {
      final currentOffset = notification.metrics.pixels;
      final delta = currentOffset - scrollManager.lastPosition;
      
      // حفظ آخر موضع
      scrollManager.lastPosition = currentOffset;
      
      // عتبة الحركة - لتجنب الحركات الصغيرة
      const threshold = 5.0;
      
      if (delta > threshold) {
        // ⬇️ التمرير للأسفل → إخفاء
        scrollManager.hide();
      } else if (delta < -threshold) {
        // ⬆️ التمرير للأعلى → إظهار
        scrollManager.show();
      }
    }
    
    // عند الوصول لأعلى الصفحة، أظهر الشريط
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels <= 0) {
        scrollManager.show();
      }
    }
  }
}
