import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  final List<Map<String, dynamic>> _topics = const [
    {'title': 'جروح ونزيف', 'icon': Icons.bloodtype, 'color': AppColors.error, 'steps': ['1. اضغط على الجرح', '2. نظف الجرح', '3. ضمّد الجرح']},
    {'title': 'حروق', 'icon': Icons.local_fire_department, 'color': AppColors.warning, 'steps': ['1. برد المنطقة', '2. لا تضع ثلجاً مباشراً', '3. غطّ الحرق']},
    {'title': 'كسور', 'icon': Icons.healing, 'color': AppColors.info, 'steps': ['1. لا تحرك المصاب', '2. ثبت الكسر', '3. اطلب الإسعاف']},
    {'title': 'اختناق', 'icon': Icons.air, 'color': AppColors.purple, 'steps': ['1. مناورة هايمليش', '2. إذا فشلت، اتصل بالإسعاف']},
    {'title': 'ضربة شمس', 'icon': Icons.wb_sunny, 'color': AppColors.orange, 'steps': ['1. انقل المصاب لمكان بارد', '2. برد الجسم', '3. قدم سوائل']},
    {'title': 'لدغات وحشرات', 'icon': Icons.bug_report, 'color': AppColors.teal, 'steps': ['1. اغسل المكان', '2. ضع ثلجاً', '3. لا تخدش']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإسعافات الأولية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.error, Color(0xFFC62828)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emergency, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('للطوارئ اتصل', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('📞 199', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('إرشادات الإسعافات الأولية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._topics.map((topic) => _buildTopicCard(topic)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    final color = topic['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(topic['icon'], color: color, size: 22),
        ),
        title: Text(topic['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        children: topic['steps'].map<Widget>((step) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 14),
              const SizedBox(width: 8),
              Expanded(child: Text(step, style: const TextStyle(fontSize: 13))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
