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
        color: isDark ? const Color(0xFF0B1121) : const Color(0xFFF5F5F5),
        image: DecorationImage(
          image: AssetImage(
            isDark
                ? 'assets/images/ui/chat_background.png'
                : 'assets/images/ui/chat_background.png',
          ),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: child,
    );
  }
}
