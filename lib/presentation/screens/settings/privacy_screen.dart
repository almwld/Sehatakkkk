import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الخصوصية والأمان', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('معلومات التطبيق', isDark),
            _buildItem('نوع التطبيق', 'صحي شامل', isDark),
            _buildItem('النسخة الحالية', '1.1.0', isDark),
            _buildItem('المنصة', 'Flutter + Firebase', isDark),
            const SizedBox(height: 16),
            _buildSection('الخصوصية', isDark),
            _buildItem('جمع البيانات', 'نعم - بيانات صحية أساسية', isDark),
            _buildItem('مشاركة البيانات', 'لا - خاصة بالكامل', isDark),
            _buildItem('التشفير', 'نعم - تشفير كامل AES-256', isDark),
            _buildItem('الاحتفاظ بالبيانات', '30 يوماً بعد إلغاء الحساب', isDark),
            const SizedBox(height: 16),
            _buildSection('الأمان', isDark),
            _buildItem('المصادقة', 'بريد إلكتروني + كلمة مرور', isDark),
            _buildItem('المصادقة الثنائية', 'قريباً', isDark),
            _buildItem('البصمة', 'مدعومة', isDark),
            _buildItem('تسجيل الدخول الآمن', 'نعم - TLS 1.3', isDark),
            const SizedBox(height: 16),
            _buildSection('حقوق المستخدم', isDark),
            _buildItem('حق الوصول', 'نعم - يمكنك عرض بياناتك', isDark),
            _buildItem('حق التصحيح', 'نعم - يمكنك تعديل بياناتك', isDark),
            _buildItem('حق الحذف', 'نعم - يمكنك حذف حسابك', isDark),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'آخر تحديث: 2 يوليو 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ),
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
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
