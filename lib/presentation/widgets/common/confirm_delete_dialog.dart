import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmLabel;

  const ConfirmDeleteDialog({
    super.key,
    this.title = 'تأكيد الحذف',
    this.message,
    this.confirmLabel = 'حذف',
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'تأكيد الحذف',
    String? message,
    String confirmLabel = 'حذف',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.of(context).translate(title)),
      content: message != null ? Text(AppStrings.of(context).translate(message!)) : null,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.of(context).translate('إلغاء'))),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
          child: Text(AppStrings.of(context).translate(confirmLabel)),
        ),
      ],
    );
  }
}
