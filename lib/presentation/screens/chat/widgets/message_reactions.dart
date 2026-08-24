import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MessageReactions extends StatefulWidget {
  final Function(String) onReactionSelected;
  final List<String> currentReactions;

  const MessageReactions({
    super.key,
    required this.onReactionSelected,
    this.currentReactions = const [],
  });

  @override
  State<MessageReactions> createState() => _MessageReactionsState();
}

class _MessageReactionsState extends State<MessageReactions> {
  final List<String> _reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '👏'];
  String? _selectedReaction;

  @override
  void initState() {
    super.initState();
    // ✅ التحقق من التفاعل الحالي
    if (widget.currentReactions.isNotEmpty) {
      _selectedReaction = widget.currentReactions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ شريط السحب
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ قائمة الإيموجي
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reactions.map((emoji) {
              final isSelected = _selectedReaction == emoji;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedReaction = emoji);
                  widget.onReactionSelected(emoji);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 28,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // ✅ زر إزالة التفاعل
          if (_selectedReaction != null)
            TextButton(
              onPressed: () {
                setState(() => _selectedReaction = null);
                widget.onReactionSelected('');
                Navigator.pop(context);
              },
              child: const Text(
                'إزالة التفاعل',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
