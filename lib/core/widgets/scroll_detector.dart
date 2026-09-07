// ============================================================
// 📡 ScrollDetector - كاشف التمرير الذكي
// يعتمد على اتجاه التمرير الفعلي بدل مقارنة موضع عام بين الشاشات.
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
    if (scrollManager.isExcludedRoute(route)) return;

    if (notification is ScrollStartNotification) {
      scrollManager.registerScreen(route);
      return;
    }

    // الاتجاه الفعلي للمستخدم، وليس فرق موضع قد ينتمي إلى ScrollView آخر.
    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.reverse:
          scrollManager.hide();
          break;
        case ScrollDirection.forward:
          scrollManager.show();
          break;
        case ScrollDirection.idle:
          break;
      }
    }

    if (notification is ScrollEndNotification) {
      final position = notification.metrics.pixels;
      scrollManager.lastPosition = position;
      scrollManager.savePosition(route, position);

      if (position <= 0) {
        scrollManager.show();
      }
    }
  }
}
