// ============================================================
// 📡 ScrollDetector - كاشف التمرير الذكي (نسخة X)
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
    // ✅ استخدام UserScrollNotification - نفس طريقة X
    if (notification is UserScrollNotification) {
      final route = ModalRoute.of(context)?.settings.name ?? 'home';
      
      if (scrollManager.isExcludedRoute(route)) {
        return;
      }

      if (notification.direction == ScrollDirection.reverse) {
        // ⬇️ التمرير للأسفل → إخفاء الشريط
        scrollManager.hide();
      } else if (notification.direction == ScrollDirection.forward) {
        // ⬆️ التمرير للأعلى → إظهار الشريط
        scrollManager.show();
      }
    }
  }
}
