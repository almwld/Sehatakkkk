import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ThemeManager {
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
    // ✅ استخدام Google Fonts
    textTheme: TextTheme(
      // ✅ العناوين الكبيرة - Bold
      displayLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: Colors.black87,
      ),
      displayMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        color: Colors.black87,
      ),
      displaySmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: Colors.black87,
      ),
      // ✅ العناوين المتوسطة - Bold
      headlineLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: Colors.black87,
      ),
      headlineMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.black87,
      ),
      headlineSmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.black87,
      ),
      // ✅ العناوين الصغيرة - SemiBold
      titleLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.black87,
      ),
      titleMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
      ),
      titleSmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Colors.grey[700],
      ),
      // ✅ النصوص العادية - Regular
      bodyLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.black87,
      ),
      bodySmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.grey[600],
      ),
      // ✅ النصوص الصغيرة - Regular
      labelLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.grey[700],
      ),
      labelMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.grey[600],
      ),
      labelSmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 10,
        color: Colors.grey[500],
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.notoSansArabic(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: GoogleFonts.notoSansArabic(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.grey[600],
      ),
      hintStyle: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.grey[400],
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
    // ✅ استخدام Google Fonts للوضع المظلم
    textTheme: TextTheme(
      displayLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Colors.white70,
      ),
      bodyLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.white70,
      ),
      bodySmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.white60,
      ),
      labelLarge: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.white70,
      ),
      labelMedium: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: Colors.white60,
      ),
      labelSmall: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 10,
        color: Colors.white60,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.notoSansArabic(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: GoogleFonts.notoSansArabic(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.white70,
      ),
      hintStyle: GoogleFonts.notoSansArabic(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Colors.white60,
      ),
    ),
  );
}
