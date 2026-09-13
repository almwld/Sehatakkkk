import 'package:flutter/material.dart';
import 'package:sehatak/presentation/widgets/unified_search_bar.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return UnifiedSearchBar(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      hint: 'ابحث عن طبيب، دواء، أو مستشفى...',
      backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey[100]!,
      borderColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      textColor: isDark ? Colors.white : Colors.black87,
      hintColor: iconColor,
      suffixIcon: Icon(Icons.mic, color: iconColor),
    );
  }
}
