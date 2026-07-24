class AppRoles {
  static const List<String> all = [
    'patient',
    'doctor',
    'pharmacist',
    'lab',
    'hospital',
    'nurse',
    'midwife',
    'physiotherapist',
    'paramedic',
    'delivery',
    'service',
    'veterinarian',
    'admin',
  ];

  static bool needsVerification(String role) {
    return role == 'doctor' || role == 'pharmacist' || role == 'lab' || role == 'hospital';
  }

  static String getRoleName(String role) {
    switch (role) {
      case 'patient': return 'مريض';
      case 'doctor': return 'طبيب';
      case 'pharmacist': return 'صيدلي';
      case 'lab': return 'مختبر';
      case 'hospital': return 'مستشفى';
      case 'nurse': return 'ممرض';
      case 'midwife': return 'قابلة';
      case 'physiotherapist': return 'معالج فيزيائي';
      case 'paramedic': return 'مسعف';
      case 'delivery': return 'موصل طلبات';
      case 'service': return 'خدمي';
      case 'veterinarian': return 'بيطري';
      case 'admin': return 'مشرف';
      default: return 'مستخدم';
    }
  }
}
