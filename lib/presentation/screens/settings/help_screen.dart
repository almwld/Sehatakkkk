import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final faqs = [
      {'q': 'كيف يمكنني حجز موعد؟', 'a': 'يمكنك حجز موعد من خلال شاشة الأطباء أو شاشة الحجز المخصصة.'},
      {'q': 'كيف يمكنني التواصل مع الطبيب؟', 'a': 'يمكنك التواصل مع الطبيب عبر الدردشة أو المكالمات الصوتية والمرئية.'},
      {'q': 'كيف يمكنني شراء الأدوية؟', 'a': 'يمكنك شراء الأدوية من خلال شاشة الصيدلية وإضافة المنتجات للسلة.'},
      {'q': 'كيف يمكنني تتبع طلبي؟', 'a': 'يمكنك تتبع طلبك من خلال شاشة تتبع الطلب.'},
      {'q': 'كيف يمكنني تغيير كلمة المرور؟', 'a': 'يمكنك تغيير كلمة المرور من خلال الإعدادات > الحساب.'},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('مركز المساعدة'),
        backgroundColor: const Color(0xFF0D5257),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0D5257).withOpacity(0.1),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF0D5257),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                faq['q'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq['a'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
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
