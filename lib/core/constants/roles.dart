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
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'مستخدم';
      case UserRole.doctor:
        return 'طبيب';
      case UserRole.nurse:
        return 'ممرض';
      case UserRole.midwife:
        return 'قابلة وتوليد';
      case UserRole.physiotherapist:
        return 'علاج فيزيائي';
      case UserRole.pharmacist:
        return 'صيدلي';
      case UserRole.lab:
        return 'مختبر';
      case UserRole.paramedic:
        return 'مسعف';
      case UserRole.delivery:
        return 'موصل طلبات';
      case UserRole.service:
        return 'خدمي';
      case UserRole.veterinarian:
        return 'بيطري';
      case UserRole.admin:
        return 'مشرف';
    }
  }

  String get id {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.doctor:
        return 'doctor';
      case UserRole.nurse:
        return 'nurse';
      case UserRole.midwife:
        return 'midwife';
      case UserRole.physiotherapist:
        return 'physiotherapist';
      case UserRole.pharmacist:
        return 'pharmacist';
      case UserRole.lab:
        return 'lab';
      case UserRole.paramedic:
        return 'paramedic';
      case UserRole.delivery:
        return 'delivery';
      case UserRole.service:
        return 'service';
      case UserRole.veterinarian:
        return 'veterinarian';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromId(String id) {
    switch (id) {
      case 'user':
        return UserRole.user;
      case 'doctor':
        return UserRole.doctor;
      case 'nurse':
        return UserRole.nurse;
      case 'midwife':
        return UserRole.midwife;
      case 'physiotherapist':
        return UserRole.physiotherapist;
      case 'pharmacist':
        return UserRole.pharmacist;
      case 'lab':
        return UserRole.lab;
      case 'paramedic':
        return UserRole.paramedic;
      case 'delivery':
        return UserRole.delivery;
      case 'service':
        return UserRole.service;
      case 'veterinarian':
        return UserRole.veterinarian;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}
