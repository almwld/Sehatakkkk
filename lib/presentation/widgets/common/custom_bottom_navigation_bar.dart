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

  static const _items = [
    NavItem(index: 0, iconPath: AppImages.uiAllServices, label: 'الرئيسية'),
    NavItem(index: 1, iconPath: AppImages.doctorMale, label: 'الأطباء'),
    NavItem(index: 2, iconPath: AppImages.servicesPharmacy, label: 'الصيدلية'),
    NavItem(index: 3, iconPath: AppImages.chatBubble, label: 'الدردشة', isSpecial: true, isProtected: true),
    NavItem(index: 4, iconPath: AppImages.servicesLaboratory, label: 'مختبرات', isProtected: true),
    NavItem(index: 5, iconPath: AppImages.servicesMedicalRecords, label: 'صحتي', isProtected: true),
    NavItem(index: 6, iconPath: AppImages.uiAllServices, label: 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      height: 68 + bottom,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _items
              .map((i) => i.isSpecial ? _special(i, dark) : _item(i, dark))
              .toList(),
        ),
      ),
    );
  }

  Widget _image(String path, double size, Color color) => Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: color,
        errorBuilder: (_, __, ___) => SizedBox(width: size, height: size),
      );

  Widget _item(NavItem item, bool dark) {
    final selected = currentIndex == item.index;
    final color = selected
        ? AppColors.primary
        : (dark ? Colors.grey.shade500 : Colors.grey.shade400);
    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image(item.iconPath, selected ? 24 : 22, color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppColors.primary
                    : (dark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: selected ? 20 : 0,
              margin: const EdgeInsets.only(top: 2),
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

  Widget _special(NavItem item, bool dark) {
    final selected = currentIndex == item.index;
    return GestureDetector(
      onTap: () => _handleTap(item),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark ? const Color(0xFF1E293B) : Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _image(item.iconPath, 28, Colors.white),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppColors.primary
                    : (dark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 4),
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

  const NavItem({
    required this.index,
    required this.iconPath,
    required this.label,
    this.isProtected = false,
    this.isSpecial = false,
  });
}
