import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MuteToggle extends StatefulWidget {
  final bool isMuted;
  final Function(bool) onChanged;

  const MuteToggle({
    super.key,
    required this.isMuted,
    required this.onChanged,
  });

  @override
  State<MuteToggle> createState() => _MuteToggleState();
}

class _MuteToggleState extends State<MuteToggle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _controller.forward().then((_) {
      widget.onChanged(!widget.isMuted);
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isMuted
                    ? (isDark ? const Color(0xFF2D3A54) : Colors.grey[200])
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isMuted
                      ? Colors.grey
                      : AppColors.primary,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isMuted ? Icons.notifications_off : Icons.notifications_active,
                    color: widget.isMuted
                        ? (isDark ? Colors.grey[400] : Colors.grey[600])
                        : AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isMuted ? 'مكتوم' : 'غير مكتوم',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isMuted
                          ? (isDark ? Colors.grey[400] : Colors.grey[600])
                          : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
