import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _vaccines = [
    {'name': 'كوفيد-19', 'doses': 3, 'nextDose': '2026-07-01', 'status': 'مكتمل', 'color': AppColors.success},
    {'name': 'الإنفلونزا', 'doses': 1, 'nextDose': '2026-12-01', 'status': 'قادم', 'color': AppColors.warning},
    {'name': 'التيفوئيد', 'doses': 2, 'nextDose': '2026-09-15', 'status': 'مكتمل', 'color': AppColors.success},
    {'name': 'الكبد الوبائي B', 'doses': 3, 'nextDose': '2026-11-01', 'status': 'قيد التنفيذ', 'color': AppColors.info},
    {'name': 'الحصبة', 'doses': 2, 'nextDose': '2026-08-01', 'status': 'مكتمل', 'color': AppColors.success},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('التطعيمات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة تطعيم جديد قريباً'), backgroundColor: AppColors.info),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ ملخص التطعيمات
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('${_vaccines.length}', 'إجمالي'),
                  _statItem('${_vaccines.where((v) => v['status'] == 'مكتمل').length}', 'مكتمل'),
                  _statItem('${_vaccines.where((v) => v['status'] == 'قادم').length}', 'قادم'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('سجل التطعيمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._vaccines.map((vaccine) => _buildVaccineCard(vaccine)),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildVaccineCard(Map<String, dynamic> vaccine) {
    final color = vaccine['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.vaccines, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vaccine['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${vaccine['doses']} جرعات', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                Text('الجرعة القادمة: ${vaccine['nextDose']}', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              vaccine['status'],
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
