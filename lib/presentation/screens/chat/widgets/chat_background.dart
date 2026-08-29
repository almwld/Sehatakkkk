// ============================================================
// 🖼️ خلفية الدردشة
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;
  final bool showPattern;
  final String? imagePath;
  final Color? backgroundColor;

  const ChatBackground({
    super.key,
    required this.child,
    this.showPattern = true,
    this.imagePath,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkBackground : AppColors.lightBackground),
        image: imagePath != null
            ? DecorationImage(
                image: AssetImage(imagePath!),
                fit: BoxFit.cover,
                opacity: 0.8,
              )
            : null,
        gradient: imagePath == null && backgroundColor == null
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [AppColors.darkBackground, AppColors.darkCard]
                    : [AppColors.lightBackground, Colors.white],
              )
            : null,
      ),
      child: child,
    );
  }
}

// ============================================================
// 🖼️ منتقي خلفية الدردشة
// ============================================================

class ChatBackgroundSelector extends StatelessWidget {
  final String currentBackground;
  final Function(String) onBackgroundSelected;

  const ChatBackgroundSelector({
    super.key,
    required this.currentBackground,
    required this.onBackgroundSelected,
  });

  final List<Map<String, dynamic>> _backgrounds = [
    {'name': 'افتراضي', 'color': null, 'image': null},
    {'name': 'داكن', 'color': const Color(0xFF0B1121), 'image': null},
    {'name': 'فاتح', 'color': const Color(0xFFE8F5E9), 'image': null},
    {'name': 'أزرق', 'color': const Color(0xFFE3F2FD), 'image': null},
    {'name': 'طبيعة', 'image': 'assets/images/chat_bg_nature.jpg', 'color': null},
    {'name': 'بحر', 'image': 'assets/images/chat_bg_sea.jpg', 'color': null},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اختر خلفية الدردشة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _backgrounds.length,
            itemBuilder: (context, index) {
              final bg = _backgrounds[index];
              final isSelected = currentBackground == bg['name'];

              return GestureDetector(
                onTap: () {
                  onBackgroundSelected(bg['name']);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bg['color'] ?? (isDark ? Colors.grey[800] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                    image: bg['image'] != null
                        ? DecorationImage(
                            image: AssetImage(bg['image']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      Center(
                        child: Text(
                          bg['name'],
                          style: TextStyle(
                            fontSize: 10,
                            color: bg['color'] != null
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
