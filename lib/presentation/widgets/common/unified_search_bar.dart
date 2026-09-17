import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

/// Canonical search field dimensions used across Sehatak screens.
/// Matches the Home search surface: 52px height, 18px radius, 14px horizontal padding.
class UnifiedSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final String hintText;
  final bool isDark;
  final bool showMicrophone;
  final bool enabled;

  const UnifiedSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onClear,
    required this.hintText,
    this.isDark = false,
    this.showMicrophone = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;
    final background = isDark ? const Color(0xFF162039) : Colors.white;
    final foreground = isDark ? Colors.white70 : const Color(0xFF6B7D7D);

    return SizedBox(
      height: 52,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            enabled: enabled,
            textDirection: TextDirection.rtl,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF173131), fontSize: 13),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: foreground, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 25),
              suffixIcon: hasText
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 21),
                      color: AppColors.primary,
                      onPressed: onClear ?? controller?.clear,
                    )
                  : (showMicrophone ? const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 23) : null),
              filled: true,
              fillColor: background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
