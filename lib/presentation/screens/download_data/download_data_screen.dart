import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class DownloadDataScreen extends StatefulWidget {
  const DownloadDataScreen({super.key});

  @override
  State<DownloadDataScreen> createState() => _DownloadDataScreenState();
}

class _DownloadDataScreenState extends State<DownloadDataScreen> {
  final Map<String, bool> _selectedItems = {
    'البيانات الشخصية': false,
    'السجلات الطبية': false,
    'المواعيد': false,
    'الأدوية': false,
    'النتائج والتحاليل': false,
  };

  void _downloadData() {
    final selected = _selectedItems.entries.where((e) => e.value).map((e) => e.key).toList();

    if (selected.isEmpty) {
      ToastService.showError(context, '❌ يرجى اختيار البيانات للتحميل');
      return;
    }

    ToastService.showSuccess(context, '📥 جاري تحميل البيانات...');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('تحميل بياناتي'),
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
                children: [
                  const Text(
                    'اختر البيانات التي تريد تحميلها',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._selectedItems.keys.map((key) {
                    return CheckboxListTile(
                      value: _selectedItems[key],
                      title: Text(
                        key,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _selectedItems[key] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                    'ملاحظة مهمة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'سيتم تحميل البيانات بصيغة JSON. تأكد من حفظ الملف في مكان آمن.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _downloadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تحميل البيانات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
