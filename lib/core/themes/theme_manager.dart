import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ThemeManager {
  // ✅ ثوابت الألوان للوضع النهاري
  static const Color _lightTextColor = Color(0xFF333333);
  static const Color _lightTextColorMedium = Color(0xFF444444);
  static const Color _lightTextColorLight = Color(0xFF555555);
  static const Color _lightLabelColor = Color(0xFF666666);
  static const Color _lightLabelColorLight = Color(0xFF777777);
  static const Color _lightLabelColorLighter = Color(0xFF888888);

  // ✅ ثوابت الألوان للوضع الليلي
  static const Color _darkTextColor = Color(0xFFE0E0E0);
  static const Color _darkTextColorMedium = Color(0xFFCCCCCC);
  static const Color _darkTextColorLight = Color(0xFFBBBBBB);
  static const Color _darkLabelColor = Color(0xFFAAAAAA);
  static const Color _darkLabelColorLight = Color(0xFF999999);
  static const Color _darkLabelColorLighter = Color(0xFF888888);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'NotoNaskhArabic',
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: Color(0xFFF8FAFC),
        background: Color(0xFFF8FAFC),
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF333333),
        onBackground: Color(0xFF333333),
        onError: Colors.white,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      textTheme: const TextTheme(
        // العناوين - أبيض
        displayLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        
        // النصوص العادية - داكن (للوضع النهاري)
        bodyLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: _lightTextColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: _lightTextColorMedium,
        ),
        bodySmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: _lightTextColorLight,
        ),
        
        // التفاصيل الصغيرة
        labelLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _lightLabelColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _lightLabelColorLight,
        ),
        labelSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _lightLabelColorLighter,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          color: Colors.grey,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF0B1121),
      fontFamily: 'NotoNaskhArabic',
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: Color(0xFF1A2540),
        background: Color(0xFF0B1121),
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE0E0E0),
        onBackground: Color(0xFFE0E0E0),
        onError: Colors.white,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      textTheme: const TextTheme(
        // العناوين - أبيض
        displayLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        
        // النصوص العادية - فاتحة (للوضع الليلي)
        bodyLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: _darkTextColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: _darkTextColorMedium,
        ),
        bodySmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: _darkTextColorLight,
        ),
        
        // التفاصيل الصغيرة
        labelLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _darkLabelColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _darkLabelColorLight,
        ),
        labelSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _darkLabelColorLighter,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'ElMessiri',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          color: Colors.grey,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ✅ دوال مساعدة
  static TextStyle getBodyTextStyle(BuildContext context, {bool isDark = false}) {
    return isDark
        ? const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 14,
            color: _darkTextColorMedium,
          )
        : const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 14,
            color: _lightTextColorMedium,
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
}
