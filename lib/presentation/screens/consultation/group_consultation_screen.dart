import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class GroupConsultationScreen extends StatefulWidget {
  const GroupConsultationScreen({super.key});

  @override
  State<GroupConsultationScreen> createState() => _GroupConsultationScreenState();
}

class _GroupConsultationScreenState extends State<GroupConsultationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _topicCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الاستشارات الجماعية'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستشارات الجماعية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateConsultationDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('group_consultations')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final consultations = snapshot.data?.docs ?? [];
          if (consultations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_work, size: 60, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد استشارات جماعية', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: consultations.length,
            itemBuilder: (context, index) {
              final data = consultations[index].data() as Map<String, dynamic>;
              return _buildConsultationCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> data) {
    final date = (data['createdAt'] as Timestamp).toDate();
    final participants = data['participants'] as List? ?? [];
    final status = data['status'] ?? 'مفتوحة';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(
          color: status == 'مفتوحة' ? AppColors.success.withOpacity(0.2) : AppColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status == 'مفتوحة' ? AppColors.success.withOpacity(0.1) : AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    color: status == 'مفتوحة' ? AppColors.success : AppColors.grey,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(data['topic'] ?? 'استشارة جماعية', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(data['description'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people, size: 14, color: AppColors.grey),
              const SizedBox(width: 4),
              Text('${participants.length} مشارك', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري الانضمام...'), backgroundColor: AppColors.primary),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 'مفتوحة' ? AppColors.primary : AppColors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(fontSize: 10),
                ),
                child: Text(status == 'مفتوحة' ? 'انضم' : 'مغلقة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateConsultationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('استشارة جماعية جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _topicCtrl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'عنوان الاستشارة',
                  prefixIcon: const Icon(Icons.title, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  prefixIcon: const Icon(Icons.note, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (_topicCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال العنوان'), backgroundColor: AppColors.warning),
                );
                return;
              }
              final user = _auth.currentUser;
              if (user == null) return;

              await _firestore.collection('group_consultations').add({
                'topic': _topicCtrl.text.trim(),
                'description': _descCtrl.text.trim(),
                'creatorId': user.uid,
                'creatorName': user.displayName ?? 'مستخدم',
                'participants': [user.uid],
                'status': 'مفتوحة',
                'createdAt': FieldValue.serverTimestamp(),
              });
              _topicCtrl.clear();
              _descCtrl.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ تم إنشاء الاستشارة'), backgroundColor: AppColors.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }
}
