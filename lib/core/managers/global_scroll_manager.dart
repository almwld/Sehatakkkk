// ============================================================
// 🌍 GlobalScrollManager - مدير التمرير العام للتطبيق
// يتحكم في إظهار/إخفاء الشريط السفلي بناءً على حركة التمرير
// في أي شاشة دون الحاجة لتعديلها
// ============================================================

import 'package:flutter/material.dart';

class GlobalScrollManager extends ChangeNotifier implements ValueListenable<bool> {
  // ✅ Singleton Pattern - نسخة واحدة للتطبيق بالكامل
  static final GlobalScrollManager _instance = GlobalScrollManager._internal();
  factory GlobalScrollManager() => _instance;
  GlobalScrollManager._internal();

  bool _isVisible = true;
  double _lastPosition = 0;
  
  // ✅ حفظ موضع التمرير لكل شاشة على حدة
  final Map<String, double> _screenPositions = {};
  
  // ✅ اسم الشاشة الحالية
  String? _currentRoute;

  bool get isVisible => _isVisible;
  double get lastPosition => _lastPosition;
  
  set lastPosition(double value) {
    _lastPosition = value;
  }

  @override
  bool get value => _isVisible;

  // ✅ تسجيل دخول الشاشة الجديدة
  void registerScreen(String route) {
    _currentRoute = route;
    
    // استرجاع الموضع السابق للشاشة إن وجد
    if (_screenPositions.containsKey(route)) {
      _lastPosition = _screenPositions[route]!;
    } else {
      _screenPositions[route] = 0;
    }
    
    // إظهار الشريط عند تغيير الشاشة
    _isVisible = true;
    notifyListeners();
  }

  // ✅ حفظ موضع التمرير لكل شاشة
  void savePosition(String route, double position) {
    _screenPositions[route] = position;
  }

  // ✅ إظهار الشريط
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  // ✅ إخفاء الشريط
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  // ✅ إعادة ضبط الشريط
  void reset() {
    _isVisible = true;
    _lastPosition = 0;
    notifyListeners();
  }

  // ✅ التحقق من الشاشات المستثناة
  bool isExcludedRoute(String route) {
    final excludedRoutes = [
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
    _screenPositions.clear();
    super.dispose();
  }
}
