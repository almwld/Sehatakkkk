import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/text_styles.dart';

class DeleteMessageDialog extends StatelessWidget {
  final String messageText;
  final bool isForEveryone;
  final VoidCallback onDelete;

  const DeleteMessageDialog({
    super.key,
    required this.messageText,
    required this.isForEveryone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
      title: Row(
        children: [
          const Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'حذف الرسالة',
            style: TextStyles.headline6.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هل أنت متأكد من حذف هذه الرسالة؟',
            style: TextStyles.body2.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              messageText,
              style: TextStyles.body2.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isForEveryone)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم حذف هذه الرسالة للجميع',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        TextButton(
          onPressed: onDelete,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('حذف'),
        ),
      ],
    );
  }
}
