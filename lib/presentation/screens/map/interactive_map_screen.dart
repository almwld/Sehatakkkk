import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class InteractiveMapScreen extends StatelessWidget {
  final String type;
  const InteractiveMapScreen({super.key, this.type = 'all'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الخريطة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text('شاشة الخريطة قيد التطوير'),
      ),
    );
  }
}
