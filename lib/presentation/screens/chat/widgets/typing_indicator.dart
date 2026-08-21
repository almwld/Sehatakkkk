import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const TypingIndicator({
    super.key,
    this.color,
    this.size = 20,
  });

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
    final color = widget.color ?? AppColors.primary;

    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: widget.size * 0.25,
                height: widget.size * (0.3 + 0.7 * _animations[index].value),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3 + 0.7 * _animations[index].value),
                  borderRadius: BorderRadius.circular(widget.size * 0.25),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
