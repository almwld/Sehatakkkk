// ============================================================
// ✏️ مؤشر الكتابة المتقدم
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class TypingIndicatorPro extends StatelessWidget {
  final String name;
  final bool isGroup;
  final int count;

  const TypingIndicatorPro({
    super.key,
    required this.name,
    this.isGroup = false,
    this.count = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0] : 'م',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGroup ? '$name (${count + 1} يكتبون)' : '$name يكتب...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _buildDot(Colors.red),
                    const SizedBox(width: 4),
                    _buildDot(Colors.amber),
                    const SizedBox(width: 4),
                    _buildDot(Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
