import 'package:flutter/material.dart';

class Roles {
  static const String user = 'user';
  static const String doctor = 'doctor';
  static const String nurse = 'nurse';
  static const String midwife = 'midwife';
  static const String physiotherapist = 'physiotherapist';
  static const String pharmacist = 'pharmacist';
  static const String lab = 'lab';
  static const String paramedic = 'paramedic';
  static const String delivery = 'delivery';
  static const String service = 'service';
  static const String veterinarian = 'veterinarian';
  static const String admin = 'admin';

  static List<String> get all => [
    user, doctor, nurse, midwife, physiotherapist,
    pharmacist, lab, paramedic, delivery, service,
    veterinarian, admin,
  ];

  static List<Map<String, dynamic>> get roles => [
    {'id': user, 'name': 'مستخدم', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFF0D5257},
    {'id': doctor, 'name': 'طبيب', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFF2196F3},
    {'id': nurse, 'name': 'ممرض', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFF00BCD4},
    {'id': midwife, 'name': 'قابلة', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFFE91E63},
    {'id': physiotherapist, 'name': 'علاج فيزيائي', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFFFF9800},
    {'id': pharmacist, 'name': 'صيدلي', 'icon': 'assets/icons/core/pharmacy.svg', 'color': 0xFF4CAF50},
    {'id': lab, 'name': 'مختبر', 'icon': 'assets/icons/core/blood_test.svg', 'color': 0xFF9C27B0},
    {'id': paramedic, 'name': 'مسعف', 'icon': 'assets/icons/core/emergency.svg', 'color': 0xFFF44336},
    {'id': delivery, 'name': 'موصل', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFFFF5722},
    {'id': service, 'name': 'خدمي', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFF607D8B},
    {'id': veterinarian, 'name': 'بيطري', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFF795548},
    {'id': admin, 'name': 'مشرف', 'icon': 'assets/icons/core/doctor.svg', 'color': 0xFFFF5722},
  ];

  static String getRoleName(String id) {
    final role = roles.firstWhere((r) => r['id'] == id, orElse: () => {'name': 'مستخدم'});
    return role['name'] as String;
  }

  static String getRoleIcon(String id) {
    final role = roles.firstWhere((r) => r['id'] == id, orElse: () => {'icon': 'assets/icons/core/doctor.svg'});
    return role['icon'] as String;
  }
}
