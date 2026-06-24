import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class TypingIndicator extends StatelessWidget {
  final String? name;
  const TypingIndicator({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning.withOpacity(0.1),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            name != null ? '$name يكتب...' : 'يكتب...',
            style: const TextStyle(color: AppColors.warning, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
