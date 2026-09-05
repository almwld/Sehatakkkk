// ============================================================
// 🌍 GlobalScrollManager - مدير التمرير العام للتطبيق
// ============================================================

import 'package:flutter/material.dart';

class GlobalScrollManager extends ChangeNotifier {
  bool _isVisible = true;
  
  bool get isVisible => _isVisible;

  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void reset() {
    _isVisible = true;
    notifyListeners();
  }

  bool isExcludedRoute(String route) {
    final excludedRoutes = ['/video_call', '/payment', '/onboarding', '/splash', '/auth'];
    return excludedRoutes.any((r) => route.contains(r));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
