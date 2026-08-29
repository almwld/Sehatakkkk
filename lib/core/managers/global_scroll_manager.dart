// ============================================================
// 📁 lib/core/managers/global_scroll_manager.dart
// 📡 مدير التمرير العالمي - يتحكم في إخفاء/إظهار الشريط السفلي
// ============================================================

import 'package:flutter/material.dart';

class GlobalScrollManager {
  // ✅ الحالة الحالية للشريط
  bool _isVisible = true;
  
  // ✅ موضع التمرير لكل شاشة
  final Map<String, double> _scrollPositions = {};
  
  // ✅ آخر موضع تم تمريره
  double lastPosition = 0;
  
  // ✅ قائمة الشاشات المستثناة
  final List<String> _excludedRoutes = [
    '/chat',
    '/video_call',
    '/consultation',
  ];

  // ✅ التحقق مما إذا كانت الشاشة مستثناة
  bool isExcluded(String route) {
    return _excludedRoutes.any((r) => route.contains(r));
  }

  // ✅ إظهار الشريط
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      _notifyListeners();
    }
  }

  // ✅ إخفاء الشريط
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      _notifyListeners();
    }
  }

  // ✅ تبديل حالة الشريط
  void toggle() {
    _isVisible = !_isVisible;
    _notifyListeners();
  }

  // ✅ الحصول على حالة الشريط
  bool get isVisible => _isVisible;

  // ✅ حفظ موضع التمرير للشاشة
  void savePosition(String route, double position) {
    _scrollPositions[route] = position;
  }

  // ✅ استعادة موضع التمرير للشاشة
  double? getPosition(String route) {
    return _scrollPositions[route];
  }

  // ✅ إعادة تعيين حالة الشريط
  void reset() {
    _isVisible = true;
    lastPosition = 0;
    _notifyListeners();
  }

  // ✅ إعادة تعيين مواضع التمرير
  void resetPositions() {
    _scrollPositions.clear();
  }

  // ✅ إضافة شاشة مستثناة
  void addExcludedRoute(String route) {
    if (!_excludedRoutes.contains(route)) {
      _excludedRoutes.add(route);
    }
  }

  // ✅ إزالة شاشة مستثناة
  void removeExcludedRoute(String route) {
    _excludedRoutes.remove(route);
  }

  // ✅ إعلام المستمعين بتغيير الحالة
  void _notifyListeners() {
    // يمكن إضافة مستمعين هنا إذا لزم الأمر
    // مثلاً: ValueNotifier أو StreamController
  }

  // ✅ التخلص من الموارد
  void dispose() {
    _scrollPositions.clear();
    _excludedRoutes.clear();
  }
}
