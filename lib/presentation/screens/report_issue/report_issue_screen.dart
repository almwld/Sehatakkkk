import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإبلاغ عن مشكلة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('سيتم إضافة شاشة الإبلاغ عن مشكلة قريباً'),
      ),
    );
  }
}
