// ============================================================
// 🎨 ThemeManager - إدارة الثيمات والخطوط
// ============================================================
// ✅ ElMessiri للعناوين والنصوص الرئيسية
// ✅ NotoNaskhArabic للتفاصيل الصغيرة
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ThemeManager {
  // ============================================================
  // 🎨 ثوابت الألوان
  // ============================================================

  // ✅ الوضع النهاري
  static const Color _lightTextColor = Color(0xFF1A1A1A);
  static const Color _lightTextColorMedium = Color(0xFF333333);
  static const Color _lightTextColorLight = Color(0xFF555555);
  static const Color _lightLabelColor = Color(0xFF666666);
  static const Color _lightLabelColorLight = Color(0xFF777777);
  static const Color _lightLabelColorLighter = Color(0xFF888888);

  // ✅ الوضع الليلي
  static const Color _darkTextColor = Color(0xFFF0F0F0);
  static const Color _darkTextColorMedium = Color(0xFFD0D0D0);
  static const Color _darkTextColorLight = Color(0xFFB0B0B0);
  static const Color _darkLabelColor = Color(0xFFAAAAAA);
  static const Color _darkLabelColorLight = Color(0xFF999999);
  static const Color _darkLabelColorLighter = Color(0xFF888888);

  // ============================================================
  // ☀️ الوضع النهاري
  // ============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'ElMessiri', // ✅ الخط الرئيسي ElMessiri

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: Color(0xFFF8FAFC),
        background: Color(0xFFF8FAFC),
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        onBackground: Color(0xFF1A1A1A),
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      textTheme: const TextTheme(
        // ============================================================
        // 🎨 العناوين الكبيرة - ElMessiri
        // ============================================================
        displayLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),

        // ============================================================
        // 🎨 العناوين الرئيسية - ElMessiri
        // ============================================================
        headlineLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),

        // ============================================================
        // 🎨 عناوين الأقسام - ElMessiri
        // ============================================================
        titleLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),

        // ============================================================
        // 📝 النصوص الرئيسية - ElMessiri (داكن للنهاري)
        // ============================================================
        bodyLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: _lightTextColor,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _lightTextColorMedium,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _lightTextColorLight,
          height: 1.6,
        ),

        // ============================================================
        // 📌 التفاصيل الصغيرة - NotoNaskhArabic
        // ============================================================
        labelLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _lightLabelColor,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _lightLabelColorLight,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _lightLabelColorLighter,
          height: 1.4,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          elevation: 2,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 15,
          color: Colors.grey,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // 🌙 الوضع الليلي
  // ============================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF0B1121),
      fontFamily: 'ElMessiri', // ✅ الخط الرئيسي ElMessiri

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: Color(0xFF1A2540),
        background: Color(0xFF0B1121),
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFF0F0F0),
        onBackground: Color(0xFFF0F0F0),
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      textTheme: const TextTheme(
        // ============================================================
        // 🎨 العناوين الكبيرة - ElMessiri
        // ============================================================
        displayLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),

        // ============================================================
        // 🎨 العناوين الرئيسية - ElMessiri
        // ============================================================
        headlineLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),

        // ============================================================
        // 🎨 عناوين الأقسام - ElMessiri
        // ============================================================
        titleLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),

        // ============================================================
        // 📝 النصوص الرئيسية - ElMessiri (فاتح للليلي)
        // ============================================================
        bodyLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: _darkTextColor,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _darkTextColorMedium,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _darkTextColorLight,
          height: 1.6,
        ),

        // ============================================================
        // 📌 التفاصيل الصغيرة - NotoNaskhArabic
        // ============================================================
        labelLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _darkLabelColor,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _darkLabelColorLight,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _darkLabelColorLighter,
          height: 1.4,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          elevation: 2,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 15,
          color: Colors.grey,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================

  static TextStyle getBodyTextStyle(BuildContext context, {bool isDark = false}) {
    return isDark
        ? const TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 16,
            color: _darkTextColorMedium,
            height: 1.6,
          )
        : const TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 16,
            color: _lightTextColorMedium,
            height: 1.6,
          );
  }

  static TextStyle getSmallTextStyle(BuildContext context, {bool isDark = false}) {
    return isDark
        ? const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 12,
            color: _darkLabelColorLight,
            height: 1.4,
          )
        : const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 12,
            color: _lightLabelColorLight,
            height: 1.4,
          );
  }

  static Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC);
  }

  static Color getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _darkTextColor : _lightTextColor;
  }

  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A2540) : Colors.white;
  }

  static Color getDividerColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
  }
}
