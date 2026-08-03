import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicationHistoryScreen extends StatelessWidget {
  const MedicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('سجل الأدوية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('سجل الأدوية قيد التطوير'),
      ),
    );
  }
}
