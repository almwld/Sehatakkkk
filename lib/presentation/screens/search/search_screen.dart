import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('بحث'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('شاشة البحث قيد التطوير'),
      ),
    );
  }
}
