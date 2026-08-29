import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  double _fontScale = 1.0;
  static const double _minScale = 0.8;
  static const double _maxScale = 1.4;
  static const double _step = 0.1;

  double get fontScale => _fontScale;

  // ✅ الحصول على نسبة الحجم كنسبة مئوية
  int get fontSizePercent => ((_fontScale - 0.8) / 0.6 * 100).round();

  // ✅ الحصول على لون المقياس
  Color getScaleColor() {
    if (_fontScale <= 0.9) return Colors.blue;
    if (_fontScale <= 1.1) return Colors.green;
    if (_fontScale <= 1.2) return Colors.orange;
    return Colors.red;
  }

  // ✅ الحصول على أيقونة المقياس
  IconData getScaleIcon() {
    if (_fontScale <= 0.9) return Icons.text_decrease;
    if (_fontScale <= 1.1) return Icons.text_fields;
    if (_fontScale <= 1.2) return Icons.text_increase;
    return Icons.text_increase;
  }

  // ✅ الحصول على تسمية المقياس
  String getScaleLabel() {
    if (_fontScale <= 0.9) return 'صغير';
    if (_fontScale <= 1.1) return 'متوسط';
    if (_fontScale <= 1.2) return 'كبير';
    return 'كبير جداً';
  }

  // ✅ زيادة حجم الخط
  void increaseFontSize() {
    if (_fontScale < _maxScale) {
      _fontScale = (_fontScale + _step).clamp(_minScale, _maxScale);
      notifyListeners();
    }
  }

  // ✅ إنقاص حجم الخط
  void decreaseFontSize() {
    if (_fontScale > _minScale) {
      _fontScale = (_fontScale - _step).clamp(_minScale, _maxScale);
      notifyListeners();
    }
  }

  // ✅ إعادة تعيين حجم الخط
  void resetFontSize() {
    _fontScale = 1.0;
    notifyListeners();
  }

  // ✅ تعيين حجم الخط مباشرة
  void setFontScale(double scale) {
    _fontScale = scale.clamp(_minScale, _maxScale);
    notifyListeners();
  }
}
