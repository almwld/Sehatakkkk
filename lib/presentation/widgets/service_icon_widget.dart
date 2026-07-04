import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceIconWidget extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final bool isPng;

  const ServiceIconWidget({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.iconColor = const Color(0xFF0D5257),
    this.backgroundColor = Colors.white,
    this.size = 30,
    this.isPng = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : backgroundColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isPng
                ? Image.asset(
                    iconPath,
                    width: size,
                    height: size,
                    color: iconColor,
                  )
                : SvgPicture.asset(
                    iconPath,
                    width: size,
                    height: size,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
