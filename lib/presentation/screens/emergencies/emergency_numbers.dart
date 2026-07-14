import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyNumbers extends StatelessWidget {
  const EmergencyNumbers({super.key});

  Future<void> _makeCall(String number) async {
    final url = 'tel:$number';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error making call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final numbers = [
      {'name': 'الشرطة', 'number': '199', 'icon': Icons.local_police, 'color': Colors.blue, 'description': 'الطوارئ الأمنية'},
      {'name': 'الإسعاف', 'number': '191', 'icon': Icons.medical_services, 'color': Colors.red, 'description': 'الحالات الحرجة'},
      {'name': 'مطافئ', 'number': '16', 'icon': Icons.fire_extinguisher, 'color': Colors.orange, 'description': 'الحرائق والكوارث'},
      {'name': 'الدفاع المدني', 'number': '194', 'icon': Icons.shield, 'color': Colors.green, 'description': 'الطوارئ العامة'},
      {'name': 'الدعم النفسي', 'number': '185', 'icon': Icons.psychology, 'color': Colors.purple, 'description': 'الدعم النفسي'},
      {'name': 'التسمم', 'number': '180', 'icon': Icons.warning_amber_rounded, 'color': Colors.orange, 'description': 'حالات التسمم'},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الطوارئ'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('اتصل بالرقم المناسب للحالة الطارئة'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ SOS Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.redAccent],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.sos,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                const Text(
                  'في حالات الطوارئ، اتصل فوراً',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _makeCall('191'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'اتصل الآن 191',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ✅ قائمة الأرقام
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: numbers.length,
              itemBuilder: (context, index) {
                final item = numbers[index];
                final color = item['color'] as Color;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2540) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(item['icon'] as IconData, color: color),
                    ),
                    title: Text(
                      item['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      item['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['number'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    onTap: () => _makeCall(item['number'] as String),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
