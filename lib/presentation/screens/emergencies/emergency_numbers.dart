import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class EmergencyNumbers extends StatelessWidget {
  const EmergencyNumbers({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ أرقام الطوارئ
    final List<Map<String, dynamic>> emergencyNumbers = [
      {'name': 'الشرطة', 'number': '199', 'icon': 'assets/images/services/emergency.png', 'color': Colors.blue},
      {'name': 'الإسعاف', 'number': '191', 'icon': 'assets/images/tracking/ambulance.png', 'color': Colors.red},
      {'name': 'الدفاع المدني', 'number': '198', 'icon': 'assets/images/services/emergency.png', 'color': Colors.orange},
      {'name': 'الدعم النفسي', 'number': '800-123-456', 'icon': 'assets/images/tracking/mental_health.png', 'color': Colors.purple},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('أرقام الطوارئ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: emergencyNumbers.length,
        itemBuilder: (context, index) {
          final item = emergencyNumbers[index];
          return _buildEmergencyCard(
            icon: item['icon'] as String,
            name: item['name'] as String,
            number: item['number'] as String,
            color: item['color'] as Color,
            isDark: isDark,
            onCall: () => _makeCall(item['number'] as String),
          );
        },
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String icon,
    required String name,
    required String number,
    required Color color,
    required bool isDark,
    required VoidCallback onCall,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              icon,
              width: 32,
              height: 32,
              color: color,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.emergency, color: color, size: 32);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.call, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'اتصل',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _makeCall(String number) async {
    final url = 'tel:$number';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
