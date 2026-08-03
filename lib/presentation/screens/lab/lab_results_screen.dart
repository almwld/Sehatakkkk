import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LabResultsScreen extends StatelessWidget {
  final String labId;

  const LabResultsScreen({super.key, required this.labId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ بيانات تجريبية
    final results = [
      {'date': '2024-01-15', 'test': 'تعداد دم كامل', 'result': 'طبيعي', 'doctor': 'د. محمد الذبحاني'},
      {'date': '2024-01-10', 'test': 'وظائف كبد', 'result': 'مرتفع قليلاً', 'doctor': 'د. أحمد العزي'},
      {'date': '2024-01-05', 'test': 'فيتامين د', 'result': 'ناقص', 'doctor': 'د. محمد الذبحاني'},
      {'date': '2023-12-28', 'test': 'دهون ثلاثية', 'result': 'طبيعي', 'doctor': 'د. أحمد العزي'},
      {'date': '2023-12-20', 'test': 'سكر الدم', 'result': 'طبيعي', 'doctor': 'د. محمد الذبحاني'},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('📊 نتائج الفحوصات السابقة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          final isNormal = result['result'] == 'طبيعي';
          final color = isNormal ? Colors.green : Colors.orange;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['test'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${result['date']} • ${result['doctor']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result['result'],
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
