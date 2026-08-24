import 'package:flutter/material.dart';

class ResponsiveHelper {
  // ✅ أنواع الشاشات
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  // ✅ الحصول على حجم الشاشة
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // ✅ حجم النص المتكيف
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double tablet = 18,
    double desktop = 20,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // ✅ حجم الأيقونة المتكيف
  static double responsiveIconSize(
    BuildContext context, {
    required double mobile,
    double tablet = 28,
    double desktop = 32,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // ✅ التباعد المتكيف
  static double responsivePadding(
    BuildContext context, {
    required double mobile,
    double tablet = 20,
    double desktop = 24,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // ✅ عدد الأعمدة في الشبكة
  static int gridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  // ✅ نسبة العرض المتكيفة
  static double widthPercentage(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  // ✅ الـ SafeArea المحسن
  static Widget safeArea({
    required Widget child,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  // ✅ حاوية متكيفة
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    BorderRadius? borderRadius,
    BoxShadow? boxShadow,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = width ?? screenWidth;
    
    return Container(
      width: containerWidth,
      height: height,
      padding: padding ?? EdgeInsets.all(responsivePadding(context, mobile: 12)),
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: responsivePadding(context, mobile: 8),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: boxShadow != null ? [boxShadow] : null,
      ),
      child: child,
    );
  }
}
