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
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 60 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, -4),
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
        height: 56,
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

  // 💬 زر الدردشة مرتفع عن مستوى الشريط بشكل احترافي.
  // Stack + Clip.none يمنع قص الدائرة عند خروجها أعلى الشريط.
  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        height: 60,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                ),
              ),
            ),
            Positioned(
              top: -17,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
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
