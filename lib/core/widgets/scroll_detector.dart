// ============================================================
// 📁 lib/core/widgets/scroll_detector.dart
// 📡 كاشف التمرير - يلتقط التمرير في أي شاشة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    // ✅ استثناء بعض الشاشات
    final route = ModalRoute.of(context)?.settings.name ?? '';
    if (scrollManager.isExcluded(route)) {
      return;
    }

    if (notification is ScrollUpdateNotification) {
      final currentPosition = notification.metrics.pixels;
      final delta = currentPosition - scrollManager.lastPosition;
      const threshold = 5.0;

      if (delta > threshold) {
        scrollManager.hide();
      } else if (delta < -threshold) {
        scrollManager.show();
      }

      scrollManager.lastPosition = currentPosition;
      
      final route = ModalRoute.of(context)?.settings.name ?? 'unknown';
      scrollManager.savePosition(route, currentPosition);
    }

    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels <= 0) {
        scrollManager.show();
      }
    }
  }
}
