import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final bool isLoggedIn;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;

  const HomeHeader({
    super.key,
    this.userName = 'مستخدم',
    this.isLoggedIn = false,
    this.onProfileTap,
    this.onNotificationTap,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                isLoggedIn ? userName[0].toUpperCase() : 'م',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLoggedIn ? 'مرحباً، $userName 👋' : 'منصة صحتك',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'كيف تشعر اليوم؟',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: onNotificationTap,
          ),
          IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: onCartTap,
          ),
        ],
      ),
    );
  }
}
