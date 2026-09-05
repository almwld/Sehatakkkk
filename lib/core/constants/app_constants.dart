import 'package:flutter/material.dart';

class AppConstants {
  // ============================================================
  // 🎨 الألوان
  // ============================================================
  static const Color primaryColor = Color(0xFF0D5257);
  static const Color primaryDark = Color(0xFF0A3D42);
  static const Color primaryLight = Color(0xFF1A7A80);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // ============================================================
  // 📏 الأبعاد
  // ============================================================
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // ============================================================
  // 📱 الأبعاد
  // ============================================================
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double fabSize = 56.0;

  // ============================================================
  // 🔤 الخطوط
  // ============================================================
  static const String fontFamily = 'Cairo';
  static const String fontFamilyAlt = 'Tajawal';

  // ============================================================
  // 🕐 المدة الزمنية
  // ============================================================
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration snackBarDuration = Duration(seconds: 3);

  // ============================================================
  // 📋 التنسيق
  // ============================================================
  static const String currency = 'ريال';
  static const String currencySymbol = 'ر.ي';
  static const String appName = 'صحتك';
  static const String appVersion = '1.1.0';

  // ============================================================
  // 🗂️ المسارات
  // ============================================================
  static const String assetsPath = 'assets/';
  static const String iconsPath = '${assetsPath}icons/';
  static const String imagesPath = '${assetsPath}images/';
  static const String fontsPath = '${assetsPath}fonts/';
  static const String audioPath = '${assetsPath}audio/';

  // ============================================================
  // 🔢 الحدود
  // ============================================================
  static const int maxImageSize = 1024; // KB
  static const int maxFileSize = 10; // MB
  static const int maxRetryAttempts = 3;
  static const int maxSearchResults = 50;

  // ============================================================
  // 📊 التحميل
  // ============================================================
  static const int pageSize = 20;
  static const int infiniteScrollThreshold = 5;
}

// ============================================================
// ☁️ NextCloud Configuration
// ============================================================
class NextCloudConfig {
  static const String baseUrl = 'https://noa.it.tabdigital.cloud';
  static const String username = 'PlatformSehatak@gmail.com';
  static const String password = '10.10.10.1010.10.10.10';
  static const String uploadPath = 'sehatak/uploads';
}
