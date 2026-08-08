import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class InsuranceCompaniesScreen extends StatelessWidget {
  const InsuranceCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final companies = [
      {'name': 'شركة الأمان للتأمين', 'coverage': 'حتى 5,000,000 ريال', 'rating': 4.8},
      {'name': 'اليمن للتأمين', 'coverage': 'حتى 3,000,000 ريال', 'rating': 4.6},
      {'name': 'شركة سبأ للتأمين', 'coverage': 'حتى 4,000,000 ريال', 'rating': 4.7},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('شركات التأمين'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: companies.length,
        itemBuilder: (context, index) {
          final company = companies[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.shield, color: AppColors.primary),
              title: Text(company['name'] as String),
              subtitle: Text(company['coverage'] as String),
              trailing: Text('⭐ ${company['rating']}'),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
