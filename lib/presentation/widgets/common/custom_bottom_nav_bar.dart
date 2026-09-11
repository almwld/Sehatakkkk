// ============================================================
// 🧭 شريط التنقل السفلي - مع الأيقونات المحلية
// ============================================================

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

  static const double _barHeight = 65.0;

  // ✅ عناصر شريط التنقل مع الأيقونات المحلية
  static const List<NavItem> _navItems = [
    NavItem(
      index: 0,
      icon: Icons.home_rounded,
      iconPath: 'assets/images/navigation/home.png',
      label: 'الرئيسية',
    ),
    NavItem(
      index: 1,
      icon: Icons.person_search_rounded,
      iconPath: 'assets/images/services/doctors.png',
      label: 'الأطباء',
    ),
    NavItem(
      index: 2,
      icon: Icons.local_pharmacy_rounded,
      iconPath: 'assets/images/services/pharmacy.png',
      label: 'الصيدلية',
    ),
    NavItem(
      index: 3,
      icon: Icons.chat_rounded,
      iconPath: 'assets/images/navigation/chat.png',
      label: 'الدردشة',
      isProtected: true,
      isSpecial: true,
    ),
    NavItem(
      index: 4,
      icon: Icons.science_rounded,
      iconPath: 'assets/images/services/labs.png',
      label: 'مختبرات',
      isProtected: true,
    ),
    NavItem(
      index: 5,
      icon: Icons.folder_rounded,
      iconPath: 'assets/images/navigation/health.png',
      label: 'صحتي',
      isProtected: true,
    ),
    NavItem(
      index: 6,
      icon: Icons.grid_view_rounded,
      iconPath: 'assets/images/navigation/more.png',
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
      clipBehavior: Clip.none,
      child: Container(
        height: _barHeight + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 4),
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: ClipRect(
            clipBehavior: Clip.none,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _navItems.map((item) {
                if (item.isSpecial) return _buildSpecialChatButton(item, isDark);
                return _buildNavItem(item, isDark);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 بناء عنصر عادي من شريط التنقل
  // ============================================================

  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade500);

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(item),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ الأيقونة المحلية مع fallback
              SizedBox(
                width: 22,
                height: 22,
                child: Image.asset(
                  item.iconPath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  color: color,
                  errorBuilder: (context, error, stackTrace) {
                    // ✅ fallback للأيقونة الافتراضية
                    return Icon(
                      item.icon,
                      color: color,
                      size: 22,
                    );
                  },
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 12 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 💬 بناء زر الدردشة المميز (الكبير)
  // ============================================================

  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(item),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 65,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              OverflowBox(
                minWidth: 0,
                maxWidth: double.infinity,
                minHeight: 0,
                maxHeight: 120,
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ الزر الدائري المميز
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
                              color: AppColors.primary.withOpacity(0.45),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? const Color(0xFF0B1121) : Colors.white,
                            width: 3,
                          ),
                        ),
                        // ✅ الأيقونة المحلية في الزر الدائري
                        child: ClipOval(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: Image.asset(
                              item.iconPath,
                              width: 26,
                              height: 26,
                              fit: BoxFit.contain,
                              color: Colors.white,
                              errorBuilder: (context, error, stackTrace) {
                                // ✅ fallback
                                return const Icon(
                                  Icons.chat_rounded,
                                  color: Colors.white,
                                  size: 26,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? AppColors.primary : inactiveColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎯 معالجة النقر
  // ============================================================

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

// ============================================================
// 📦 نموذج عنصر التنقل
// ============================================================

class NavItem {
  final int index;
  final IconData icon;
  final String iconPath;  // ✅ مسار الأيقونة المحلية
  final String label;
  final bool isProtected;
  final bool isSpecial;

  const NavItem({
    required this.index,
    required this.icon,
    required this.iconPath,
    required this.label,
    this.isProtected = false,
    this.isSpecial = false,
  });
}
