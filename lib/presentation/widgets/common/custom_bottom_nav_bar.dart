import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isVisible;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isVisible = true,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCartIcon(bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.local_pharmacy_rounded,
          color: widget.currentIndex == 2
              ? AppColors.primary
              : (isDark ? Colors.grey[400] : Colors.grey[600]),
          size: 22,
        ),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: const Text(
              '3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingChatButton(bool isDark) {
    final isSelected = widget.currentIndex == 3;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(3),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: const Offset(0, -14), // ✅ تقليل الارتفاع
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46, // ✅ تصغير الحجم
                    height: 46,
                    decoration: BoxDecoration(
                      // ✅ تغيير اللون إلى AppColors.primary
                      color: isSelected ? AppColors.primary : Colors.grey[300],
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: isDark ? const Color(0xFF0B1121) : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.chat_rounded,
                      color: isSelected ? Colors.white : Colors.grey[500],
                      size: 22, // ✅ تصغير حجم الأيقونة
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'الدردشة',
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
    Widget? customIcon,
  }) {
    final isSelected = widget.currentIndex == index;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            customIcon ?? Icon(icon, color: color, size: 20), // ✅ تصغير حجم الأيقونة
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 8, // ✅ تصغير حجم النص
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 10 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: 55, // ✅ تقليل ارتفاع الشريط من 65 إلى 55
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B1121) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.person_search_rounded,
                label: 'الأطباء',
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.local_pharmacy_rounded,
                label: 'الصيدلية',
                index: 2,
                isDark: isDark,
                customIcon: _buildCartIcon(isDark),
              ),
              _buildFloatingChatButton(isDark),
              _buildNavItem(
                icon: Icons.science_rounded,
                label: 'مختبرات',
                index: 4,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.folder_rounded,
                label: 'صحتي',
                index: 5,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                label: 'المزيد',
                index: 6,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
