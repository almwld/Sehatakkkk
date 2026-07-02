import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'الشروط والأحكام',
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
                    'آخر تحديث: 2 يوليو 2026',
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

            // ✅ مقدمة
            _buildSection(
              title: 'مقدمة',
              content:
                  'مرحباً بك في تطبيق "صحتك". باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بالشروط والأحكام التالية. يرجى قراءتها بعناية قبل استخدام التطبيق.',
            ),
            const SizedBox(height: 20),

            // ✅ قبول الشروط
            _buildSection(
              title: '1. قبول الشروط',
              content:
                  'باستخدامك لتطبيق "صحتك"، فإنك توافق على هذه الشروط والأحكام. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق.',
            ),
            const SizedBox(height: 20),

            // ✅ وصف الخدمة
            _buildSection(
              title: '2. وصف الخدمة',
              content:
                  '"صحتك" هو منصة رقمية تقدم خدمات الرعاية الصحية بما في ذلك:\n'
                  '• حجز المواعيد مع الأطباء.\n'
                  '• الاستشارات الطبية عن بعد (صوت وفيديو).\n'
                  '• طلب الأدوية من الصيدليات.\n'
                  '• إدارة الملف الصحي الشخصي.\n'
                  '• تذكيرات الأدوية والمواعيد.',
            ),
            const SizedBox(height: 20),

            // ✅ الحسابات
            _buildSection(
              title: '3. الحسابات',
              content:
                  '• أنت مسؤول عن الحفاظ على سرية معلومات حسابك.\n'
                  '• يجب أن تكون جميع المعلومات المقدمة دقيقة وكاملة.\n'
                  '• أنت مسؤول عن جميع الأنشطة التي تحدث عبر حسابك.\n'
                  '• يجب إخطارنا فوراً بأي استخدام غير مصرح به لحسابك.',
            ),
            const SizedBox(height: 20),

            // ⚠️ إخلاء المسؤولية الطبية (موسع)
            _buildWarningSection(
              title: '⚠️ 4. إخلاء المسؤولية الطبية',
              content:
                  'تحذير مهم: المعلومات والخدمات المقدمة في تطبيق "صحتك" هي لأغراض تعليمية ومعلوماتية فقط.\n\n'
                  '• لا تغني المعلومات المقدمة عن استشارة الطبيب المختص.\n'
                  '• يجب عليك دائماً استشارة الطبيب قبل اتخاذ أي قرارات صحية.\n'
                  '• التطبيق لا يقدم تشخيصاً طبياً أو وصفات طبية.\n'
                  '• أي قرار طبي تتخذه بناءً على معلومات التطبيق هو مسؤوليتك الشخصية.\n'
                  '• في حالات الطوارئ، اتصل على رقم الطوارئ المحلي (199).',
            ),
            const SizedBox(height: 20),

            // ⚠️ مسؤولية الأطباء والعاملين
            _buildWarningSection(
              title: '⚠️ 5. مسؤولية الأطباء والعاملين',
              content:
                  'الأطباء والعاملون في منصة "صحتك" يقدمون خدماتهم بحسن نية، ومع ذلك:\n\n'
                  '• الأطباء هم المسؤولون عن تشخيصاتهم وتوصياتهم الطبية.\n'
                  '• التطبيق مجرد وسيط يربط بين المريض والطبيب.\n'
                  '• التطبيق غير مسؤول عن الأخطاء الطبية أو التشخيصات الخاطئة.\n'
                  '• يتحمل الطبيب المسؤولية الكاملة عن الاستشارات الطبية التي يقدمها.\n'
                  '• ننصح بالحصول على رأي طبي ثانٍ في الحالات الحرجة.',
            ),
            const SizedBox(height: 20),

            // ⚠️ الأخطاء الطبية وسوء الممارسة
            _buildWarningSection(
              title: '⚠️ 6. الأخطاء الطبية وسوء الممارسة',
              content:
                  'نحن في "صحتك" نسعى لتقديم أفضل الخدمات، ولكن:\n\n'
                  '• التطبيق غير مسؤول عن الأضرار الناتجة عن الأخطاء الطبية.\n'
                  '• الأطباء هم المسؤولون قانونياً عن ممارستهم الطبية.\n'
                  '• في حالة حدوث خطأ طبي، يجب التواصل مباشرة مع الطبيب المعالج.\n'
                  '• التطبيق يقدم خدمات الوساطة فقط ولا يتحمل المسؤولية الطبية.\n'
                  '• يوصى بالاحتفاظ بسجل لجميع الاستشارات والتوصيات الطبية.',
            ),
            const SizedBox(height: 20),

            // ⚠️ مسؤولية المستخدم
            _buildWarningSection(
              title: '⚠️ 7. مسؤولية المستخدم',
              content:
                  'باستخدامك للتطبيق، فإنك توافق على:\n\n'
                  '• توفير معلومات صحية دقيقة وكاملة.\n'
                  '• متابعة تعليمات الأطباء بدقة.\n'
                  '• إبلاغ الطبيب بأي تغييرات في حالتك الصحية.\n'
                  '• عدم الاعتماد على التطبيق في الحالات الطارئة.\n'
                  '• تحمل المسؤولية الكاملة عن قراراتك الصحية.',
            ),
            const SizedBox(height: 20),

            // ✅ السلوك المقبول
            _buildSection(
              title: '8. السلوك المقبول',
              content:
                  'باتفاقك على هذه الشروط، فإنك توافق على:\n'
                  '• عدم استخدام التطبيق لأي غرض غير قانوني.\n'
                  '• عدم التسبب في إزعاج أو مضايقة الآخرين.\n'
                  '• عدم محاولة اختراق أمان التطبيق.\n'
                  '• عدم نشر محتوى ضار أو مسيء.',
            ),
            const SizedBox(height: 20),

            // ✅ الملكية الفكرية
            _buildSection(
              title: '9. الملكية الفكرية',
              content:
                  'جميع المحتويات في تطبيق "صحتك" بما في ذلك النصوص، الصور، الشعارات، والتصميمات هي ملكية خاصة بنا أو مرخصة لنا ولا يجوز استخدامها دون إذن مسبق.',
            ),
            const SizedBox(height: 20),

            // ✅ التعديلات
            _buildSection(
              title: '10. التعديلات على الشروط',
              content:
                  'نحتفظ بالحق في تعديل هذه الشروط والأحكام في أي وقت. سيتم إخطارك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني. استمرارك في استخدام التطبيق بعد التعديلات يعني موافقتك عليها.',
            ),
            const SizedBox(height: 20),

            // ✅ إنهاء الخدمة
            _buildSection(
              title: '11. إنهاء الخدمة',
              content:
                  'نحتفظ بالحق في تعليق أو إنهاء حسابك في حالة انتهاك هذه الشروط أو لأي سبب آخر نراه مناسباً دون إشعار مسبق.',
            ),
            const SizedBox(height: 20),

            // ✅ القانون الحاكم
            _buildSection(
              title: '12. القانون الحاكم',
              content:
                  'تخضع هذه الشروط والأحكام لقوانين الجمهورية اليمنية. يتم حل أي نزاعات بموجب هذه القوانين.',
            ),
            const SizedBox(height: 20),

            // ✅ اتصل بنا
            _buildSection(
              title: '13. اتصل بنا',
              content:
                  'إذا كان لديك أي استفسار حول هذه الشروط، يمكنك التواصل معنا عبر:\n'
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
                      'باستخدامك لتطبيق "صحتك"، فإنك توافق على جميع الشروط والأحكام بما فيها إخلاء المسؤولية الطبية.',
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

  Widget _buildWarningSection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.replaceFirst('⚠️ ', ''),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
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
      ),
    );
  }
}
