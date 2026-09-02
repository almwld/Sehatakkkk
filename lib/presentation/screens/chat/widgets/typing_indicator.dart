import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final bool visible;

  const TypingIndicator({
    super.key,
    this.visible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 16,
        bottom: 8,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          'يكتب الآن...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
