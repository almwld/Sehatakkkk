// ============================================================
// 📱 CustomBottomNavigationBar - شريط التنقل السفلي المخصص
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_images.dart';
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
    NavItem(index: 0, iconPath: AppImages.uiAllServices, label: 'الرئيسية'),
    NavItem(index: 1, iconPath: AppImages.doctorMale, label: 'الأطباء'),
    NavItem(index: 2, iconPath: AppImages.servicesPharmacy, label: 'الصيدلية'),
    NavItem(index: 3, iconPath: AppImages.chatBubble, label: 'الدردشة', isSpecial: true),
    NavItem(index: 4, iconPath: AppImages.servicesLaboratory, label: 'مختبرات'),
    NavItem(index: 5, iconPath: AppImages.servicesMedicalRecords, label: 'صحتي', isProtected: true),
    NavItem(index: 6, iconPath: AppImages.uiAllServices, label: 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 72,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _navItems.map((item) => item.isSpecial ? _buildSpecialChatButton(item, isDark) : _buildNavItem(item, isDark)).toList(growable: false),
      ),
    );
  }

  Widget _image(String path, {double size = 24, Color? color}) => Image.asset(
    path,
    width: size,
    height: size,
    fit: BoxFit.contain,
    color: color,
    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
  );

  Widget _buildNavItem(NavItem item, bool isDark) {
    final isSelected = currentIndex == item.index;
    final iconColor = isSelected ? AppColors.primary : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);
    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image(item.iconPath, size: isSelected ? 24 : 22, color: iconColor),
            const SizedBox(height: 2),
            Text(item.label, style: TextStyle(fontSize: 9, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500)), maxLines: 1, overflow: TextOverflow.clip),
            if (isSelected)
              Container(width: 16, height: 3, margin: const EdgeInsets.only(top: 2), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

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
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 3),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.32), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 1)],
              ),
              child: Center(child: _image(AppImages.chatBubble, size: 27, color: Colors.white)),
            ),
            const SizedBox(height: 2),
            Text(item.label, style: TextStyle(fontSize: 9, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade500)), maxLines: 1, overflow: TextOverflow.visible),
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
  final String iconPath;
  final String label;
  final bool isProtected;
  final bool isSpecial;

  const NavItem({required this.index, required this.iconPath, required this.label, this.isProtected = false, this.isSpecial = false});
}
