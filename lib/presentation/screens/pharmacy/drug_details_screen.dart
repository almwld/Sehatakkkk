import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class DrugDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> drug;

  const DrugDetailsScreen({super.key, required this.drug});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ معلومات الدواء التجريبية
    final drugInfo = {
      'name': drug['name'],
      'category': drug['category'],
      'price': drug['price'],
      'prescription': drug['prescription'],
      'usage': 'يستخدم لعلاج الألم والحمى والالتهابات',
      'sideEffects': 'قد يسبب غثيان، دوار، أو حساسية',
      'interactions': 'تجنب استخدامه مع الكحول أو أدوية أخرى',
      'dosage': 'قرص كل 6-8 ساعات حسب الحاجة',
      'storage': 'يحفظ في مكان جاف وبارد',
      'manufacturer': 'شركة الدواء',
      'expiry': '2025-12-31',
    };

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(drugInfo['name']),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ صورة الدواء
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.medication, size: 60, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الاسم والسعر
            Row(
              children: [
                Expanded(
                  child: Text(
                    drugInfo['name'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${drugInfo['price']} ر.ي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ✅ التصنيف والوصفة
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    drugInfo['category'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (drugInfo['prescription'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '⚠️ يحتاج وصفة',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(),
            const SizedBox(height: 16),

            // ✅ التفاصيل
            _buildDetailItem('💊 الاستخدام', drugInfo['usage'], isDark),
            _buildDetailItem('⚠️ الآثار الجانبية', drugInfo['sideEffects'], isDark),
            _buildDetailItem('🔄 التفاعلات', drugInfo['interactions'], isDark),
            _buildDetailItem('💉 الجرعة', drugInfo['dosage'], isDark),
            _buildDetailItem('🏷️ الشركة المصنعة', drugInfo['manufacturer'], isDark),
            _buildDetailItem('📅 تاريخ الانتهاء', drugInfo['expiry'], isDark),
            _buildDetailItem('❄️ التخزين', drugInfo['storage'], isDark),

            const SizedBox(height: 24),

            // ✅ بدائل الدواء
            const Text(
              '💊 بدائل الدواء',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'دواء بديل 1',
                'دواء بديل 2',
                'دواء بديل 3',
              ].map((alt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    alt,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ✅ زر الطلب
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ تم إضافة الدواء إلى السلة'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '🛒 إضافة إلى السلة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
