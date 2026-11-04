import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedCategory = 'مشكلة تقنية';
  bool _isLoading = false;

  final List<String> _categories = [
    'مشكلة تقنية',
    'خطأ في البيانات',
    'مشكلة في الدفع',
    'اقتراح تحسين',
    'شكوى عامة',
    'أخرى',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final email = _emailController.text.trim();

    if (title.isEmpty) {
      ToastService.showError(_t('يرجى إدخال عنوان للمشكلة'));
      return;
    }

    if (description.isEmpty) {
      ToastService.showError(_t('يرجى وصف المشكلة بالتفصيل'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ToastService.showSuccess('✅ ${_t('تم إرسال التقرير بنجاح')}');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('❌ ${_t('فشل إرسال التقرير: ')}$e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_t('الإبلاغ عن مشكلة')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _t('ساعدنا في تحسين التطبيق من خلال الإبلاغ عن أي مشكلة تواجهها. سنعمل على حلها في أقرب وقت.'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_t(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              decoration: InputDecoration(
                labelText: _t('تصنيف المشكلة'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(Icons.category_rounded),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: _t('عنوان المشكلة'),
                hintText: _t('مثال: تعذر تسجيل الدخول'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 6,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: _t('وصف المشكلة بالتفصيل'),
                hintText: _t('يرجى وصف المشكلة بالتفصيل مع ذكر خطوات حدوثها...'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(Icons.description_rounded),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              enabled: !_isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _t('البريد الإلكتروني (اختياري)'),
                hintText: _t('للتواصل معك بخصوص المشكلة'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                prefixIcon: Icon(Icons.email_rounded),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _t('إرسال التقرير'),
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
