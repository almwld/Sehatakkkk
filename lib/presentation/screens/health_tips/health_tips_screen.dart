// ============================================================
// 📁 lib/presentation/screens/health_tips/health_tips_screen.dart
// 💡 شاشة النصائح الصحية - الإصدار النهائي
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/services/toast_service.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  String _selectedCategory = 'تغذية';

  final Map<String, List<String>> _tips = {
    'تغذية': [
      'تناول 5 حصص من الفواكه والخضروات يومياً',
      'اشرب 8 أكواب من الماء يومياً',
      'تجنب الوجبات السريعة والمشروبات الغازية',
      'تناول الأسماك مرتين أسبوعياً',
      'اختر الحبوب الكاملة بدلاً من المكررة',
      'قلل من استهلاك الملح والسكر',
      'تناول وجبة فطور متوازنة يومياً'
    ],
    'رياضة': [
      'مارس المشي 30 دقيقة يومياً',
      'تمارين الإطالة صباحاً ومساءً',
      'استخدم الدرج بدلاً من المصعد',
      'مارس تمارين القوة مرتين أسبوعياً',
      'خذ استراحة كل ساعة عمل',
      'مارس السباحة لتقوية العضلات'
    ],
    'نوم': [
      'نم 7-8 ساعات يومياً',
      'تجنب الشاشات قبل النوم بساعة',
      'حافظ على مواعيد نوم ثابتة',
      'اجعل غرفة النوم مظلمة وهادئة',
      'تجنب الكافيين مساءً',
      'مارس تمارين الاسترخاء قبل النوم'
    ],
    'صحة نفسية': [
      'مارس التأمل 10 دقائق يومياً',
      'تواصل مع الأصدقاء والعائلة',
      'خصص وقتاً لهواياتك',
      'اكتب 3 أشياء تشعر بالامتنان لها',
      'تعلم أن تقول "لا" عند الحاجة',
      'خذ استراحة من وسائل التواصل'
    ],
    'وقاية': [
      'اغسل يديك بانتظام',
      'احصل على التطعيمات الموسمية',
      'فحص سنوي شامل',
      'تجنب التدخين والكحول',
      'استخدم واقي الشمس يومياً',
      'نظف أسنانك مرتين يومياً'
    ],
    'صحة القلب': [
      'قس ضغط الدم بانتظام',
      'قلل من استهلاك الملح',
      'تناول الدهون الصحية',
      'راقب مستوى الكوليسترول',
      'تحكم في التوتر والقلق',
      'مارس تمارين الكارديو'
    ],
  };

  final Map<String, String> _categoryIcons = {
    'تغذية': 'assets/images/tracking/fruits.png',
    'رياضة': 'assets/images/tracking/walking.png',
    'نوم': 'assets/images/tracking/sleep_tracking.png',
    'صحة نفسية': 'assets/images/tracking/mental_health.png',
    'وقاية': 'assets/images/tracking/vaccination.png',
    'صحة القلب': 'assets/images/tracking/blood_pressure.png',
  };

  final Map<String, Color> _categoryColors = {
    'تغذية': AppColors.success,
    'رياضة': AppColors.info,
    'نوم': AppColors.purple,
    'صحة نفسية': Colors.teal,
    'وقاية': AppColors.primary,
    'صحة القلب': AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTips = _tips[_selectedCategory] ?? [];
    final color = _categoryColors[_selectedCategory] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF6F8FA),
      appBar: CustomAppBar(
        title: 'نصائح صحية',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ✅ شريط الفئات
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              itemCount: _tips.keys.length,
              itemBuilder: (context, i) {
                final cat = _tips.keys.elementAt(i);
                final icon = _categoryIcons[cat] ?? '';
                final color = _categoryColors[cat] ?? AppColors.primary;
                final selected = _selectedCategory == cat;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    width: 85,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: selected ? color.withOpacity(0.08) : (isDark ? const Color(0xFF1A2540) : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? color : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          icon,
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.health_and_safety,
                            color: selected ? color : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                            color: selected ? color : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // ✅ قائمة النصائح
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: currentTips.length,
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: color.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        currentTips[i],
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
