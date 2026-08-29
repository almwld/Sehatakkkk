import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;
  final bool showPattern;

  const ChatBackground({
    super.key,
    required this.child,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0B1121),
                  const Color(0xFF1A2540),
                ]
              : [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFC8E6C9),
                ],
        ),
        image: showPattern
            ? DecorationImage(
                image: const AssetImage('assets/images/chat_background.svg'),
                fit: BoxFit.cover,
                opacity: isDark ? 0.1 : 0.15,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.softLight,
                ),
              )
            : null,
      ),
      child: child,
    );
  }
}

// ✅ خلفيات مخصصة للدردشة
class ChatBackgroundSelector extends StatefulWidget {
  final Function(String) onBackgroundSelected;

  const ChatBackgroundSelector({
    super.key,
    required this.onBackgroundSelected,
  });

  @override
  State<ChatBackgroundSelector> createState() => _ChatBackgroundSelectorState();
}

class _ChatBackgroundSelectorState extends State<ChatBackgroundSelector> {
  final List<Map<String, dynamic>> _backgrounds = [
    {'name': 'افتراضي', 'color': null, 'image': null},
    {'name': 'داكن', 'color': const Color(0xFF0B1121), 'image': null},
    {'name': 'فاتح', 'color': const Color(0xFFE8F5E9), 'image': null},
    {'name': 'أنيق', 'color': const Color(0xFFF5F5F5), 'image': null},
    {'name': 'طبيعة', 'image': 'assets/images/chat_bg_nature.jpg', 'color': null},
    {'name': 'بحر', 'image': 'assets/images/chat_bg_sea.jpg', 'color': null},
    {'name': 'سماء', 'image': 'assets/images/chat_bg_sky.jpg', 'color': null},
    {'name': 'أزهار', 'image': 'assets/images/chat_bg_flowers.jpg', 'color': null},
  ];

  String _selectedBackground = 'افتراضي';

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
          // ✅ شريط السحب
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
          // ✅ العنوان
          Text(
            'اختر خلفية الدردشة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // ✅ شبكة الخلفيات
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _backgrounds.length,
            itemBuilder: (context, index) {
              final bg = _backgrounds[index];
              final isSelected = _selectedBackground == bg['name'];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedBackground = bg['name']);
                  widget.onBackgroundSelected(bg['name']);
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
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
