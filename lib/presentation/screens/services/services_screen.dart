import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  final List<Map<String, dynamic>> _services = const [
    {'icon': '🏥', 'name': 'حجز موعد', 'color': 0xFF0D5257},
    {'icon': '💊', 'name': 'طلب دواء', 'color': 0xFF4CAF50},
    {'icon': '🔬', 'name': 'فحص مخبري', 'color': 0xFF9C27B0},
    {'icon': '🩺', 'name': 'استشارة طبية', 'color': 0xFF2196F3},
    {'icon': '🚑', 'name': 'طوارئ', 'color': 0xFFF44336},
    {'icon': '🏠', 'name': 'رعاية منزلية', 'color': 0xFFFF9800},
    {'icon': '💉', 'name': 'تبرع بالدم', 'color': 0xFFE91E63},
    {'icon': '🧠', 'name': 'صحة نفسية', 'color': 0xFF9C27B0},
    {'icon': '🏃', 'name': 'تمارين', 'color': 0xFF00BCD4},
    {'icon': '🥗', 'name': 'تغذية', 'color': 0xFF4CAF50},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('جميع الخدمات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          final color = Color(service['color'] as int);
          return Container(
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
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        service['icon'] as String,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
