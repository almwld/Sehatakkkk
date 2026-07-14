import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SnackBarHelper {
  // ✅ SnackBar نجاح - رمادي فاخر
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.successSnackBar, Icons.check_circle);
  }

  // ✅ SnackBar خطأ - رمادي فاخر
  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.errorSnackBar, Icons.error_outline);
  }

  // ✅ SnackBar تحذير - رمادي فاخر
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.warningSnackBar, Icons.warning_amber_rounded);
  }

  // ✅ SnackBar معلومات - رمادي فاخر
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, AppColors.infoSnackBar, Icons.info_outline);
  }

  // ✅ SnackBar مخصص
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor ?? AppColors.primarySnackBar,
      icon ?? Icons.circle,
      duration: duration,
    );
  }

  // ✅ الدالة الأساسية
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'NotoSansArabicUI',
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration,
        elevation: 6,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
