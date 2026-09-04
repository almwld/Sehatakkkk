// ============================================================
// 📡 ScrollDetector - كاشف التمرير الذكي
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

  void _handleScroll(
    ScrollNotification notification,
    BuildContext context,
  ) {
    final route = ModalRoute.of(context)?.settings.name ?? 'home';

    if (scrollManager.isExcludedRoute(route)) {
      return;
    }

    if (notification is ScrollStartNotification) {
      scrollManager.registerScreen(route);
      return;
    }

    if (notification is ScrollUpdateNotification) {
      final currentPosition = notification.metrics.pixels;
      final delta = currentPosition - scrollManager.lastPosition;

      const threshold = 5.0;

      if (delta > threshold) {
        // ⬇️ التمرير للأسفل → إخفاء الشريط
        scrollManager.hide();
      } else if (delta < -threshold) {
        // ⬆️ التمرير للأعلى → إظهار الشريط
        scrollManager.show();
      }

      scrollManager.lastPosition = currentPosition;
      scrollManager.savePosition(route, currentPosition);
    }

    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels <= 0) {
        scrollManager.show();
      }

      scrollManager.savePosition(
        route,
        notification.metrics.pixels,
      );
    }
  }
}
