// ============================================================
// 📱 CustomBottomNavigationBar - شريط التنقل السفلي المخصص
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/managers/global_scroll_manager.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final ScrollController? scrollController;
  final GlobalScrollManager? scrollManager;
  final bool isLoggedIn;
  final VoidCallback onAuthRequired;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.scrollController,
    this.scrollManager,
    required this.isLoggedIn,
    required this.onAuthRequired,
  });

  static const List<NavItem> _navItems = [
    NavItem(index: 0, icon: Icons.home_rounded, label: 'الرئيسية'),
    NavItem(index: 1, icon: Icons.person_search_rounded, label: 'الأطباء'),
    NavItem(index: 2, icon: Icons.local_pharmacy_rounded, label: 'الصيدلية'),
    NavItem(index: 3, icon: Icons.chat_rounded, label: 'الدردشة', isSpecial: true),
    NavItem(index: 4, icon: Icons.science_rounded, label: 'مختبرات'),
    NavItem(index: 5, icon: Icons.folder_rounded, label: 'صحتي', isProtected: true),
    NavItem(index: 6, icon: Icons.grid_view_rounded, label: 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // The bar is tall enough to contain the elevated chat button completely.
    // No negative-positioned content is used, so Scaffold cannot clip it.
    return Container(
      height: 72,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _navItems.map((item) {
          return item.isSpecial
              ? _buildSpecialChatButton(item, isDark)
              : _buildNavItem(item, isDark);
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              size: isSelected ? 24 : 22,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
            if (isSelected)
              Container(
                width: 16,
                height: 3,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // 💬 The complete chat button stays inside the navigation bar bounds.
  // This avoids the previous top:-17 overflow that could be clipped by the
  // Scaffold bottomNavigationBar slot.
  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.32),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
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
    onTap(item.index);
    scrollManager?.show();
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
