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
    NavItem(index: 0, icon: Icons.home_rounded, iconPath: 'assets/images/navigation/home.webp', label: 'الرئيسية'),
    NavItem(index: 1, icon: Icons.person_search_rounded, iconPath: 'assets/images/services/doctors.webp', label: 'الأطباء'),
    NavItem(index: 2, icon: Icons.local_pharmacy_rounded, iconPath: 'assets/images/services/pharmacy.webp', label: 'الصيدلية'),
    NavItem(index: 3, icon: Icons.chat_rounded, iconPath: 'assets/images/navigation/chat.webp', label: 'الدردشة', isProtected: true, isSpecial: true),
    NavItem(index: 4, icon: Icons.science_rounded, iconPath: 'assets/images/services/labs.webp', label: 'مختبرات', isProtected: true),
    NavItem(index: 5, icon: Icons.folder_rounded, iconPath: 'assets/images/navigation/health.webp', label: 'صحتي', isProtected: true),
    NavItem(index: 6, icon: Icons.grid_view_rounded, iconPath: 'assets/images/navigation/more.webp', label: 'المزيد'),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: ClipRect(
            clipBehavior: Clip.none,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _navItems.map((item) => item.isSpecial ? _buildSpecialChatButton(item, isDark) : _buildNavItem(item, isDark)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final color = isSelected ? AppColors.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500);
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(item),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Image.asset(item.iconPath, width: 22, height: 22, fit: BoxFit.contain, color: color,
                  errorBuilder: (context, error, stackTrace) => Icon(item.icon, color: color, size: 22)),
              ),
              const SizedBox(height: 3),
              Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: color)),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 12 : 0,
                height: 2,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialChatButton(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    // المقاس الحالي كان 54.08، وتمت زيادته 15% إلى 62.192.
    const chatButtonSize = 62.192;
    const chatIconSize = 31.096;

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
                      Container(
                        width: chatButtonSize,
                        height: chatButtonSize,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4))],
                          border: Border.all(color: isDark ? const Color(0xFF0B1121) : Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: SizedBox(
                            width: chatIconSize,
                            height: chatIconSize,
                            child: Image.asset(item.iconPath, width: chatIconSize, height: chatIconSize, fit: BoxFit.contain, color: Colors.white,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.chat_rounded, color: Colors.white, size: chatIconSize)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 9, color: isSelected ? AppColors.primary : inactiveColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
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

  void _handleTap(NavItem item) {
    if (item.isProtected && !isLoggedIn) {
      onAuthRequired();
      return;
    }
    onTap(item.index);
    if (scrollManager != null) {
      try { scrollManager.show(); } catch (_) {}
    }
  }
}

class NavItem {
  final int index;
  final IconData icon;
  final String iconPath;
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
