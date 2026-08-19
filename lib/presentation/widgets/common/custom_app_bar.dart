import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? AppColors.backgroundDark : AppColors.primary);
    final fgColor = foregroundColor ?? (isDark ? Colors.white : Colors.white);

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      elevation: elevation,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: IconThemeData(color: fgColor),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
