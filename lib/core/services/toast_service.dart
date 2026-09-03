import 'package:flutter/material.dart';

class ToastService {
  static void showSuccess(String message) {
    _showToast(message, Colors.green);
  }

  static void showError(String message) {
    _showToast(message, Colors.red);
  }

  static void showInfo(String message) {
    _showToast(message, Colors.blue);
  }

  static void showWarning(String message) {
    _showToast(message, Colors.orange);
  }

  static void _showToast(String message, Color color) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      print('⚠️ Toast: $message');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  static GlobalKey<NavigatorState>? _navigatorKey;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }
}
