import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

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
      title: Text(title),
      content: message != null ? Text(message!) : null,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
