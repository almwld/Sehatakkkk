import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/presentation/screens/health_tools/stress_meter_screen.dart';

class MentalHealthScreen extends StatelessWidget {
  const MentalHealthScreen({super.key});

  final List<Map<String, dynamic>> _services = const [
    {'icon': '🧠', 'name': 'استشارة نفسية', 'desc': 'تحدث مع معالج نفسي', 'color': AppColors.purple},
    {'icon': '📊', 'name': 'مقياس الاكتئاب', 'desc': 'تقييم حالتك النفسية', 'color': AppColors.info},
    {'icon': '🧘', 'name': 'تمارين التنفس', 'desc': 'تمارين للاسترخاء', 'color': AppColors.success},
    {'icon': '📝', 'name': 'تتبع المزاج', 'desc': 'سجل مزاجك اليومي', 'color': AppColors.warning},
  ];

  final List<Map<String, dynamic>> _doctors = const [
    {'name': 'د. سارة أحمد', 'specialty': 'استشارية نفسية', 'price': 300, 'rating': 4.9, 'id': '1'},
    {'name': 'د. خالد محمود', 'specialty': 'معالج سلوكي', 'price': 250, 'rating': 4.7, 'id': '2'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصحة النفسية'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'خدمات الصحة النفسية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: _services.map((s) {
                final color = s['color'] as Color;
                return GestureDetector(
                  onTap: () {
                    if (s['name'] == 'استشارة نفسية') {
                      ChatNavigation.openChat(
                        context,
                        doctorName: 'المعالج النفسي',
                        doctorId: '1',
                      );
                    } else if (s['name'] == 'مقياس الاكتئاب') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StressMeterScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s['icon'], style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          s['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['desc'],
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'أطباء الصحة النفسية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._doctors.map((d) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        d['name'][0],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          d['specialty'],
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${d['price']} ر.ي',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () => ChatNavigation.openChat(
                          context,
                          doctorName: d['name'],
                          doctorId: d['id'],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'استشر',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
