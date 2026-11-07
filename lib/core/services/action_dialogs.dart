import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/services/toast_service.dart';

class ActionDialogs {
  static String _t(BuildContext context, String value) =>
      AppStrings.of(context).translate(value);

  static void showConfirmDialog({required BuildContext context, required String title, required String message, required VoidCallback onConfirm, String confirmText = 'نعم', String cancelText = 'إلغاء'}) {
    showDialog<void>(context: context, builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_t(context, title), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text(_t(context, message), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t(context, cancelText))),
          ElevatedButton(onPressed: () { Navigator.pop(context); onConfirm(); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: Text(_t(context, confirmText))),
        ],
      );
    });
  }
  static void showCallDialog(BuildContext context, String action) => showConfirmDialog(context: context, title: _t(context, action), message: _t(context, 'هل تريد بدء هذه العملية مع جهة الاتصال؟'), onConfirm: () => ToastService.showInfo('${_t(context, 'جاري تنفيذ: ')}${_t(context, action)}...'));
}
