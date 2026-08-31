// ============================================================
// 📱 CustomBottomNavigationBar - شريط التنقل السفلي المخصص
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final GlobalScrollManager scrollManager;
  final bool isLoggedIn;
  final VoidCallback onAuthRequired;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.scrollManager,
    required this.isLoggedIn,
    required this.onAuthRequired,
  });

  final List<NavItem> _navItems = const [
    NavItem(index: 0, icon: Icons.home_rounded, label: 'الرئيسية'),
    NavItem(index: 1, icon: Icons.person_search_rounded, label: 'الأطباء'),
    NavItem(index: 2, icon: Icons.local_pharmacy_rounded, label: 'الصيدلية'),
    NavItem(index: 3, icon: Icons.chat_rounded, label: 'الدردشة', isSpecial: true, isProtected: true),
    NavItem(index: 4, icon: Icons.science_rounded, label: 'مختبرات', isProtected: true),
    NavItem(index: 5, icon: Icons.folder_rounded, label: 'صحتي', isProtected: true),
    NavItem(index: 6, icon: Icons.grid_view_rounded, label: 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _navItems.map((item) {
        if (item.isSpecial) {
          return _buildSpecialChatButton(item, isDark);
        }
        return _buildNavItem(item, isDark);
      }).toList(),
    );
  }

  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final color = isSelected ? AppColors.primary : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

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
            Icon(item.icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(item.label, style: TextStyle(fontSize: 9, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: color)),
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final color = isSelected ? AppColors.primary : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

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
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 14, offset: Offset(0, 4))],
                ),
                child: Icon(item.icon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 2),
            Text(item.label, style: TextStyle(fontSize: 9, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: color)),
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  void _handleTap(NavItem item) {
    if (item.isProtected && !isLoggedIn) {
      onAuthRequired();
      return;
    }
    HapticFeedback.lightImpact();
    onTap(item.index);
  }
}

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
