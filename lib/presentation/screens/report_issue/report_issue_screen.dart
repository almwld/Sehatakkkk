import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _issueController = TextEditingController();
  bool _includeScreenshot = false;
  String _selectedCategory = 'مشكلة تقنية';
  final List<String> _categories = [
    'مشكلة تقنية',
    'خطأ في البيانات',
    'مشكلة في الدفع',
    'اقتراح تحسين',
    'مشكلة في الحساب',
    'أخرى',
  ];

  void _submitReport() {
    if (_issueController.text.isEmpty) {
      ToastService.showError(context, '❌ يرجى كتابة تفاصيل المشكلة');
      return;
    }

    ToastService.showSuccess(context, '✅ تم إرسال البلاغ. سنراجعه ونتواصل معك.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الإبلاغ عن مشكلة'),
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
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bug_report, color: AppColors.error, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: const Text(
                      'نأسف للمشكلة! ساعدنا في حلها بإرسال التفاصيل',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل المشكلة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _issueController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'صف المشكلة بالتفصيل...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
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
              child: SwitchListTile(
                value: _includeScreenshot,
                onChanged: (value) => setState(() => _includeScreenshot = value),
                title: const Text('إرفاق لقطة شاشة'),
                subtitle: const Text('يساعدنا في فهم المشكلة بشكل أفضل'),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitReport,
                icon: const Icon(Icons.send),
                label: const Text('إرسال البلاغ'),
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
          ],
        ),
      ),
    );
  }
}
