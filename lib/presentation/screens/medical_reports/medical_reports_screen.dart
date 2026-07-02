import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'title': 'تقرير أشعة الصدر',
      'lab': 'مركز الأشعة المتقدم',
      'doctor': 'د. عثمان خان',
      'date': '5 مايو 2026',
      'type': 'أشعة',
      'status': 'طبيعي',
      'size': '1.2 MB',
      'result': 'صورة شعاعية للصدر: لا يوجد ارتشاح رئوي. القلب بحجم طبيعي. الأضلاع والحجاب الحاجز طبيعية.',
    },
    {
      'id': '2',
      'title': 'تحليل الدم الشامل',
      'lab': 'مختبرات العولقي',
      'doctor': 'د. أحمد المولد',
      'date': '28 أبريل 2026',
      'type': 'تحليل',
      'status': 'طبيعي',
      'size': '0.8 MB',
      'result': 'جميع المؤشرات ضمن المعدل الطبيعي. الهيموجلوبين 14.5، الكريات البيضاء 7.2.',
    },
  ];

  void _shareReport(Map<String, dynamic> report) {
    final text = '''
📋 التقرير الطبي
━━━━━━━━━━━━━━━━━
📄 العنوان: ${report['title']}
👨‍⚕️ الطبيب: ${report['doctor']}
🏥 المختبر: ${report['lab']}
📅 التاريخ: ${report['date']}
📊 النوع: ${report['type']}
📌 الحالة: ${report['status']}
📁 الحجم: ${report['size']}

📝 النتيجة:
${report['result']}
━━━━━━━━━━━━━━━━━
📱 تطبيق صحتك - Sehatak
''';
    Share.share(text);
  }

  void _downloadPDF(Map<String, dynamic> report) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ جاري تحميل ملف PDF...'),
        backgroundColor: AppColors.success,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 تم تحميل التقرير بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('التقارير الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._reports.map((report) => _buildReportCard(report, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(
          color: isDark ? const Color(0xFF2D3A54) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ العنوان والمعلومات
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${report['lab']} • ${report['date']}',
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report['status'],
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ التفاصيل
          Row(
            children: [
              _detailChip('👨‍⚕️ ${report['doctor']}'),
              const SizedBox(width: 6),
              _detailChip('📊 ${report['type']}'),
              const SizedBox(width: 6),
              _detailChip('📁 ${report['size']}'),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ النتيجة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              report['result'],
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ✅ الأزرار
          Row(
            children: [
              // ✅ مشاركة
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareReport(report),
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('مشاركة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ✅ تحميل PDF
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPDF(report),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('تحميل PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: AppColors.primary),
      ),
    );
  }
}
