import 'package:flutter/material.dart';

class FamilyPlanningScreen extends StatelessWidget {
  const FamilyPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظيم الأسرة'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('شاشة تنظيم الأسرة قيد التطوير'),
      ),
    );
  }
}
