import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class TemperatureScreen extends StatelessWidget {
  const TemperatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درجة الحرارة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('شاشة درجة الحرارة - قيد التطوير'),
      ),
    );
  }
}
