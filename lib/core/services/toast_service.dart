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
    double borderRadius = 12.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: duration > 3 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      webBgColor: 'rgba(13, 82, 87, 0.85)',
      webPosition: 'center',
    );
  }

  // ✅ نجاح - أخضر شفاف
  static void showSuccess(String message) {
    show(
      message: message,
      backgroundColor: AppColors.success.withOpacity(0.85), // ✅ شفاف 85%
      textColor: Colors.white,
    );
  }

  // ✅ خطأ - أحمر شفاف
  static void showError(String message) {
    show(
      message: message,
      backgroundColor: Colors.red.withOpacity(0.85), // ✅ أحمر شفاف
      textColor: Colors.white,
    );
  }

  // ✅ تحذير - برتقالي شفاف
  static void showWarning(String message) {
    show(
      message: message,
      backgroundColor: Colors.orange.withOpacity(0.85), // ✅ برتقالي شفاف
      textColor: Colors.white,
    );
  }

  // ✅ معلومات - أزرق شفاف
  static void showInfo(String message) {
    show(
      message: message,
      backgroundColor: Colors.blue.withOpacity(0.85), // ✅ أزرق شفاف
      textColor: Colors.white,
    );
  }

  // ✅ عادي - لون التطبيق شفاف
  static void showDefault(String message) {
    show(
      message: message,
      backgroundColor: AppColors.primary.withOpacity(0.85), // ✅ لون التطبيق شفاف
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

  // ✅ Toast بأيقونة
  static void showWithIcon({
    required String message,
    required IconData icon,
    Color iconColor = Colors.white,
    Color backgroundColor = AppColors.primary,
  }) {
    // استخدام Fluttertoast مباشرة مع widget مخصص
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.transparent,
      webBgColor: 'rgba(0,0,0,0)',
      webPosition: 'center',
      toast: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Toast مع أيقونة نجاح
  static void showSuccessWithIcon(String message) {
    showWithIcon(
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.white,
      backgroundColor: Colors.green,
    );
  }

  // ✅ Toast مع أيقونة خطأ
  static void showErrorWithIcon(String message) {
    showWithIcon(
      message: message,
      icon: Icons.error_rounded,
      iconColor: Colors.white,
      backgroundColor: Colors.red,
    );
  }

  // ✅ Toast مع أيقونة معلومات
  static void showInfoWithIcon(String message) {
    showWithIcon(
      message: message,
      icon: Icons.info_rounded,
      iconColor: Colors.white,
      backgroundColor: Colors.blue,
    );
  }

  // ✅ Toast مع أيقونة تحذير
  static void showWarningWithIcon(String message) {
    showWithIcon(
      message: message,
      icon: Icons.warning_rounded,
      iconColor: Colors.white,
      backgroundColor: Colors.orange,
    );
  }
}
