import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/ai/assistant_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? const Color(0xFF0B1121) : Colors.white);
    final fgColor = foregroundColor ?? (isDark ? Colors.white : Colors.black87);

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: fgColor),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : leading,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: fgColor,
        ),
      ),
      actions: [
        // ✅ زر المساعد الصحي
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AIChatbotScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Image.asset(
              'assets/images/services/ai_assistant.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.medical_services,
                  color: fgColor,
                  size: 28,
                );
              },
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
