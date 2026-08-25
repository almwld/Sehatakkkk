import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ThemeManager {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      fontFamily: 'ElMessiri', // ✅ الخط الافتراضي (ElMessiri)
      
      // ✅ تخصيص AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'ElMessiri', // ✅ عنوان الشاشة (ElMessiri)
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      
      // ✅ تخصيص النصوص
      textTheme: const TextTheme(
        // ✅ العناوين الرئيسية (NotoNaskhArabic)
        displayLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displaySmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        
        // ✅ عناوين الأقسام (NotoNaskhArabic)
        headlineLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        
        // ✅ عناوين البطاقات (NotoNaskhArabic)
        titleLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleSmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        
        // ✅ النصوص العادية (ElMessiri)
        bodyLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        
        // ✅ التفاصيل الصغيرة (ElMessiri)
        labelLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        labelMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        labelSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      
      // ✅ تخصيص الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'NotoNaskhArabic', // ✅ خط الأزرار (NotoNaskhArabic)
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // ✅ تخصيص الحقول النصية
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
          fontFamily: 'ElMessiri', // ✅ خط التلميحات (ElMessiri)
          fontSize: 14,
          color: Colors.grey,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'NotoNaskhArabic', // ✅ خط التسميات (NotoNaskhArabic)
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
      fontFamily: 'ElMessiri', // ✅ الخط الافتراضي (ElMessiri)
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B1121),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'ElMessiri', // ✅ عنوان الشاشة (ElMessiri)
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      textTheme: const TextTheme(
        // ✅ العناوين الرئيسية (NotoNaskhArabic)
        displayLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontFamily: 'ElMessiri',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'NotoNaskhArabic', // ✅ خط الأزرار (NotoNaskhArabic)
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
          fontFamily: 'ElMessiri', // ✅ خط التلميحات (ElMessiri)
          fontSize: 14,
          color: Colors.grey,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'NotoNaskhArabic', // ✅ خط التسميات (NotoNaskhArabic)
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
