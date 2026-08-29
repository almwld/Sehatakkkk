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
    // استخدام ScaffoldMessenger لعرض SnackBar
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      // طباعة في الكونسول إذا لم يكن هناك Context
      print('📢 $message');
    }
  }
}

// ✅ GlobalKey للـ Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
