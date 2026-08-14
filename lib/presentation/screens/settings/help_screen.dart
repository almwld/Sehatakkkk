import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _expandedIndex = -1;

  // ✅ الأسئلة الشائعة
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'كيف يمكنني حجز موعد مع طبيب؟',
      'answer': 'يمكنك حجز موعد من خلال الذهاب إلى قسم "الأطباء" واختيار الطبيب المناسب، ثم الضغط على زر "حجز موعد". يمكنك أيضاً حجز موعد من خلال شاشة "مواعيدي".',
    },
    {
      'question': 'كيف يمكنني التواصل مع الطبيب؟',
      'answer': 'يمكنك التواصل مع الطبيب من خلال الدردشة المباشرة في قسم "الدردشة" أو من خلال مكالمة فيديو عبر زر "مكالمة فيديو" في صفحة تفاصيل الطبيب.',
    },
    {
      'question': 'كيف يمكنني طلب أدوية من الصيدلية؟',
      'answer': 'يمكنك طلب الأدوية من خلال الذهاب إلى قسم "الصيدلية" واختيار المنتجات المطلوبة، ثم إضافتها إلى السلة وإتمام عملية الشراء.',
    },
    {
      'question': 'كيف يمكنني عرض نتائج الفحوصات؟',
      'answer': 'يمكنك عرض نتائج الفحوصات من خلال قسم "السجل الطبي" حيث ستجد جميع الفحوصات السابقة والنتائج المرتبطة بها.',
    },
    {
      'question': 'كيف يمكنني تغيير كلمة المرور؟',
      'answer': 'يمكنك تغيير كلمة المرور من خلال الذهاب إلى "الإعدادات" ثم اختيار "تغيير كلمة المرور" وإدخال البيانات المطلوبة.',
    },
    {
      'question': 'كيف يمكنني التواصل مع الدعم الفني؟',
      'answer': 'يمكنك التواصل مع الدعم الفني من خلال البريد الإلكتروني: support@sehatak.com أو عبر رقم الهاتف: +967 1 234 567.',
    },
  ];

  // ✅ معلومات الاتصال
  final List<Map<String, dynamic>> _contactInfo = [
    {'icon': Icons.email, 'label': 'البريد الإلكتروني', 'value': 'support@sehatak.com', 'action': 'mailto:support@sehatak.com'},
    {'icon': Icons.phone, 'label': 'رقم الهاتف', 'value': '+967 1 234 567', 'action': 'tel:+9671234567'},
    {'icon': Icons.location_on, 'label': 'العنوان', 'value': 'صنعاء - اليمن', 'action': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'المساعدة والدعم',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ عنوان القسم
            const Text(
              'الأسئلة الشائعة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الأسئلة الشائعة
            ..._faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              final isExpanded = _expandedIndex == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    expandedAlignment: Alignment.centerRight,
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    title: Text(
                      faq['question'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    trailing: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.primary,
                    ),
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedIndex = expanded ? index : -1;
                      });
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          faq['answer'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // ✅ معلومات الاتصال
            const Text(
              'معلومات الاتصال',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
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
              ),
              child: Column(
                children: _contactInfo.map((info) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            info['icon'] as IconData,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info['label'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final action = info['action'] as String;
                                  if (action.isNotEmpty) {
                                    _launchUrl(action);
                                  }
                                },
                                child: Text(
                                  info['value'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: info['action'].toString().isNotEmpty
                                        ? AppColors.primary
                                        : (isDark ? Colors.white : Colors.black87),
                                    decoration: info['action'].toString().isNotEmpty
                                        ? TextDecoration.underline
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ زر إرسال رسالة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _launchUrl('mailto:support@sehatak.com?subject=استفسار من تطبيق صحتك');
                },
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text(
                  'إرسال رسالة للدعم الفني',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
