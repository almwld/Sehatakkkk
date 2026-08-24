import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;

  const ChatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/chat_background.svg'),
          fit: BoxFit.cover,
          opacity: isDark ? 0.15 : 0.3,
          colorFilter: ColorFilter.mode(
            isDark ? Colors.grey[900]! : Colors.grey[100]!,
            BlendMode.softLight,
          ),
        ),
      ),
      child: child,
    );
  }
}
