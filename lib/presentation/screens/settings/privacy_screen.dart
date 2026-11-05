import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = AppStrings.of(context);
    String t(String value) => strings.translate(value);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: t('الخصوصية والأمان'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(t('معلومات التطبيق'), isDark),
            _buildItem(t('نوع التطبيق'), t('صحي شامل'), isDark),
            _buildItem(t('النسخة الحالية'), '1.1.0', isDark),
            const SizedBox(height: 24),
            _buildSection(t('الخصوصية'), isDark),
            _buildItem(t('جمع البيانات'), t('نعم - بيانات صحية أساسية'), isDark),
            _buildItem(t('مشاركة البيانات'), t('لا - خاصة بالكامل'), isDark),
            _buildItem(t('التشفير'), t('نعم - تشفير كامل'), isDark),
            const SizedBox(height: 24),
            _buildSection(t('الأمان'), isDark),
            _buildItem(t('المصادقة'), t('بريد إلكتروني + كلمة مرور'), isDark),
            _buildItem(t('المصادقة الثنائية'), t('قريباً'), isDark),
            _buildItem(t('البصمة'), t('مدعومة'), isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
