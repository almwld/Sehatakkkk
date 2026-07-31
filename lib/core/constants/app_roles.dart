import 'package:sehatak/core/models/user_model.dart';

class AppRoles {
  static const List<String> allRoles = [
    'user',
    'doctor',
    'nurse',
    'midwife',
    'physiotherapist',
    'pharmacist',
    'lab',
    'paramedic',
    'delivery',
    'service',
    'veterinarian',
    'admin',
  ];

  static const List<String> rolesNeedingVerification = [
    'doctor',
    'pharmacist',
    'lab',
  ];

  static bool needsVerification(String role) {
    return rolesNeedingVerification.contains(role);
  }

  static String getRoleName(String role) {
    switch (role) {
      case 'user': return 'مستخدم';
      case 'doctor': return 'طبيب';
      case 'nurse': return 'ممرض';
      case 'midwife': return 'قابلة وتوليد';
      case 'physiotherapist': return 'علاج فيزيائي';
      case 'pharmacist': return 'صيدلي';
      case 'lab': return 'مختبر';
      case 'paramedic': return 'مسعف';
      case 'delivery': return 'موصل طلبات';
      case 'service': return 'خدمي';
      case 'veterinarian': return 'بيطري';
      case 'admin': return 'مشرف';
      default: return 'مستخدم';
    }
  }

  static UserRole getUserRoleFromString(String role) {
    switch (role) {
      case 'doctor': return UserRole.doctor;
      case 'nurse': return UserRole.doctor;
      case 'midwife': return UserRole.doctor;
      case 'physiotherapist': return UserRole.doctor;
      case 'pharmacist': return UserRole.pharmacist;
      case 'lab': return UserRole.lab;
      case 'paramedic': return UserRole.doctor;
      case 'veterinarian': return UserRole.veterinarian;
      case 'admin': return UserRole.admin;
      default: return UserRole.user;
    }
  }
}
