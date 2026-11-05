import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

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
    final strings = AppStrings.of(context);
    final localizedSave = saveLabel == 'حفظ' ? strings.save : strings.translate(saveLabel);
    final localizedCancel = cancelLabel == 'إلغاء' ? strings.cancel : strings.translate(cancelLabel);
    return Row(
      children: [
        Expanded(child: TextButton(onPressed: isLoading ? null : onCancel, child: Text(localizedCancel))),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(localizedSave),
          ),
        ),
      ],
    );
  }
}
