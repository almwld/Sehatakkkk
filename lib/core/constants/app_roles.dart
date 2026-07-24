import 'package:sehatak/core/models/user_model.dart';

class AppRoles {
  static const List<UserRole> all = [
    UserRole.patient,
    UserRole.doctor,
    UserRole.pharmacist,
    UserRole.lab,
    UserRole.hospital,
    UserRole.nurse,
    UserRole.midwife,
    UserRole.physiotherapist,
    UserRole.paramedic,
    UserRole.delivery,
    UserRole.service,
    UserRole.veterinarian,
    UserRole.admin,
  ];

  static bool needsVerification(UserRole role) {
    return role == UserRole.doctor || 
           role == UserRole.pharmacist || 
           role == UserRole.lab || 
           role == UserRole.hospital;
  }

  static String getRoleName(UserRole role) {
    switch (role) {
      case UserRole.patient: return 'مريض';
      case UserRole.doctor: return 'طبيب';
      case UserRole.pharmacist: return 'صيدلي';
      case UserRole.lab: return 'مختبر';
      case UserRole.hospital: return 'مستشفى';
      case UserRole.nurse: return 'ممرض';
      case UserRole.midwife: return 'قابلة';
      case UserRole.physiotherapist: return 'معالج فيزيائي';
      case UserRole.paramedic: return 'مسعف';
      case UserRole.delivery: return 'موصل طلبات';
      case UserRole.service: return 'خدمي';
      case UserRole.veterinarian: return 'بيطري';
      case UserRole.admin: return 'مشرف';
    }
  }

  static UserRole getRoleFromString(String role) {
    switch (role) {
      case 'doctor': return UserRole.doctor;
      case 'pharmacist': return UserRole.pharmacist;
      case 'lab': return UserRole.lab;
      case 'hospital': return UserRole.hospital;
      case 'nurse': return UserRole.nurse;
      case 'midwife': return UserRole.midwife;
      case 'physiotherapist': return UserRole.physiotherapist;
      case 'paramedic': return UserRole.paramedic;
      case 'delivery': return UserRole.delivery;
      case 'service': return UserRole.service;
      case 'veterinarian': return UserRole.veterinarian;
      case 'admin': return UserRole.admin;
      default: return UserRole.patient;
    }
  }
}
