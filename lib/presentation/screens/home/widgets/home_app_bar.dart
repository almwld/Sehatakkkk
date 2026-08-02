import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

class HomeAppBar extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final VoidCallback onProfileTap;

  const HomeAppBar({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 30.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? 'مرحباً، $userName 👋' : 'منصة صحتك',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'كيف تشعر اليوم؟',
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
