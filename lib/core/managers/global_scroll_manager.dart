import 'package:flutter/foundation.dart';

/// مدير ظهور الشريط السفلي.
///
/// يوجد منه instance واحد داخل HomeScreen.
/// لا يستمع للتمرير بنفسه؛ ScrollDetector هو المسؤول عن ذلك.
class GlobalScrollManager extends ChangeNotifier {
  bool _isVisible = true;
  double _lastPosition = 0.0;

  bool get isVisible => _isVisible;
  double get lastPosition => _lastPosition;

  void updatePosition(double position) {
    _lastPosition = position;
  }

  void show() {
    if (_isVisible) return;

    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    if (!_isVisible) return;

    _isVisible = false;
    notifyListeners();
  }

  void reset() {
    _lastPosition = 0.0;

    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }
}
