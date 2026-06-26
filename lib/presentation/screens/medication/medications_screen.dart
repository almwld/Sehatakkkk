import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _medications = [
    {'name': 'باراسيتامول 500mg', 'dose': 'قرص واحد', 'frequency': 'كل 6 ساعات', 'duration': '5 أيام', 'status': 'نشط', 'color': AppColors.info},
    {'name': 'أموكسيسيلين 500mg', 'dose': 'قرصين', 'frequency': 'كل 8 ساعات', 'duration': '7 أيام', 'status': 'نشط', 'color': AppColors.primary},
    {'name': 'فيتامين د 1000IU', 'dose': 'قرص واحد', 'frequency': 'يومياً', 'duration': '30 يوماً', 'status': 'نشط', 'color': AppColors.success},
    {'name': 'أملوديبين 5mg', 'dose': 'نصف قرص', 'frequency': 'يومياً', 'duration': '90 يوماً', 'status': 'منتهي', 'color': AppColors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة دواء جديد قريباً'), backgroundColor: AppColors.info),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('${_medications.length}', 'إجمالي'),
                  _statItem('${_medications.where((m) => m['status'] == 'نشط').length}', 'نشط'),
                  _statItem('${_medications.where((m) => m['status'] == 'منتهي').length}', 'منتهي'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('قائمة الأدوية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._medications.map((med) => _buildMedicationCard(med)),
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

  Widget _buildMedicationCard(Map<String, dynamic> med) {
    final color = med['color'] as Color;
    final isActive = med['status'] == 'نشط';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: isActive ? color.withOpacity(0.2) : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication, color: isActive ? color : Colors.grey, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isActive ? null : Colors.grey)),
                const SizedBox(height: 2),
                Text('${med['dose']} • ${med['frequency']}', style: TextStyle(fontSize: 11, color: isActive ? AppColors.grey : Colors.grey[400])),
                Text('المدة: ${med['duration']}', style: TextStyle(fontSize: 10, color: isActive ? AppColors.grey : Colors.grey[400])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              med['status'],
              style: TextStyle(fontSize: 10, color: isActive ? color : Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
