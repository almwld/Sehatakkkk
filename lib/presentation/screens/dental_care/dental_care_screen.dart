import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';

class DentalCareScreen extends StatelessWidget {
  const DentalCareScreen({super.key});

  static const _services = <Map<String, dynamic>>[
    {'name': 'فحص الأسنان والفم', 'description': 'فحص شامل وتقييم صحة الأسنان واللثة', 'icon': Icons.health_and_safety_rounded},
    {'name': 'تنظيف الأسنان', 'description': 'تنظيف وإزالة الترسبات والعناية باللثة', 'icon': Icons.cleaning_services_rounded},
    {'name': 'علاج التسوس والحشوات', 'description': 'تقييم التسوس وتحديد العلاج المناسب', 'icon': Icons.medical_services_rounded},
    {'name': 'علاج العصب', 'description': 'تقييم ألم الأسنان ومشكلات العصب', 'icon': Icons.healing_rounded},
    {'name': 'تقويم الأسنان', 'description': 'استشارة لتقييم اصطفاف الأسنان والفك', 'icon': Icons.grid_view_rounded},
    {'name': 'تبييض الأسنان', 'description': 'استشارة حول خيارات تبييض الأسنان', 'icon': Icons.auto_awesome_rounded},
    {'name': 'زراعة وتركيبات الأسنان', 'description': 'استشارة لتحديد الخيارات المناسبة', 'icon': Icons.add_box_rounded},
    {'name': 'خلع الأسنان', 'description': 'تقييم الحالة قبل الخلع وتحديد الخطة', 'icon': Icons.remove_circle_outline_rounded},
  ];

  void _openDoctors(BuildContext context, {String? service}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DoctorsListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('صحة الأسنان'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 30),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رعاية الأسنان', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('اختر الخدمة ثم انتقل مباشرة إلى الأطباء المتاحين للحجز.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('الخدمات', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._services.map((service) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _openDoctors(context, service: service['name'] as String),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(12)),
                          child: Icon(service['icon'] as IconData, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(service['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(service['description'] as String, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                          ]),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openDoctors(context),
              icon: const Icon(Icons.person_search_rounded),
              label: const Text('عرض أطباء الأسنان والحجز'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
