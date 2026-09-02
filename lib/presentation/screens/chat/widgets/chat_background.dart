import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;

  const ChatBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: child,
    );
  }
}
