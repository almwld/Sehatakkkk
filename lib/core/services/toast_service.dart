// ============================================================
// 🍞 خدمة الإشعارات المنبثقة (Toast)
// ============================================================

import 'package:flutter/material.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  static GlobalKey<ScaffoldMessengerState>? _scaffoldKey;

  // ============================================================
  // 🔗 ربط المفتاح
  // ============================================================

  static void setScaffoldKey(GlobalKey<ScaffoldMessengerState> key) {
    _scaffoldKey = key;
  }

  // ============================================================
  // 📤 عرض الإشعارات
  // ============================================================

  static void showSuccess(String message) {
    _showToast(message, Colors.green, Icons.check_circle);
  }

  static void showError(String message) {
    _showToast(message, Colors.red, Icons.error);
  }

  static void showInfo(String message) {
    _showToast(message, Colors.blue, Icons.info);
  }

  static void showWarning(String message) {
    _showToast(message, Colors.orange, Icons.warning);
  }

  static void showCustom({
    required String message,
    required Color color,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showToast(message, color, icon, duration: duration);
  }

  // ============================================================
  // 🛠️ العرض الفعلي
  // ============================================================

  static void _showToast(
    String message,
    Color color,
    IconData? icon, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_scaffoldKey == null) {
      print('⚠️ ToastService: Scaffold key not set');
      return;
    }

    final context = _scaffoldKey!.currentContext;
    if (context == null) {
      print('⚠️ ToastService: No context available');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ============================================================
  // 📤 عرض إشعار مع زر إجراء
  // ============================================================

  static void showAction({
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Color color = Colors.blue,
    Duration duration = const Duration(seconds: 5),
  }) {
    if (_scaffoldKey == null) return;
    final context = _scaffoldKey!.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ============================================================
  // ⏳ عرض تحميل
  // ============================================================

  static SnackBar showLoading({
    required String message,
    Color color = Colors.blue,
  }) {
    return SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(12),
      duration: const Duration(days: 365), // غير محدود
    );
  }

  static void hideSnackBar() {
    if (_scaffoldKey == null) return;
    final context = _scaffoldKey!.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void clearSnackBars() {
    if (_scaffoldKey == null) return;
    final context = _scaffoldKey!.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
