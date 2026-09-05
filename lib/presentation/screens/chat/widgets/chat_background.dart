// ============================================================
// 📁 lib/presentation/screens/chat/widgets/chat_background.dart
// 🎨 خلفية شاشة الدردشة
// ============================================================

import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;

  const ChatBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        image: DecorationImage(
          image: AssetImage(
            isDark
                ? 'assets/images/sehatak_chat_wallpaper_dark_1080x2160.png'
                : 'assets/images/sehatak_chat_wallpaper_light_1080x2160.png',
          ),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: child,
    );
  }
}
