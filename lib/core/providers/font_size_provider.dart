import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'font_size';
  static const double _defaultFontSize = 1.0;
  static const double _minFontSize = 0.8;
  static const double _maxFontSize = 1.6;

  double _fontScale = _defaultFontSize;

  FontSizeProvider() {
    _loadFontSize();
  }

  double get fontScale => _fontScale;
  double get fontSizePercent => (_fontScale * 100).roundToDouble();

  Future<void> _loadFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontScale = prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
      notifyListeners();
    } catch (e) {
      _fontScale = _defaultFontSize;
    }
  }

  Future<void> setFontScale(double value) async {
    _fontScale = value.clamp(_minFontSize, _maxFontSize);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, _fontScale);
    } catch (e) {
      // Ignore
    }
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    await setFontScale(_defaultFontSize);
  }

  String getScaleLabel() {
    if (_fontScale <= 0.85) return 'صغير';
    if (_fontScale <= 1.05) return 'متوسط';
    if (_fontScale <= 1.25) return 'كبير';
    return 'كبير جداً';
  }

  IconData getScaleIcon() {
    if (_fontScale <= 0.85) return "assets/icons/core/doctor.svg";
    if (_fontScale <= 1.05) return "assets/icons/core/doctor.svg";
    if (_fontScale <= 1.25) return "assets/icons/core/doctor.svg";
    return "assets/icons/core/doctor.svg";
  }

  Color getScaleColor() {
    if (_fontScale <= 0.85) return Colors.blue;
    if (_fontScale <= 1.05) return Colors.green;
    if (_fontScale <= 1.25) return Colors.orange;
    return Colors.red;
  }
}
