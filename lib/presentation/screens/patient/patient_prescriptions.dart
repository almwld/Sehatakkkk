import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PatientPrescriptions extends StatefulWidget {
  const PatientPrescriptions({super.key});

  @override
  State<PatientPrescriptions> createState() => _PatientPrescriptionsState();
}

class _PatientPrescriptionsState extends State<PatientPrescriptions> {
  final List<Map<String, dynamic>> _prescriptions = [
    {
      'id': '1',
      'doctor': 'د. خالد النخلاني',
      'date': '1 مايو 2026',
      'duration': '3 أشهر',
      'diagnosis': 'ارتفاع ضغط الدم',
      'medications': ['أملوديبين 5mg - حبة يومياً', 'هيدروكلوروتيازيد 25mg'],
      'notes': 'تجنب الأطعمة المالحة',
      'status': 'نشطة',
    },
    {
      'id': '2',
      'doctor': 'د. عائشة ملك',
      'date': '25 أبريل 2026',
      'duration': 'أسبوعين',
      'diagnosis': 'حساسية جلدية',
      'medications': ['سيتريزين 10mg', 'مرهم هيدروكلوروتيزون'],
      'notes': '',
      'status': 'نشطة',
    },
    {
      'id': '3',
      'doctor': 'د. فاطمة صديقي',
      'date': '18 أبريل 2026',
      'duration': '7 أيام',
      'diagnosis': 'التهاب حلق',
      'medications': ['أموكسيليين 500mg', 'بار.ييتامول 800mg'],
      'notes': '',
      'status': 'نشطة',
    },
  ];

  void _sharePrescription(Map<String, dynamic> prescription) {
    final text = '''
📋 الوصفة الطبية
━━━━━━━━━━━━━━━━━
👨‍⚕️ الطبيب: ${prescription['doctor']}
📅 التاريخ: ${prescription['date']}
⏳ المدة: ${prescription['duration']}
🏥 التشخيص: ${prescription['diagnosis']}

💊 الأدوية:
${prescription['medications'].map((m) => '• $m').join('\n')}

${prescription['notes'].isNotEmpty ? '📝 ملاحظات: ${prescription['notes']}' : ''}
━━━━━━━━━━━━━━━━━
📱 تطبيق صحتك - Sehatak
''';
    Share.share(text);
  }

  void _downloadPDF(Map<String, dynamic> prescription) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ جاري تحميل ملف PDF...'),
        backgroundColor: AppColors.success,
      ),
    );
    // ✅ محاكاة تحميل PDF
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 تم تحميل ملف PDF بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  void _orderMedications(Map<String, dynamic> prescription) {
    final meds = prescription['medications'].join(', ');
    final url = 'https://wa.me/?text=أريد طلب أدوية: $meds';
    _launchUrl(url);
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الرابط')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('الوصفات الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سابقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('نشطة', style: TextStyle(color: AppColors.success)),
            ),
            const SizedBox(height: 16),
            ..._prescriptions.map((prescription) => _buildPrescriptionCard(prescription, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription, bool isDark) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${prescription['date']} - ${prescription['duration']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'التشخيص: ${prescription['diagnosis']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                child: const Text(
                  'نشطة',
                  style: TextStyle(color: AppColors.success, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...prescription['medications'].map((med) => Row(
            children: [
              const Icon(Icons.medication, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(med, style: TextStyle(fontSize: 12)),
            ],
          )),
          if (prescription['notes'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📝 ${prescription['notes']}',
                style: TextStyle(fontSize: 11, color: AppColors.warning),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              // ✅ طلب الأدوية
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _orderMedications(prescription),
                  icon: const Icon(Icons.shopping_cart_rounded, size: 16),
                  label: const Text('طلب الأدوية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
                  onPressed: () => _downloadPDF(prescription),
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
              const SizedBox(width: 8),
              // ✅ مشاركة
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sharePrescription(prescription),
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
            ],
          ),
        ],
      ),
    );
  }
}
