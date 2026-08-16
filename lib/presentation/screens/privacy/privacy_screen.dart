import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الخصوصية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سياسة الخصوصية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'نحن في صحتك نولي خصوصية بياناتك أهمية كبيرة. إليك ملخص لسياسة الخصوصية:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacyItem(
                    'جمع البيانات',
                    'نجمع البيانات الأساسية مثل الاسم والبريد الإلكتروني والمعلومات الصحية الضرورية لتقديم الخدمات.',
                    isDark,
                  ),
                  _buildPrivacyItem(
                    'استخدام البيانات',
                    'نستخدم بياناتك لتقديم خدمات صحية مخصصة وتحسين تجربتك في التطبيق.',
                    isDark,
                  ),
                  _buildPrivacyItem(
                    'مشاركة البيانات',
                    'لا نشارك بياناتك مع أطراف ثالثة إلا بموافقتك الصريحة أو عند الضرورة القانونية.',
                    isDark,
                  ),
                  _buildPrivacyItem(
                    'أمن البيانات',
                    'نتخذ إجراءات أمنية متقدمة لحماية بياناتك من الوصول غير المصرح به.',
                    isDark,
                  ),
                  _buildPrivacyItem(
                    'حذف البيانات',
                    'يمكنك طلب حذف بياناتك في أي وقت من خلال التواصل مع فريق الدعم.',
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String description, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
