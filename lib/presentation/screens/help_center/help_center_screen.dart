import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'كيف يمكنني حجز موعد مع طبيب؟',
      'answer': 'يمكنك حجز موعد من خلال الذهاب إلى قسم "الأطباء" واختيار الطبيب المناسب، ثم الضغط على زر "حجز موعد".',
    },
    {
      'question': 'كيف أستخدم خدمة الاستشارة الفورية؟',
      'answer': 'من خلال قسم "استشارة فورية" يمكنك التحدث مع طبيب عبر الدردشة النصية أو المكالمة الصوتية.',
    },
    {
      'question': 'كيف أتبع حالة طلبي في الصيدلية؟',
      'answer': 'يمكنك متابعة طلبك من خلال قسم "طلباتي" في الصيدلية، حيث ستظهر لك حالة الطلب وتفاصيل التوصيل.',
    },
    {
      'question': 'كيف أضيف أفراد عائلتي للتطبيق؟',
      'answer': 'من خلال قسم "الملف الشخصي" يمكنك إضافة أفراد العائلة وإدارة ملفاتهم الصحية.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                faq['question'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq['answer'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5,
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
