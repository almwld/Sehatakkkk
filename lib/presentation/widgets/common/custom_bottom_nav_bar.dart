// ============================================================
// 📱 CustomBottomNavigationBar - شريط التنقل السفلي المخصص
// ✅ يدعم التمرير العالمي عبر GlobalScrollManager
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final ScrollController scrollController;
  final bool isLoggedIn;
  final VoidCallback onAuthRequired;
  final GlobalScrollManager? scrollManager;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.scrollController,
    required this.isLoggedIn,
    required this.onAuthRequired,
    this.scrollManager,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState
    extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  
  // ✅ استخدام ValueNotifier محلي
  final ValueNotifier<bool> _isBottomBarVisible = ValueNotifier<bool>(true);

  // ✅ قائمة عناصر التنقل
  final List<NavItem> _navItems = const [
    NavItem(index: 0, icon: Icons.home_rounded, label: 'الرئيسية'),
    NavItem(index: 1, icon: Icons.person_search_rounded, label: 'الأطباء'),
    NavItem(index: 2, icon: Icons.local_pharmacy_rounded, label: 'الصيدلية'),
    NavItem(
      index: 3,
      icon: Icons.chat_rounded,
      label: 'الدردشة',
      isSpecial: true,
      isProtected: true,
    ),
    NavItem(index: 4, icon: Icons.science_rounded, label: 'مختبرات', isProtected: true),
    NavItem(index: 5, icon: Icons.folder_rounded, label: 'صحتي', isProtected: true),
    NavItem(index: 6, icon: Icons.grid_view_rounded, label: 'المزيد'),
  ];

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _isBottomBarVisible.dispose();
    super.dispose();
  }

  // ✅ دالة التمرير والاختفاء مع التحقق من mounted
  void _onScroll() {
    // ✅ التحقق من mounted لتجنب الأخطاء
    if (!mounted) return;
    if (!widget.scrollController.hasClients) return;

    final direction = widget.scrollController.position.userScrollDirection;

    // ⬇️ تمرير للأسفل → إخفاء الشريط
    if (direction == ScrollDirection.reverse) {
      if (_isBottomBarVisible.value != false) {
        _isBottomBarVisible.value = false;
        // ✅ إعلام المدير العالمي
        widget.scrollManager?.hide();
      }
    }
    // ⬆️ تمرير للأعلى → إظهار الشريط
    else if (direction == ScrollDirection.forward) {
      if (_isBottomBarVisible.value != true) {
        _isBottomBarVisible.value = true;
        // ✅ إعلام المدير العالمي
        widget.scrollManager?.show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return ValueListenableBuilder<bool>(
      valueListenable: _isBottomBarVisible,
      builder: (context, isVisible, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isVisible ? 60 : 0,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _navItems.map((item) {
                  if (item.isSpecial) {
                    return _buildSpecialChatButton(item);
                  }
                  return _buildNavItem(item);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ زر عادي
  Widget _buildNavItem(NavItem item) {
    final isSelected = widget.currentIndex == item.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  // ✅ زر الدردشة المميز
  Widget _buildSpecialChatButton(NavItem item) {
    final isSelected = widget.currentIndex == item.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  // ✅ دالة التعامل مع الضغط
  void _handleTap(NavItem item) {
    if (item.isProtected && !widget.isLoggedIn) {
      widget.onAuthRequired();
      return;
    }

    HapticFeedback.lightImpact();
    widget.onTap(item.index);
    
    // ✅ إظهار الشريط عند التنقل
    _isBottomBarVisible.value = true;
    widget.scrollManager?.show();
    widget.scrollManager?.reset();
  }
}

// ✅ نموذج عنصر التنقل
class NavItem {
  final int index;
  final IconData icon;
  final String label;
  final bool isProtected;
  final bool isSpecial;

  const NavItem({
    required this.index,
    required this.icon,
    required this.label,
    this.isProtected = false,
    this.isSpecial = false,
  });
}
