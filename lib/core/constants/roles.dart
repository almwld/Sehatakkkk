import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_icons.dart';

enum UserRole {
  user,
  doctor,
  nurse,
  midwife,
  physiotherapist,
  pharmacist,
  lab,
  paramedic,
  delivery,
  service,
  veterinarian,
  hospital,
  admin,
  superAdmin,
}

class AppRoles {
  static final List<Map<String, dynamic>> all = [
    {'id': 'user', 'name': 'مستخدم', 'icon': AppIcons.home, 'color': 0xFF0D5257},
    {'id': 'doctor', 'name': 'طبيب', 'icon': AppIcons.doctor, 'color': 0xFF2196F3},
    {'id': 'nurse', 'name': 'ممرض', 'icon': AppIcons.serviceMedical, 'color': 0xFF00BCD4},
    {'id': 'midwife', 'name': 'قابلة', 'icon': AppIcons.specialtyPediatrics, 'color': 0xFFE91E63},
    {'id': 'physiotherapist', 'name': 'علاج فيزيائي', 'icon': AppIcons.specialtyBone, 'color': 0xFFFF9800},
    {'id': 'pharmacist', 'name': 'صيدلي', 'icon': AppIcons.pharmacy, 'color': 0xFF4CAF50},
    {'id': 'lab', 'name': 'مختبر', 'icon': AppIcons.labMicroscope, 'color': 0xFF9C27B0},
    {'id': 'paramedic', 'name': 'مسعف', 'icon': AppIcons.emergency, 'color': 0xFFF44336},
    {'id': 'delivery', 'name': 'موصل', 'icon': AppIcons.navBlood, 'color': 0xFFFF5722},
    {'id': 'service', 'name': 'خدمي', 'icon': AppIcons.serviceMedical, 'color': 0xFF607D8B},
    {'id': 'veterinarian', 'name': 'بيطري', 'icon': AppIcons.specialtyPediatrics, 'color': 0xFF795548},
    {'id': 'hospital', 'name': 'مستشفى', 'icon': AppIcons.moreMenu, 'color': 0xFF1565C0},
    {'id': 'admin', 'name': 'مشرف', 'icon': AppIcons.moreMenu, 'color': 0xFFFF5722},
    {'id': 'superAdmin', 'name': 'مدير المنصة', 'icon': AppIcons.moreMenu, 'color': 0xFF263238},
  ];

  static final List<String> verifiedRoles = [
    'doctor', 'nurse', 'midwife', 'physiotherapist',
    'pharmacist', 'lab', 'paramedic', 'veterinarian',
  ];

  static bool needsVerification(String roleId) => verifiedRoles.contains(roleId);

  static String getRoleName(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'name': id});
    return role['name'] as String;
  }

  static String getRoleIcon(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'icon': AppIcons.home});
    return role['icon'] as String;
  }

  static Color getRoleColor(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'color': 0xFF0D5257});
    return Color(role['color'] as int);
  }

  static UserRole parseRole(String value) {
    switch (value) {
      case 'doctor': return UserRole.doctor;
      case 'nurse': return UserRole.nurse;
      case 'midwife': return UserRole.midwife;
      case 'physiotherapist': return UserRole.physiotherapist;
      case 'pharmacist': return UserRole.pharmacist;
      case 'lab': return UserRole.lab;
      case 'paramedic': return UserRole.paramedic;
      case 'delivery': return UserRole.delivery;
      case 'service': return UserRole.service;
      case 'veterinarian': return UserRole.veterinarian;
      case 'hospital': return UserRole.hospital;
      case 'admin': return UserRole.admin;
      case 'superAdmin': return UserRole.superAdmin;
      default: return UserRole.user;
    }
  }
}
