import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final ScrollController? scrollController;
  final dynamic scrollManager;
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

  // ✅ ارتفاع الشريط 60
  static const double _barHeight = 60.0;

  // ✅ الأيقونات من Material Icons (نفس السابقة)
  static const List<NavItem> _navItems = [
    NavItem(
      index: 0,
      icon: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    NavItem(
      index: 1,
      icon: Icons.person_search_rounded,
      label: 'الأطباء',
    ),
    NavItem(
      index: 2,
      icon: Icons.local_pharmacy_rounded,
      label: 'الصيدلية',
    ),
    NavItem(
      index: 3,
      icon: Icons.chat_rounded,
      label: 'الدردشة',
      isProtected: true,
      isSpecial: true,
    ),
    NavItem(
      index: 4,
      icon: Icons.science_rounded,
      label: 'مختبرات',
      isProtected: true,
    ),
    NavItem(
      index: 5,
      icon: Icons.folder_rounded,
      label: 'صحتي',
      isProtected: true,
    ),
    NavItem(
      index: 6,
      icon: Icons.grid_view_rounded,
      label: 'المزيد',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: _barHeight + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 4),
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _navItems.map((item) {
              if (item.isSpecial) {
                return _buildSpecialChatButton(item, isDark);
              }
              return _buildNavItem(item, isDark);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 🔘 الأيقونات العادية
  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

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
              color: isSelected ? AppColors.primary : inactiveColor,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💬 زر الدردشة المميز - يخرج من الشريط باستخدام Stack + Positioned
  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ✅ الزر يخرج للأعلى باستخدام Positioned
            Positioned(
              top: -22,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.5),
                              AppColors.primaryDark.withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(
                          isSelected ? 0.4 : 0.15,
                        ),
                        blurRadius: isSelected ? 20 : 12,
                        offset: const Offset(0, 4),
                        spreadRadius: isSelected ? 2 : 0,
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
            ),
            // ✅ النص في الأسفل
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : inactiveColor,
                  ),
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
    if (scrollManager != null) {
      try {
        scrollManager.show();
      } catch (_) {}
    }
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
