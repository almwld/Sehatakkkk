import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SaveCancelBar extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final String saveLabel;
  final String cancelLabel;
  final bool isLoading;

  const SaveCancelBar({
    super.key,
    required this.onSave,
    this.onCancel,
    this.saveLabel = 'حفظ',
    this.cancelLabel = 'إلغاء',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextButton(onPressed: isLoading ? null : onCancel, child: Text(cancelLabel))),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(saveLabel),
          ),
        ),
      ],
    );
  }
}
