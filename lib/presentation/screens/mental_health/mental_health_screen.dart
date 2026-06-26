import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> {
  int _stressLevel = 0;
  String _mood = '😊';

  final List<Map<String, dynamic>> _services = [
    {'icon': '🧠', 'name': 'استشارة نفسية', 'desc': 'تحدث مع معالج نفسي', 'color': AppColors.purple},
    {'icon': '📊', 'name': 'مقياس الاكتئاب', 'desc': 'تقييم حالتك النفسية', 'color': AppColors.info},
    {'icon': '🧘', 'name': 'تمارين التنفس', 'desc': 'تمارين للاسترخاء', 'color': AppColors.success},
    {'icon': '📝', 'name': 'تتبع المزاج', 'desc': 'سجل مزاجك اليومي', 'color': AppColors.warning},
  ];

  final List<Map<String, dynamic>> _tips = [
    {'title': 'خذ نفساً عميقاً', 'desc': 'تنفس بعمق 5 مرات لتخفيف التوتر', 'icon': Icons.air, 'color': AppColors.info},
    {'title': 'تحدث مع شخص تثق به', 'desc': 'مشاركة مشاعرك تخفف العبء', 'icon': Icons.people, 'color': AppColors.success},
    {'title': 'مارس نشاطاً تحبه', 'desc': 'القيام بنشاط ممتع يحسن المزاج', 'icon': Icons.favorite, 'color': AppColors.error},
    {'title': 'نام جيداً', 'desc': 'النوم الكافي يحسن الصحة النفسية', 'icon': Icons.bedtime, 'color': AppColors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصحة النفسية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ حالة المزاج
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.purple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Text(_mood, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('كيف تشعر اليوم؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _moodButton('😊', 'جيد'),
                            _moodButton('😐', 'متوسط'),
                            _moodButton('😔', 'سيئ'),
                            _moodButton('😡', 'غاضب'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('مستوى التوتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Slider(
                value: _stressLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: _stressLevel > 7 ? AppColors.error : _stressLevel > 4 ? AppColors.warning : AppColors.success,
                label: _stressLevel.toString(),
                onChanged: (value) => setState(() => _stressLevel = value.toInt()),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('مرتاح', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                Text('${_stressLevel}/10', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _stressLevel > 7 ? AppColors.error : _stressLevel > 4 ? AppColors.warning : AppColors.success)),
                Text('متوتر', style: TextStyle(fontSize: 11, color: AppColors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('الخدمات النفسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('جاري تحميل ${s['name']}...'), backgroundColor: color),
                    );
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
                        Text(s['icon'], style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(s['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color), textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text(s['desc'], style: TextStyle(color: AppColors.grey, fontSize: 10), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('نصائح يومية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._tips.map((tip) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tip['color'].withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tip['color'].withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tip['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(tip['icon'], color: tip['color'], size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(tip['desc'], style: TextStyle(fontSize: 11, color: AppColors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _moodButton(String emoji, String label) {
    final selected = _mood == emoji;
    return GestureDetector(
      onTap: () => setState(() => _mood = emoji),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.purple : Colors.transparent),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, color: selected ? AppColors.purple : AppColors.grey)),
          ],
        ),
      ),
    );
  }
}
