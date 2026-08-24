import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ToastService {
  static void show({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    int duration = 3,
    Color backgroundColor = AppColors.primary,
    Color textColor = Colors.white,
    double fontSize = 14.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 3 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }

  // ✅ نجاح - أخضر شفاف
  static void showSuccess(String message) {
    show(
      message: message,
      backgroundColor: AppColors.success.withOpacity(0.85),
      textColor: Colors.white,
    );
  }

  // ✅ خطأ - أحمر شفاف
  static void showError(String message) {
    show(
      message: message,
      backgroundColor: Colors.red.withOpacity(0.85),
      textColor: Colors.white,
    );
  }

  // ✅ تحذير - برتقالي شفاف
  static void showWarning(String message) {
    show(
      message: message,
      backgroundColor: Colors.orange.withOpacity(0.85),
      textColor: Colors.white,
    );
  }

  // ✅ معلومات - أزرق شفاف
  static void showInfo(String message) {
    show(
      message: message,
      backgroundColor: Colors.blue.withOpacity(0.85),
      textColor: Colors.white,
    );
  }

  // ✅ عادي - لون التطبيق شفاف
  static void showDefault(String message) {
    show(
      message: message,
      backgroundColor: AppColors.primary.withOpacity(0.85),
      textColor: Colors.white,
    );
  }

  // ✅ مخصص - مع إمكانية التحكم الكامل
  static void showCustom({
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    double fontSize = 14.0,
  }) {
    show(
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
