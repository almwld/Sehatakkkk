import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String) onReactionSelected;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
  });

  final List<String> _reactions = [
    '👍', // إعجاب
    '❤️', // حب
    '😂', // ضحك
    '😮', // مفاجأة
    '😢', // حزن
    '🙏', // شكر
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _reactions.map((emoji) {
          return GestureDetector(
            onTap: () => onReactionSelected(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
