import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ التاريخ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'آخر تحديث: 1 يوليو 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ✅ المقدمة
            _buildSection(
              title: 'المقدمة',
              content:
                  'نحن في "صحتك" نولي خصوصية بياناتك أهمية قصوى. توضح سياسة الخصوصية هذه كيفية جمعنا واستخدامنا وحمايتنا لمعلوماتك الشخصية عند استخدامك لتطبيقنا.',
            ),
            const SizedBox(height: 20),
            // ✅ المعلومات التي نجمعها
            _buildSection(
              title: 'المعلومات التي نجمعها',
              content:
                  '1. المعلومات الشخصية: الاسم، البريد الإلكتروني، رقم الهاتف، تاريخ الميلاد.\n'
                  '2. المعلومات الصحية: السجل الطبي، المواعيد، التحاليل، الوصفات الطبية.\n'
                  '3. معلومات الاستخدام: بيانات التفاعل مع التطبيق، الميزات المستخدمة.\n'
                  '4. معلومات الجهاز: نوع الجهاز، نظام التشغيل، معرف الجهاز الفريد.',
            ),
            const SizedBox(height: 20),
            // ✅ كيفية استخدام المعلومات
            _buildSection(
              title: 'كيفية استخدام معلوماتك',
              content:
                  '1. تقديم وتحسين خدمات الرعاية الصحية.\n'
                  '2. إدارة المواعيد والتذكيرات.\n'
                  '3. التواصل مع الأطباء والمختبرات.\n'
                  '4. تحليل البيانات لتحسين جودة الخدمات.\n'
                  '5. إرسال إشعارات وتحديثات مهمة.',
            ),
            const SizedBox(height: 20),
            // ✅ مشاركة المعلومات
            _buildSection(
              title: 'مشاركة المعلومات',
              content:
                  'نحن لا نشارك معلوماتك الشخصية مع أطراف ثالثة إلا في الحالات التالية:\n'
                  '• بموافقتك الصريحة.\n'
                  '• مع مقدمي الرعاية الصحية لتقديم الخدمات.\n'
                  '• للامتثال للمتطلبات القانونية.\n'
                  '• لحماية حقوقنا ومستخدمينا.',
            ),
            const SizedBox(height: 20),
            // ✅ أمان البيانات
            _buildSection(
              title: 'أمان البيانات',
              content:
                  'نحن نستخدم إجراءات أمنية متقدمة لحماية معلوماتك، بما في ذلك:\n'
                  '• تشفير البيانات أثناء النقل والتخزين.\n'
                  '• التحقق من الهوية متعدد العوامل.\n'
                  '• مراقبة النشاطات المشبوهة.\n'
                  '• تحديثات أمنية منتظمة.',
            ),
            const SizedBox(height: 20),
            // ✅ حقوق المستخدم
            _buildSection(
              title: 'حقوق المستخدم',
              content:
                  'لديك الحق في:\n'
                  '1. الوصول إلى بياناتك الشخصية.\n'
                  '2. تصحيح أو تحديث معلوماتك.\n'
                  '3. حذف حسابك وبياناتك.\n'
                  '4. سحب الموافقة في أي وقت.\n'
                  '5. تقديم شكوى إذا كنت تعتقد أن بياناتك قد استخدمت بشكل غير صحيح.',
            ),
            const SizedBox(height: 20),
            // ✅ الاتصال بنا
            _buildSection(
              title: 'الاتصال بنا',
              content:
                  'إذا كان لديك أي استفسار حول سياسة الخصوصية، يمكنك التواصل معنا عبر:\n'
                  '• البريد الإلكتروني: support@sehatak.com\n'
                  '• الهاتف: +967 123 456 789',
            ),
            const SizedBox(height: 30),
            // ✅ موافقة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'باستخدامك لتطبيق "صحتك"، فإنك توافق على سياسة الخصوصية هذه.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.8,
          ),
        ),
      ],
    );
  }
}
