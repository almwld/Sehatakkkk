import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class DrugDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> drugInfo;

  const DrugDetailsScreen({super.key, required this.drugInfo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: drugInfo['name'] as String,
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('الاسم', drugInfo['name'] ?? 'غير معروف', isDark),
                  _buildInfoRow('التصنيف', drugInfo['category'] ?? 'غير معروف', isDark),
                  _buildInfoRow('السعر', '${drugInfo['price'] ?? 0} ر.ي', isDark),
                  _buildInfoRow('الجرعة', drugInfo['dose'] ?? 'حسب الحاجة', isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }
}
