// ============================================================
// 📡 ScrollDetector - كاشف التمرير الذكي
// يعتمد على حركة المستخدم الفعلية مع عتبة 5dp.
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

    // Accumulate actual user movement so small 1-2dp updates do not cause
    // jitter. The manager activates hide/show only after 5dp is reached.
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0.0;
      if (delta != 0.0) {
        scrollManager.handleScrollDelta(delta);
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
