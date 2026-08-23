import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  // ============================================================
  // ✅ العناوين البارزة - Bold (Noto Sans Arabic Bold)
  // ============================================================
  
  static TextStyle get headline1 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1.2,
  );
  
  static TextStyle get headline2 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.2,
  );
  
  static TextStyle get headline3 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 1.2,
  );
  
  static TextStyle get headline4 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.2,
  );
  
  static TextStyle get headline5 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 1.2,
  );
  
  static TextStyle get headline6 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.2,
  );

  // ============================================================
  // ✅ العناوين الفرعية - SemiBold
  // ============================================================
  
  static TextStyle get subtitle1 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.3,
  );
  
  static TextStyle get subtitle2 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
  );
  
  static TextStyle get subtitle3 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.3,
  );

  // ============================================================
  // ✅ النصوص العادية - Regular (Noto Sans Arabic Regular)
  // ============================================================
  
  static TextStyle get body1 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );
  
  static TextStyle get body2 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
  );
  
  static TextStyle get body3 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
  );
  
  static TextStyle get body4 => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w400,
    fontSize: 10,
    height: 1.5,
  );

  // ============================================================
  // ✅ نصوص خاصة
  // ============================================================
  
  static TextStyle get button => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.2,
  );
  
  static TextStyle get appBar => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 1.2,
  );
  
  static TextStyle get caption => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.4,
    color: Colors.grey,
  );
  
  static TextStyle get overline => GoogleFonts.notoSansArabic(
    fontWeight: FontWeight.w400,
    fontSize: 10,
    height: 1.2,
    letterSpacing: 1.5,
  );
}
