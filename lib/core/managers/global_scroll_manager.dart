// ============================================================
// 🌍 GlobalScrollManager - مدير التمرير العام للتطبيق
// ============================================================

import 'package:flutter/material.dart';

class GlobalScrollManager extends ChangeNotifier {
  static const double scrollThreshold = 5.0;

  bool _isVisible = true;
  double _lastPosition = 0.0;
  double _pendingDelta = 0.0;
  String _currentRoute = '';
  final Map<String, double> _savedPositions = <String, double>{};

  bool get isVisible => _isVisible;
  double get lastPosition => _lastPosition;

  set lastPosition(double value) {
    _lastPosition = value;
  }

  void registerScreen(String route) {
    _currentRoute = route;
    _pendingDelta = 0.0;
  }

  void savePosition(String route, double position) {
    _savedPositions[route] = position;
    _lastPosition = position;
  }

  double positionFor(String route) => _savedPositions[route] ?? 0.0;

  /// Accumulates small scroll updates until the 5dp threshold is crossed.
  /// Positive delta means scrolling down; negative means scrolling up.
  void handleScrollDelta(double delta) {
    if (delta == 0) return;

    if ((_pendingDelta > 0 && delta < 0) ||
        (_pendingDelta < 0 && delta > 0)) {
      _pendingDelta = 0.0;
    }

    _pendingDelta += delta;

    if (_pendingDelta >= scrollThreshold) {
      hide();
      _pendingDelta = 0.0;
    } else if (_pendingDelta <= -scrollThreshold) {
      show();
      _pendingDelta = 0.0;
    }
  }

  void show() {
    _pendingDelta = 0.0;
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  void hide() {
    _pendingDelta = 0.0;
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  void toggle() {
    _isVisible = !_isVisible;
    _pendingDelta = 0.0;
    notifyListeners();
  }

  void reset() {
    _isVisible = true;
    _lastPosition = 0.0;
    _pendingDelta = 0.0;
    _currentRoute = '';
    notifyListeners();
  }

  bool isExcludedRoute(String route) {
    const excludedRoutes = [
      '/video_call',
      '/payment',
      '/onboarding',
      '/splash',
      '/auth',
    ];
    return excludedRoutes.any((r) => route.contains(r));
  }

  @override
  void dispose() {
    _savedPositions.clear();
    super.dispose();
  }
}
