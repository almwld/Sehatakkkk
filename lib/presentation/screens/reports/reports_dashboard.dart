import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'title': 'تقرير الدهون الثلاثية',
      'doctor': 'د. عثمان خان',
      'date': '25 أبريل 2026',
      'type': 'تحليل',
      'status': 'مرتفع',
      'size': '195 KB',
      'result': 'نسبة الدهون الثلاثية: 210 mg/dL (مرتفع)\nالقيمة الطبيعية: أقل من 150 mg/dL',
    },
    {
      'id': '2',
      'title': 'تقرير السكر التراكمي HbA1c',
      'doctor': 'د. حسن رضا',
      'date': '20 أبريل 2026',
      'type': 'تحليل',
      'status': 'طبيعي',
      'size': '210 KB',
      'result': 'نسبة السكر التراكمي: 5.8%\nالقيمة الطبيعية: أقل من 5.7%',
    },
    {
      'id': '3',
      'title': 'تقرير فيتامين د',
      'doctor': 'د. عائشة ملك',
      'date': '15 أبريل 2026',
      'type': 'تحليل',
      'status': 'منخفض',
      'size': '175 KB',
      'result': 'نسبة فيتامين د: 18 ng/mL (منخفض)\nالقيمة الطبيعية: 30-100 ng/mL',
    },
    {
      'id': '4',
      'title': 'تقرير الغدة الدرقية',
      'doctor': 'د. حسن رضا',
      'date': '10 أبريل 2026',
      'type': 'تحليل',
      'status': 'طبيعي',
      'size': '230 KB',
      'result': 'TSH: 2.5 mIU/L (طبيعي)\nT3: 1.2 ng/mL (طبيعي)\nT4: 8.5 µg/dL (طبيعي)',
    },
    {
      'id': '5',
      'title': 'تقرير تخطيط القلب',
      'doctor': 'د. عثمان خان',
      'date': '5 أبريل 2026',
      'type': 'تخطيط',
      'status': 'طبيعي',
      'size': '450 KB',
      'result': 'نبضات القلب منتظمة\nمعدل ضربات القلب: 72 bpm',
    },
  ];

  void _showReportDetails(Map<String, dynamic> report) {
    final statusColor = report['status'] == 'طبيعي'
        ? AppColors.success
        : report['status'] == 'مرتفع'
            ? AppColors.error
            : AppColors.warning;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${report['date']} • ${report['type']}',
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report['status'],
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                _detailChip('👨‍⚕️ ${report['doctor']}'),
                const SizedBox(width: 8),
                _detailChip('📁 ${report['size']}'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'نتيجة التقرير',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report['result'],
                style: const TextStyle(fontSize: 14, height: 1.8),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📄 جاري تحميل PDF...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('تحميل PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('إغلاق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        style: TextStyle(fontSize: 11, color: AppColors.primary),
      ),
    );
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ إحصائيات سريعة
            _buildStats(),
            const SizedBox(height: 20),
            // ✅ قائمة التقارير
            ..._reports.map((report) => _buildReportCard(report, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _statCard('4', 'يحتاج متابعة', AppColors.error),
        const SizedBox(width: 8),
        _statCard('7', 'طبيعي', AppColors.success),
        const SizedBox(width: 8),
        _statCard('11', 'تقرير', AppColors.info),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, bool isDark) {
    final statusColor = report['status'] == 'طبيعي'
        ? AppColors.success
        : report['status'] == 'مرتفع'
            ? AppColors.error
            : AppColors.warning;

    return GestureDetector(
      onTap: () => _showReportDetails(report),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
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
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${report['doctor']} • ${report['date']}',
                    style: TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                  Text(
                    '${report['type']} • ${report['size']}',
                    style: TextStyle(fontSize: 10, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report['status'],
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'معاينة',
                    style: TextStyle(fontSize: 9, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
