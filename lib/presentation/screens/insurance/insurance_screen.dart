import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التأمين الصحي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('شاشة التأمين الصحي - قيد التطوير'),
      ),
    );
  }
}
