import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HeartRateScreen extends StatelessWidget {
  const HeartRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معدل القلب'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('شاشة معدل القلب - قيد التطوير'),
      ),
    );
  }
}
