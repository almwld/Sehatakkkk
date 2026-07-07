import 'package:flutter/material.dart';

class AppRoles {
  static const List<Map<String, dynamic>> all = [
    {'id': 'user', 'name': 'مستخدم', 'icon': Icons.person_outline, 'color': 0xFF0D9488},
    {'id': 'doctor', 'name': 'طبيب', 'icon': Icons.local_hospital_outlined, 'color': 0xFF0D5257},
    {'id': 'pharmacist', 'name': 'صيدلي', 'icon': Icons.local_pharmacy_outlined, 'color': 0xFF2E7D32},
    {'id': 'lab_tech', 'name': 'مخبري', 'icon': Icons.science_outlined, 'color': 0xFF6A1B9A},
    {'id': 'veterinarian', 'name': 'بيطري', 'icon': Icons.pets_outlined, 'color': 0xFFE65100},
    {'id': 'paramedic', 'name': 'مسعف', 'icon': Icons.health_and_safety_outlined, 'color': 0xFFC62828},
    {'id': 'delivery', 'name': 'موصل طلبات', 'icon': Icons.delivery_dining_outlined, 'color': 0xFFF57F17},
    {'id': 'service', 'name': 'خدمي', 'icon': Icons.support_agent_outlined, 'color': 0xFF283593},
    {'id': 'other', 'name': 'أخرى', 'icon': Icons.more_horiz_outlined, 'color': 0xFF616161},
  ];

  static Map<String, dynamic> getById(String id) {
    return all.firstWhere((r) => r['id'] == id, orElse: () => all.first);
  }

  static List<Map<String, dynamic>> getFiltered(String query) {
    if (query.isEmpty) return all;
    return all.where((r) => 
      r['name'].contains(query) || 
      r['id'].contains(query)
    ).toList();
  }
}
