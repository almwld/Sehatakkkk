import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_icons.dart';

class AppIcon extends StatelessWidget {
  final String path;
  final double size;
  final Color? color;

  const AppIcon({
    super.key,
    required this.path,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

// ════════════════════════════════════════════════════════
// 📦 Widgets جاهزة للاستخدام
// ════════════════════════════════════════════════════════

class NavigationIcon extends StatelessWidget {
  final String path;
  final bool isSelected;
  final double size;

  const NavigationIcon({
    super.key,
    required this.path,
    this.isSelected = false,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return AppIcon(
      path: path,
      size: size,
      color: isSelected ? AppColors.primary : AppColors.grey,
    );
  }
}

class SocialIcon extends StatelessWidget {
  final String path;
  final VoidCallback? onTap;
  final double size;

  const SocialIcon({
    super.key,
    required this.path,
    this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: AppIcon(
          path: path,
          size: size,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
