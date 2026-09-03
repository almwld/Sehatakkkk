import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A8F83);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color secondary = Color(0xFF263238);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);

  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color darkBackground = Color(0xFF1A1A2E);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF616161);

  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
