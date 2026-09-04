// ============================================================
// 🌍 GlobalScrollManager - مدير التمرير العام للتطبيق
// ============================================================

import 'package:flutter/material.dart';

class GlobalScrollManager extends ChangeNotifier {
  bool _isVisible = true;
  double _lastPosition = 0;
  final Map<String, double> _screenPositions = {};
  String? _currentRoute;

  bool get isVisible => _isVisible;
  double get lastPosition => _lastPosition;

  set lastPosition(double value) {
    _lastPosition = value;
  }

  void registerScreen(String route) {
    _currentRoute = route;
    if (_screenPositions.containsKey(route)) {
      _lastPosition = _screenPositions[route]!;
    } else {
      _screenPositions[route] = 0;
    }
    _isVisible = true;
    notifyListeners();
  }

  void savePosition(String route, double position) {
    _screenPositions[route] = position;
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

  void reset() {
    _isVisible = true;
    _lastPosition = 0;
    notifyListeners();
  }

  bool isExcludedRoute(String route) {
    final excludedRoutes = ['/video_call', '/payment', '/onboarding', '/splash', '/auth'];
    return excludedRoutes.any((r) => route.contains(r));
  }

  @override
  void dispose() {
    _screenPositions.clear();
    super.dispose();
  }
}
