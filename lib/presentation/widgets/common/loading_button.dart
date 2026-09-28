import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : (icon != null ? Icon(icon, size: 18) : const SizedBox()),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color ?? AppColors.primary, foregroundColor: Colors.white),
    );
  }
}
