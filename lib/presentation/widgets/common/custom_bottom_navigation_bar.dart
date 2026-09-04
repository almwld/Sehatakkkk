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

  // ✅ قائمة عناصر التنقل
  final List<NavItem> _navItems = const [
    NavItem(index: 0, icon: Icons.home_rounded, label: 'الرئيسية'),
    NavItem(index: 1, icon: Icons.person_search_rounded, label: 'الأطباء'),
    NavItem(index: 2, icon: Icons.local_pharmacy_rounded, label: 'الصيدلية'),
    NavItem(index: 3, icon: Icons.chat_rounded, label: 'الدردشة', isProtected: true, isSpecial: true),
    NavItem(index: 4, icon: Icons.science_rounded, label: 'مختبرات', isProtected: true),
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
        children: _navItems.map((item) {
          if (item.isSpecial) {
            return _buildSpecialChatButton(item, isDark);
          }
          return _buildNavItem(item, isDark);
        }).toList(),
      ),
    );
  }

  // 🔘 عناصر التنقل العادية
  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🟣 الأيقونة
            Icon(
              item.icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
              size: isSelected ? 24 : 22,
            ),
            const SizedBox(height: 2),
            // 📝 النص
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
            ),
            // 🔵 المؤشر السفلي
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

  // 💬 زر الدردشة المميز
  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 🔵 زر دائري مع تدرج
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 2),
            // 📝 النص
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }

  // 🎯 معالجة الضغط
  void _handleTap(NavItem item) {
    if (item.isProtected && !isLoggedIn) {
      onAuthRequired();
      return;
    }
    onTap(item.index);
  }
}

// 📦 نموذج عنصر التنقل
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
