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
        title: const Text('سياسة الخصوصية'),
        backgroundColor: const Color(0xFF0D5257),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سياسة الخصوصية لتطبيق صحتك',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'نحن في تطبيق صحتك نلتزم بحماية خصوصيتك. هذه السياسة تشرح كيفية جمع واستخدام وحماية بياناتك الشخصية.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection('١. المعلومات التي نجمعها', isDark),
            _buildSection('٢. كيفية استخدام معلوماتك', isDark),
            _buildSection('٣. مشاركة المعلومات', isDark),
            _buildSection('٤. حماية المعلومات', isDark),
            _buildSection('٥. حقوقك', isDark),
            _buildSection('٦. التغييرات على السياسة', isDark),
            const SizedBox(height: 20),
            Text(
              'آخر تحديث: 4 يوليو 2026',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0D5257),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'هذا هو نص السياسة الخاص بـ $title. يتم تحديد التفاصيل الكاملة في الوثيقة الرسمية.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
