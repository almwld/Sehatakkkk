import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

/// Shared animated typing state used by the main chat room and other chat UI.
class TypingIndicator extends StatefulWidget {
  final String name;
  final bool compact;

  const TypingIndicator({
    super.key,
    this.name = '',
    this.compact = false,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = dark ? const Color(0xFF8BE0D6) : AppColors.primary;
    final labelColor = dark ? Colors.grey.shade300 : Colors.grey.shade700;

    return Padding(
      padding: widget.compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.name.isNotEmpty) ...[
            Flexible(
              child: Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            widget.compact ? 'يكتب الآن' : 'يكتب',
            style: TextStyle(
              color: labelColor,
              fontSize: widget.compact ? 11 : 12,
              fontWeight: widget.compact ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_controller.value + index / 3) % 1;
                final scale =
                    .65 + .35 * (.5 + .5 * math.sin(phase * 2 * math.pi));
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.compact ? 4.5 : 5.5,
                    height: widget.compact ? 4.5 : 5.5,
                    margin: EdgeInsetsDirectional.only(
                      end: index == 2 ? 0 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
