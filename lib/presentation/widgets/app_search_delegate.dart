import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';

class AppSearchDelegate extends SearchDelegate<String?> {
  // ✅ بيانات البحث (سيتم ربطها بـ Firestore لاحقاً)
  final List<Map<String, dynamic>> _searchData = [
    // أطباء
    {'id': 'd1', 'name': 'د. أحمد المؤيد', 'subtitle': 'باطنية', 'type': 'طبيب', 'icon': Icons.medical_services},
    {'id': 'd2', 'name': 'د. خالد النخلاني', 'subtitle': 'قلبية', 'type': 'طبيب', 'icon': Icons.medical_services},
    {'id': 'd3', 'name': 'د. أسماء الهندي', 'subtitle': 'أطفال', 'type': 'طبيب', 'icon': Icons.medical_services},
    {'id': 'd4', 'name': 'د. محمد العلاي', 'subtitle': 'أنف وأذن وحنجرة', 'type': 'طبيب', 'icon': Icons.medical_services},
    {'id': 'd5', 'name': 'د. فاطمة صديقي', 'subtitle': 'نساء وولادة', 'type': 'طبيب', 'icon': Icons.medical_services},
    
    // صيدليات
    {'id': 'p1', 'name': 'صيدلية ابن حيان', 'subtitle': 'صنعاء - حدة', 'type': 'صيدلية', 'icon': Icons.local_pharmacy},
    {'id': 'p2', 'name': 'صيدلية عالم الصيدلة', 'subtitle': 'صنعاء', 'type': 'صيدلية', 'icon': Icons.local_pharmacy},
    {'id': 'p3', 'name': 'صيدلية النهضة', 'subtitle': 'صنعاء', 'type': 'صيدلية', 'icon': Icons.local_pharmacy},
    
    // مستشفيات
    {'id': 'h1', 'name': 'مستشفى 22 مايو', 'subtitle': 'صنعاء', 'type': 'مستشفى', 'icon': Icons.local_hospital},
    {'id': 'h2', 'name': 'مستشفى آزال', 'subtitle': 'صنعاء', 'type': 'مستشفى', 'icon': Icons.local_hospital},
    {'id': 'h3', 'name': 'مستشفى السبعين', 'subtitle': 'صنعاء', 'type': 'مستشفى', 'icon': Icons.local_hospital},
    
    // مختبرات
    {'id': 'l1', 'name': 'مختبرات الرازي', 'subtitle': 'صنعاء', 'type': 'مختبر', 'icon': Icons.science},
    {'id': 'l2', 'name': 'مختبرات العولقي', 'subtitle': 'صنعاء', 'type': 'مختبر', 'icon': Icons.science},
    
    // أدوية
    {'id': 'm1', 'name': 'باراسيتامول 500mg', 'subtitle': 'مسكن ألم', 'type': 'دواء', 'icon': Icons.medication},
    {'id': 'm2', 'name': 'فيتامين د 1000IU', 'subtitle': 'فيتامينات', 'type': 'دواء', 'icon': Icons.medication},
    {'id': 'm3', 'name': 'أموكسيسيلين 500mg', 'subtitle': 'مضاد حيوي', 'type': 'دواء', 'icon': Icons.medication},
  ];

  @override
  String get searchFieldLabel => 'ابحث عن طبيب، دواء، خدمة...';

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
    fontFamily: 'NotoSansArabicUI',
    fontSize: 16,
  );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = _performSearch(query);
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج لـ "$query"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب كلمات مختلفة',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return _buildResultItem(context, item);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = _getSuggestions(query);
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: Icon(item['icon'] as IconData, color: AppColors.primary),
          title: Text(item['name'] as String),
          subtitle: Text(
            '${item['type']} - ${item['subtitle']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['type'] as String,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () {
            query = item['name'] as String;
            showResults(context);
          },
        );
      },
    );
  }

  // ============================================================
  // 🧠 دوال البحث
  // ============================================================

  List<Map<String, dynamic>> _performSearch(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _searchData.where((item) {
      final name = (item['name'] as String).toLowerCase();
      final subtitle = (item['subtitle'] as String).toLowerCase();
      final type = (item['type'] as String).toLowerCase();
      return name.contains(lowerQuery) || 
             subtitle.contains(lowerQuery) ||
             type.contains(lowerQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _getSuggestions(String query) {
    if (query.isEmpty) {
      // اقتراحات افتراضية
      return _searchData.take(6).toList();
    }
    return _performSearch(query).take(6).toList();
  }

  // ============================================================
  // 🎨 عرض نتيجة البحث
  // ============================================================

  Widget _buildResultItem(BuildContext context, Map<String, dynamic> item) {
    final type = item['type'] as String;
    final id = item['id'] as String;
    
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 24),
      ),
      title: Text(
        item['name'] as String,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${item['subtitle']} • ${item['type']}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        close(context, null);
        _navigateToResult(context, type, id);
      },
    );
  }

  // ============================================================
  // 🧭 التنقل إلى النتيجة
  // ============================================================

  void _navigateToResult(BuildContext context, String type, String id) {
    switch (type) {
      case 'طبيب':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(doctor: id),
          ),
        );
        break;
      case 'مستشفى':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HospitalDetailsScreen(hospitalId: id),
          ),
        );
        break;
      case 'صيدلية':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PharmacyScreen(),
          ),
        );
        break;
      case 'دواء':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MedicinesScreen(),
          ),
        );
        break;
      default:
        ToastService.showSuccess('جاري التوجيه...');
    }
  }
}
