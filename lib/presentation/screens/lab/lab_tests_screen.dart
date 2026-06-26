import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LabTestsScreen extends StatefulWidget {
  const LabTestsScreen({super.key});

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _tests = [
    {'name': 'تحليل دم شامل', 'code': 'CBC', 'price': 2000, 'category': 'دم', 'icon': Icons.bloodtype, 'color': AppColors.error},
    {'name': 'فيتامين د', 'code': 'Vit D', 'price': 3500, 'category': 'فيتامينات', 'icon': Icons.wb_sunny, 'color': AppColors.warning},
    {'name': 'وظائف كبد', 'code': 'LFT', 'price': 2500, 'category': 'كبد', 'icon': Icons.healing, 'color': AppColors.info},
    {'name': 'سكر تراكمي', 'code': 'HbA1c', 'price': 1800, 'category': 'سكري', 'icon': Icons.monitor, 'color': AppColors.success},
    {'name': 'وظائف كلية', 'code': 'RFT', 'price': 2200, 'category': 'كلية', 'icon': Icons.favorite, 'color': AppColors.primary},
    {'name': 'دهون ثلاثية', 'code': 'Trig', 'price': 1200, 'category': 'دهون', 'icon': Icons.water, 'color': AppColors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _searchCtrl.text.isNotEmpty
        ? _tests.where((t) => t['name'].toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList()
        : _tests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحاليل الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة سلة التحاليل قريباً'), backgroundColor: AppColors.info),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن تحليل...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final test = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    border: Border.all(color: test['color'].withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: test['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(test['icon'], color: test['color'], size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(test['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('${test['code']} • ${test['category']}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${test['price']} ر.ي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: test['color'])),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✅ تم إضافة ${test['name']} إلى السلة'), backgroundColor: AppColors.success),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: test['color'],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(60, 24),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              textStyle: const TextStyle(fontSize: 10),
                            ),
                            child: const Text('أضف'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
