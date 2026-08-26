import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AIRecommendationsScreen extends StatelessWidget {
  const AIRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('توصيات الذكاء الاصطناعي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('شاشة توصيات الذكاء الاصطناعي - قيد التطوير'),
      ),
    );
  }
}
