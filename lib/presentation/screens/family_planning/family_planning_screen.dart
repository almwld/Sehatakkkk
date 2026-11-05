import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class FamilyPlanningScreen extends StatelessWidget {
  const FamilyPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context).translate('تنظيم الأسرة')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(AppStrings.of(context).translate('شاشة تنظيم الأسرة قيد التطوير')),
      ),
    );
  }
}
