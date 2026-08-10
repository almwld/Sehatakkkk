import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

class HomeHeader extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.onProfileTap,
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
                isLoggedIn && userName.isNotEmpty ? userName[0].toUpperCase() : 'م',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
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
                  isLoggedIn ? 'كيف تشعر اليوم؟' : 'سجل دخولك للمتابعة',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _buildIcon('assets/images/services/notifications.png', isDark),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _buildIcon('assets/images/services/wallet.png', isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String path, bool isDark) {
    return Image.asset(
      path,
      width: 24,
      height: 24,
      color: isDark ? Colors.white : Colors.black87,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: isDark ? Colors.white : Colors.black87, size: 24);
      },
    );
  }
}
