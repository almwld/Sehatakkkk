// ============================================================
// 🧭 GlobalNavigatorObserver - مراقب التنقل العام
// يتتبع التنقل بين الشاشات ويتحكم في حالة الشريط السفلي
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';

class GlobalNavigatorObserver extends NavigatorObserver {
  final GlobalScrollManager scrollManager;

  GlobalNavigatorObserver({required this.scrollManager});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _handleRouteChange(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _handleRouteChange(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _handleRouteChange(newRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _handleRouteChange(previousRoute);
    }
  }

  void _handleRouteChange(Route<dynamic> route) {
    final routeName = route.settings.name ?? 'unknown';
    scrollManager.registerScreen(routeName);
    scrollManager.show();
  }
}
