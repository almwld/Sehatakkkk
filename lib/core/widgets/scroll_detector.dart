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
      onNotification: _handleScroll,
      child: child,
    );
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final position = notification.metrics.pixels;

      // إبقاء الشريط ظاهرًا في أعلى الصفحة.
      if (position <= 0) {
        scrollManager.show();
        scrollManager.updatePosition(position);
        return false;
      }


      // في Flutter:
      // down = المحتوى يتحرك للأسفل => المستخدم يصعد الصفحة
      // up   = المحتوى يتحرك للأعلى => المستخدم ينزل الصفحة
      if (notification.dragDetails != null) {
        final delta = notification.dragDetails!.primaryDelta ?? 0.0;

        if (delta < -3.0) {
          // المستخدم يسحب للأعلى → يخفي الشريط.
          scrollManager.hide();
        } else if (delta > 3.0) {
          // المستخدم يسحب للأسفل → يظهر الشريط.
          scrollManager.show();
        }
      } else {
        // حالات التمرير غير المباشر مثل animateTo.
        final currentPosition = notification.metrics.pixels;
        final previousPosition = scrollManager.lastPosition;
        final delta = currentPosition - previousPosition;

        if (delta > 3.0) {
          scrollManager.hide();
        } else if (delta < -3.0) {
          scrollManager.show();
        }
      }

      scrollManager.updatePosition(position);
    }

    if (notification is ScrollEndNotification) {
      final position = notification.metrics.pixels;

      if (position <= 0) {
        scrollManager.show();
      }

      scrollManager.updatePosition(position);
    }

    return false;
  }
}
