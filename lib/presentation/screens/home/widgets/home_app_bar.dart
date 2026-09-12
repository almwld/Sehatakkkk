import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/widgets/common/svg_icon.dart';

class HomeAppBar extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final VoidCallback onProfileTap;
  final int notificationCount, cartItemCount;

  const HomeAppBar({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.onProfileTap,
    this.notificationCount = 0,
    this.cartItemCount = 0,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.primary,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: isLoggedIn
                        ? const NetworkImage(ImageKit.profileAvatar)
                        : null,
                    child: !isLoggedIn ? const Icon(Icons.person) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? 'مرحباً، $userName 👋' : 'منصة صحتك',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'كيف تشعر اليوم؟',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                _icon(
                  context,
                  ImageKit.notificationIcon,
                  notificationCount,
                  notificationCount > 0
                      ? 'لديك $notificationCount إشعار جديد'
                      : 'لا توجد إشعارات جديدة',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                _icon(
                  context,
                  ImageKit.cartIcon,
                  cartItemCount,
                  cartItemCount > 0
                      ? 'لديك $cartItemCount عنصر في السلة'
                      : 'السلة فارغة',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _icon(
    BuildContext context,
    String path,
    int count,
    String statusText,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: statusText,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 2),
      waitDuration: Duration.zero,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'Noto Sans Arabic',
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: onTap,
            tooltip: null,
            icon: SvgIcon(
              assetPath: path,
              size: 24,
              color: Colors.white,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
