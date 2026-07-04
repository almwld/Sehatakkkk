import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LabTestsScreen extends StatelessWidget {
  final String labId;
  const LabTestsScreen({super.key, this.labId = ''});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('فحوصات المختبر'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.science, color: AppColors.primaryColor),
              ),
              title: Text(
                'فحص رقم ${index + 1}',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                'نتيجة ${index % 2 == 0 ? "طبيعي" : "محتاج مراجعة"}',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}
