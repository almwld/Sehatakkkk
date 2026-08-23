import 'package:flutter/material.dart';

enum UserRole {
  user,
  doctor,
  pharmacist,
  lab,
  veterinarian,
  admin,
  superAdmin,
}

class AppRoles {
  static final List<Map<String, dynamic>> all = [
    {'id': 'user', 'name': 'مستخدم', 'icon': Icons.person_outline, 'color': 0xFF0D5257},
    {'id': 'doctor', 'name': 'طبيب', 'icon': Icons.local_hospital_outlined, 'color': 0xFF2196F3},
    {'id': 'nurse', 'name': 'ممرض', 'icon': Icons.medical_services_outlined, 'color': 0xFF00BCD4},
    {'id': 'midwife', 'name': 'قابلة', 'icon': Icons.pregnant_woman, 'color': 0xFFE91E63},
    {'id': 'physiotherapist', 'name': 'علاج فيزيائي', 'icon': Icons.fitness_center, 'color': 0xFFFF9800},
    {'id': 'pharmacist', 'name': 'صيدلي', 'icon': Icons.local_pharmacy_outlined, 'color': 0xFF4CAF50},
    {'id': 'lab', 'name': 'مختبر', 'icon': Icons.science_outlined, 'color': 0xFF9C27B0},
    {'id': 'paramedic', 'name': 'مسعف', 'icon': Icons.emergency, 'color': 0xFFF44336},
    {'id': 'delivery', 'name': 'موصل', 'icon': Icons.delivery_dining, 'color': 0xFFFF5722},
    {'id': 'service', 'name': 'خدمي', 'icon': Icons.handyman, 'color': 0xFF607D8B},
    {'id': 'veterinarian', 'name': 'بيطري', 'icon': Icons.pets, 'color': 0xFF795548},
    {'id': 'admin', 'name': 'مشرف', 'icon': Icons.admin_panel_settings, 'color': 0xFFFF5722},
  ];

  static final List<String> verifiedRoles = [
    'doctor', 'nurse', 'midwife', 'physiotherapist',
    'pharmacist', 'lab', 'paramedic', 'veterinarian'
  ];

  static bool needsVerification(String roleId) {
    return verifiedRoles.contains(roleId);
  }

  static String getRoleName(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'name': id});
    return role['name'] as String;
  }

  static IconData getRoleIcon(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'icon': Icons.person});
    return role['icon'] as IconData;
  }

  static Color getRoleColor(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'color': 0xFF0D5257});
    return Color(role['color'] as int);
  }

  static UserRole parseRole(String value) {
    switch (value) {
      case 'doctor': return UserRole.doctor;
      case 'pharmacist': return UserRole.pharmacist;
      case 'lab': return UserRole.lab;
      case 'veterinarian': return UserRole.veterinarian;
      case 'admin': return UserRole.admin;
      case 'superAdmin': return UserRole.superAdmin;
      default: return UserRole.user;
    }
  }
}
