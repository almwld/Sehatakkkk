import 'package:flutter/material.dart';

enum UserRole {
  user,
  doctor,
  pharmacist,
  lab,
  veterinarian,
  admin,
}

class AppRoles {
  static const Map<UserRole, String> roleNames = {
    UserRole.user: 'مستخدم',
    UserRole.doctor: 'طبيب',
    UserRole.pharmacist: 'صيدلي',
    UserRole.lab: 'مختبر',
    UserRole.veterinarian: 'بيطري',
    UserRole.admin: 'مشرف',
  };

  static const Map<UserRole, IconData> roleIcons = {
    UserRole.user: Icons.person_outline,
    UserRole.doctor: Icons.local_hospital_outlined,
    UserRole.pharmacist: Icons.local_pharmacy_outlined,
    UserRole.lab: Icons.science_outlined,
    UserRole.veterinarian: Icons.pets_outlined,
    UserRole.admin: Icons.admin_panel_settings,
  };

  static const Map<UserRole, int> roleColors = {
    UserRole.user: 0xFF0D5257,
    UserRole.doctor: 0xFF2196F3,
    UserRole.pharmacist: 0xFF4CAF50,
    UserRole.lab: 0xFF9C27B0,
    UserRole.veterinarian: 0xFFFF9800,
    UserRole.admin: 0xFFFF5722,
  };

  static bool needsVerification(UserRole role) {
    return role == UserRole.doctor ||
           role == UserRole.pharmacist ||
           role == UserRole.lab ||
           role == UserRole.veterinarian;
  }

  static String getRoleName(UserRole role) {
    return roleNames[role] ?? 'مستخدم';
  }

  static IconData getRoleIcon(UserRole role) {
    return roleIcons[role] ?? Icons.person_outline;
  }

  static Color getRoleColor(UserRole role) {
    return Color(roleColors[role] ?? 0xFF0D5257);
  }

  // ✅ دالة للتحقق من الدور كـ String (للتوافق مع الكود القديم)
  static bool needsVerificationString(String role) {
    return role == 'doctor' ||
           role == 'pharmacist' ||
           role == 'lab' ||
           role == 'veterinarian';
  }
}
