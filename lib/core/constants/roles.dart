import 'package:flutter/material.dart';

// ✅ تعريف UserRole
enum UserRole {
  user,        // مستخدم عادي
  doctor,      // طبيب
  pharmacist,  // صيدلي
  lab,         // مختبر
  veterinarian, // بيطري
  admin,       // مشرف
  superAdmin,  // مدير المنصة
}

class AppRoles {
  // ✅ جميع الأدوار المتاحة في المنصة
  static final List<Map<String, dynamic>> all = [
    {'id': 'user', 'name': 'مستخدم', 'icon': Icons.person_outline, 'color': 0xFF0D5257, 'category': 'عام'},
    {'id': 'doctor', 'name': 'طبيب', 'icon': Icons.local_hospital_outlined, 'color': 0xFF2196F3, 'category': 'طبي'},
    {'id': 'nurse', 'name': 'ممرض', 'icon': Icons.medical_services_outlined, 'color': 0xFF00BCD4, 'category': 'طبي'},
    {'id': 'midwife', 'name': 'قابلة وتوليد', 'icon': Icons.pregnant_woman, 'color': 0xFFE91E63, 'category': 'طبي'},
    {'id': 'physiotherapist', 'name': 'علاج فيزيائي', 'icon': Icons.fitness_center, 'color': 0xFFFF9800, 'category': 'طبي'},
    {'id': 'pharmacist', 'name': 'صيدلي', 'icon': Icons.local_pharmacy_outlined, 'color': 0xFF4CAF50, 'category': 'صيدلي'},
    {'id': 'lab', 'name': 'مختبر', 'icon': Icons.science_outlined, 'color': 0xFF9C27B0, 'category': 'مختبر'},
    {'id': 'paramedic', 'name': 'مسعف', 'icon': Icons.emergency, 'color': 0xFFF44336, 'category': 'طوارئ'},
    {'id': 'delivery', 'name': 'موصل طلبات', 'icon': Icons.delivery_dining, 'color': 0xFFFF5722, 'category': 'خدمي'},
    {'id': 'service', 'name': 'خدمي', 'icon': Icons.handyman, 'color': 0xFF607D8B, 'category': 'خدمي'},
    {'id': 'veterinarian', 'name': 'بيطري', 'icon': Icons.pets, 'color': 0xFF795548, 'category': 'بيطري'},
    {'id': 'admin', 'name': 'مشرف', 'icon': Icons.admin_panel_settings, 'color': 0xFFFF5722, 'category': 'إداري'},
  ];

  // ✅ الأدوار التي تحتاج توثيق
  static final List<String> verifiedRoles = [
    'doctor', 'nurse', 'midwife', 'physiotherapist',
    'pharmacist', 'lab', 'paramedic', 'veterinarian'
  ];

  // ✅ الأدوار التي تظهر في لوحة التحكم
  static final List<String> providerRoles = [
    'doctor', 'nurse', 'midwife', 'physiotherapist',
    'pharmacist', 'lab', 'paramedic', 'delivery', 'service',
    'veterinarian'
  ];

  // ✅ الحصول على اسم الدور
  static String getRoleName(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'name': id});
    return role['name'] as String;
  }

  // ✅ الحصول على أيقونة الدور
  static IconData getRoleIcon(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'icon': Icons.person});
    return role['icon'] as IconData;
  }

  // ✅ الحصول على لون الدور
  static Color getRoleColor(String id) {
    final role = all.firstWhere((r) => r['id'] == id, orElse: () => {'color': 0xFF0D5257});
    return Color(role['color'] as int);
  }

  // ✅ هل الدور يحتاج توثيق؟
  static bool needsVerification(String roleId) {
    return verifiedRoles.contains(roleId);
  }

  // ✅ هل الدور مقدم خدمة؟
  static bool isProvider(String roleId) {
    return providerRoles.contains(roleId);
  }
}
