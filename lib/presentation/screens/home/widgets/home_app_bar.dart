import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/widgets/common/svg_icon.dart';

class HomeAppBar extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final VoidCallback onProfileTap;
  final int notificationCount;
  final int cartItemCount;

  const HomeAppBar({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.onProfileTap,
    this.notificationCount = 0,
    this.cartItemCount = 0,
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
              // ✅ الصورة الشخصية
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: isLoggedIn
                        ? Image.asset(
                            ImageKit.profileAvatar,
                            width: 56.w,
                            height: 56.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 30.sp,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 30.sp,
                          ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              
              // ✅ الترحيب
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
              
              // ✅ أزرار الإشعارات والعربة
              _buildIconButton(
                iconPath: ImageKit.notificationIcon,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
                badgeCount: notificationCount,
              ),
              
              _buildIconButton(
                iconPath: ImageKit.cartIcon,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
                badgeCount: cartItemCount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required String iconPath,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: SvgIcon(
                  assetPath: iconPath,
                  width: 22.w,
                  height: 22.h,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16.w,
                  minHeight: 16.h,
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
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

// ✅ نسخة مبسطة (بدون SVG)
class SimpleHomeAppBar extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final VoidCallback onProfileTap;

  const SimpleHomeAppBar({
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
