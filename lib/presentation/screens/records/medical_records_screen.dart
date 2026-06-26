import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterType = 'الكل';

  final List<String> _types = ['الكل', 'تقارير', 'تحاليل', 'أشعة', 'وصفات', 'ملاحظات'];

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الملفات الطبية'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملفات الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('medical_records')
                  .where('patientId', isEqualTo: user.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }

                var records = snapshot.data?.docs ?? [];
                if (_searchCtrl.text.isNotEmpty) {
                  final q = _searchCtrl.text.toLowerCase();
                  records = records.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['title'].toLowerCase().contains(q) ||
                        data['doctorName'].toLowerCase().contains(q);
                  }).toList();
                }
                if (_filterType != 'الكل') {
                  records = records.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['type'] == _filterType;
                  }).toList();
                }

                if (records.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 60, color: AppColors.grey),
                        SizedBox(height: 16),
                        Text('لا توجد ملفات طبية', style: TextStyle(color: AppColors.grey)),
                        SizedBox(height: 8),
                        Text('أضف ملفاً جديداً', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final data = records[index].data() as Map<String, dynamic>;
                    return _buildRecordCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن ملف طبي...',
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final type = _types[index];
          final selected = _filterType == type;
          return GestureDetector(
            onTap: () => setState(() => _filterType = type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.darkGrey,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> data) {
    final date = (data['date'] as Timestamp).toDate();
    final type = data['type'] ?? 'تقرير';
    final color = type == 'تحاليل' ? AppColors.info :
                  type == 'أشعة' ? AppColors.purple :
                  type == 'وصفات' ? AppColors.success :
                  type == 'ملاحظات' ? AppColors.warning : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(type, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
              ),
              const Spacer(),
              Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 10, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(data['title'] ?? 'ملف طبي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(data['doctorName'] ?? 'طبيب', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          if (data['description'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(data['description'], style: const TextStyle(fontSize: 12, color: AppColors.darkGrey), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attachment, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text('${data['attachments']?.length ?? 0} مرفق', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share, size: 18, color: AppColors.primary),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.download, size: 18, color: AppColors.primary),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إضافة ملف طبي', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'العنوان', prefixIcon: const Icon(Icons.title, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 8),
              TextField(controller: doctorCtrl, textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'اسم الطبيب', prefixIcon: const Icon(Icons.person, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 8),
              TextField(controller: typeCtrl, textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'النوع (تقرير/تحليل/أشعة/وصفة)', prefixIcon: const Icon(Icons.category, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, textAlign: TextAlign.right, maxLines: 3, decoration: InputDecoration(labelText: 'الوصف', prefixIcon: const Icon(Icons.note, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final user = _auth.currentUser;
              if (user == null || titleCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال البيانات'), backgroundColor: AppColors.warning));
                return;
              }
              await _firestore.collection('medical_records').add({
                'patientId': user.uid,
                'patientName': user.displayName ?? 'مريض',
                'title': titleCtrl.text.trim(),
                'doctorName': doctorCtrl.text.trim(),
                'type': typeCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'attachments': [],
                'date': FieldValue.serverTimestamp(),
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم إضافة الملف'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
