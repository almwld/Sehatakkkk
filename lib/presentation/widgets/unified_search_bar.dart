import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_assets.dart';

/// Search field with the same geometry as the Home search bar.
/// Colors remain configurable so each screen keeps its existing visual theme.
class UnifiedSearchBar extends StatelessWidget {
  static const double height = 48;
  static const double horizontalMargin = 16;
  static const double borderRadius = 24;
  static const double iconSize = 22;

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final EdgeInsetsGeometry margin;

  const UnifiedSearchBar({
    super.key,
    this.hint = 'بحث...',
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.hintColor,
    this.margin = const EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? const Color(0xFF1A2540) : Colors.grey[100]!);
    final border = borderColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final text = textColor ?? (isDark ? Colors.white : Colors.black87);
    final hintText = hintColor ?? (isDark ? Colors.grey[500]! : Colors.grey[400]!);

    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        textAlign: TextAlign.right,
        style: TextStyle(color: text, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: hintText, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13),
            child: SvgPicture.asset(
              AppAssets.searchIcon,
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(hintText, BlendMode.srcIn),
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
