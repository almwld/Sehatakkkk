// ============================================================
// 📡 ScrollDetector - كاشف التمرير الذكي
// يلتقط حركة التمرير في أي شاشة ويتحكم في الشريط السفلي
// دون الحاجة لتعديل أي شاشة موجودة
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
    // ✅ الحصول على اسم الشاشة الحالية
    final route = ModalRoute.of(context)?.settings.name ?? 'unknown';
    
    // ✅ استثناء بعض الشاشات
    if (scrollManager.isExcludedRoute(route)) {
      return;
    }

    if (notification is ScrollUpdateNotification) {
      final currentPosition = notification.metrics.pixels;
      final delta = currentPosition - scrollManager.lastPosition;
      const threshold = 5.0;

      // ⬇️ تمرير للأسفل → إخفاء الشريط
      if (delta > threshold) {
        scrollManager.hide();
      }
      // ⬆️ تمرير للأعلى → إظهار الشريط
      else if (delta < -threshold) {
        scrollManager.show();
      }

      scrollManager.lastPosition = currentPosition;
      
      // ✅ حفظ الموقع للشاشة الحالية
      scrollManager.savePosition(route, currentPosition);
    }

    // ✅ إظهار الشريط عند الوصول للأعلى
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels <= 0) {
        scrollManager.show();
      }
    }
  }
}
