import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ThemeManager {
  static const String _fontFamily = 'ElMessiri';
  static const String _fontFamilySecondary = 'NotoNaskhArabic';

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      background: AppColors.backgroundLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: _fontFamily,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 10,
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Color(0xFF1A2540),
      background: Color(0xFF0B1121),
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1121),
    fontFamily: _fontFamily,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: Colors.white,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Colors.white70,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 12,
        color: Colors.white60,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Colors.white70,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 12,
        color: Colors.white60,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 10,
        color: Colors.white60,
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Colors.white70,
      ),
      hintStyle: TextStyle(
        fontFamily: _fontFamilySecondary,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Colors.white60,
      ),
    ),
  );
}
