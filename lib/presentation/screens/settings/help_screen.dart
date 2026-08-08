import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final faqs = [
      {'q': 'كيف يمكنني حجز موعد مع طبيب؟', 'a': 'يمكنك حجز موعد من خلال شاشة الأطباء أو من خلال شاشة المواعيد.'},
      {'q': 'كيف يمكنني التواصل مع الطبيب؟', 'a': 'يمكنك التواصل عبر الدردشة أو المكالمة الصوتية أو المرئية من خلال شاشة الطبيب.'},
      {'q': 'كيف يمكنني شراء أدوية؟', 'a': 'يمكنك شراء الأدوية من خلال شاشة الصيدلية وإضافتها إلى سلة المشتريات.'},
      {'q': 'كيف يمكنني متابعة حالتي الصحية؟', 'a': 'يمكنك متابعة حالتك الصحية من خلال شاشة صحتي التي تحتوي على جميع المؤشرات الحيوية.'},
      {'q': 'التطبيق مجاني؟', 'a': 'نعم، التطبيق مجاني للاستخدام الأساسي. هناك باقات مدفوعة للخدمات المتقدمة.'},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('مركز المساعدة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: ExpansionTile(
              title: Text(
                faq['q']!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq['a']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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
