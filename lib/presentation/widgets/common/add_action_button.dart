import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

enum AddButtonVariant { appBar, fab, text, outlined }

class AddActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final String? tooltip;
  final AddButtonVariant variant;
  final String? heroTag;

  const AddActionButton({
    super.key,
    required this.onPressed,
    this.label,
    this.tooltip = 'إضافة',
    this.variant = AddButtonVariant.appBar,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final strings = AppStrings.of(context);
    final buttonLabel = strings.translate(label ?? 'إضافة');
    final buttonTooltip = tooltip == null ? null : strings.translate(tooltip!);

    switch (variant) {
      case AddButtonVariant.appBar:
        return IconButton(
          onPressed: onPressed,
          tooltip: buttonTooltip,
          icon: const Icon(Icons.add_rounded),
          color: Colors.white,
          disabledColor: Colors.white38,
        );
      case AddButtonVariant.fab:
        return FloatingActionButton.extended(
          heroTag: heroTag ?? 'add_fab_${label ?? "default"}',
          onPressed: onPressed,
          backgroundColor: enabled ? AppColors.primary : Colors.grey,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: Text(buttonLabel),
        );
      case AddButtonVariant.text:
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(buttonLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      case AddButtonVariant.outlined:
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(buttonLabel),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
    }
  }
}
