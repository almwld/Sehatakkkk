import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterType = 'الكل';

  final List<String> _types = ['الكل', 'تحاليل', 'أشعة', 'تقارير', 'وصفات'];

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('التقارير الطبية'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReportDialog(context),
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
                  .collection('reports')
                  .where('patientId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }

                var reports = snapshot.data?.docs ?? [];
                if (_searchCtrl.text.isNotEmpty) {
                  final q = _searchCtrl.text.toLowerCase();
                  reports = reports.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['title'].toLowerCase().contains(q) ||
                        data['doctorName'].toLowerCase().contains(q);
                  }).toList();
                }
                if (_filterType != 'الكل') {
                  reports = reports.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['type'] == _filterType;
                  }).toList();
                }

                if (reports.isEmpty) {
                  return const Center(child: Text('لا توجد تقارير'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final data = reports[index].data() as Map<String, dynamic>;
                    return _buildReportCard(data);
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
            hintText: 'ابحث عن تقرير...',
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

  Widget _buildReportCard(Map<String, dynamic> data) {
    final date = (data['createdAt'] as Timestamp).toDate();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['type'] ?? 'تقرير',
                  style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data['title'] ?? 'تقرير طبي',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            data['doctorName'] ?? 'طبيب',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          if (data['notes'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                data['notes'],
                style: const TextStyle(fontSize: 12, color: AppColors.darkGrey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attachment, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text(
                '${data['attachments'] ?? 0} مرفق',
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
              const Spacer(),
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

  void _showAddReportDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إضافة تقرير طبي', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'عنوان التقرير', prefixIcon: const Icon(Icons.title, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: doctorCtrl, textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'اسم الطبيب', prefixIcon: const Icon(Icons.person, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: typeCtrl, textAlign: TextAlign.right, decoration: InputDecoration(labelText: 'النوع (تحاليل/أشعة/تقرير)', prefixIcon: const Icon(Icons.category, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 10),
              TextField(controller: notesCtrl, textAlign: TextAlign.right, maxLines: 3, decoration: InputDecoration(labelText: 'ملاحظات', prefixIcon: const Icon(Icons.note, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(color: AppColors.grey))),
          ElevatedButton(
            onPressed: () async {
              final user = _auth.currentUser;
              if (user == null || titleCtrl.text.isEmpty || doctorCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء الحقول'), backgroundColor: AppColors.warning));
                return;
              }
              await _firestore.collection('reports').add({
                'patientId': user.uid,
                'title': titleCtrl.text.trim(),
                'doctorName': doctorCtrl.text.trim(),
                'type': typeCtrl.text.trim(),
                'notes': notesCtrl.text.trim(),
                'attachments': 0,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم إضافة التقرير'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
