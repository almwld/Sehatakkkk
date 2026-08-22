import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  final String? name;

  const TypingIndicator({super.key, this.name});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animations = List.generate(3, (index) {
      final delay = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ النقاط المتحركة
          Row(
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 8,
                    height: 8 * (0.3 + 0.7 * _animations[index].value),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(
                        0.3 + 0.7 * _animations[index].value,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(width: 8),
          Text(
            widget.name != null ? '${widget.name} يكتب...' : 'يكتب...',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
