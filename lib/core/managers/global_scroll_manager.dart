// ============================================================
// 🌍 GlobalScrollManager - مدير التمرير العام للتطبيق
// ============================================================

import 'package:flutter/material.dart';

class GlobalScrollManager extends ChangeNotifier {
  bool _isVisible = true;
  double _lastPosition = 0.0;
  
  bool get isVisible => _isVisible;
  double get lastPosition => _lastPosition;
  
  set lastPosition(double value) {
    _lastPosition = value;
  }

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
    _lastPosition = 0.0;
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
