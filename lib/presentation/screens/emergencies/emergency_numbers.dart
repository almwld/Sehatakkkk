import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class EmergencyNumbers extends StatelessWidget {
  const EmergencyNumbers({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numbers = [
      {'name': 'الشرطة', 'number': '199', 'icon': Icons.local_police, 'color': Colors.blue},
      {'name': 'الإسعاف', 'number': '191', 'icon': Icons.medical_services, 'color': Colors.red},
      {'name': 'مطافئ', 'number': '16', 'icon': Icons.fire_extinguisher, 'color': Colors.orange},
      {'name': 'الدفاع المدني', 'number': '194', 'icon': Icons.shield, 'color': Colors.green},
      {'name': 'الدعم النفسي', 'number': '185', 'icon': Icons.psychology, 'color': Colors.purple},
      {'name': 'التسمم', 'number': '180', 'icon': Icons.warning_amber_rounded, 'color': Colors.yellow},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('أرقام الطوارئ'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: numbers.length,
        itemBuilder: (context, index) {
          final item = numbers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item['color'] as Color,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: (item['color'] as Color).withOpacity(0.1),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'رقم الطوارئ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['number'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: item['color'] as Color,
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
