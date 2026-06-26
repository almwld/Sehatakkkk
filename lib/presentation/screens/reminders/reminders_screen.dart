import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('التذكيرات'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('التذكيرات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('reminders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('dateTime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final reminders = snapshot.data?.docs ?? [];
          if (reminders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm, size: 60, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد تذكيرات', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final data = reminders[index].data() as Map<String, dynamic>;
              final dateTime = (data['dateTime'] as Timestamp).toDate();
              final isCompleted = data['completed'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.grey[100] : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  border: Border.all(color: isCompleted ? Colors.grey[300]! : AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isCompleted,
                      activeColor: AppColors.success,
                      onChanged: (value) async {
                        await _firestore.collection('reminders').doc(reminders[index].id).update({
                          'completed': value,
                          'completedAt': value ? FieldValue.serverTimestamp() : null,
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'تذكير',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (data['description'] != null)
                            Text(data['description'], style: TextStyle(fontSize: 12, color: isCompleted ? Colors.grey : AppColors.grey)),
                          Text(
                            DateFormat('EEEE، dd MMMM yyyy - hh:mm a', 'ar').format(dateTime),
                            style: TextStyle(fontSize: 10, color: isCompleted ? Colors.grey : AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: isCompleted ? Colors.grey : AppColors.error),
                      onPressed: () async {
                        await _firestore.collection('reminders').doc(reminders[index].id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إضافة تذكير', style: TextStyle(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: const Icon(Icons.title, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                textAlign: TextAlign.right,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  prefixIcon: const Icon(Icons.note, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('ar', 'YE'),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) setState(() => _selectedTime = time);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(_selectedTime.format(context)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final user = _auth.currentUser;
              if (user == null || _titleCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال العنوان'), backgroundColor: AppColors.warning));
                return;
              }
              final dateTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );
              await _firestore.collection('reminders').add({
                'userId': user.uid,
                'title': _titleCtrl.text.trim(),
                'description': _descCtrl.text.trim(),
                'dateTime': Timestamp.fromDate(dateTime),
                'completed': false,
                'createdAt': FieldValue.serverTimestamp(),
              });
              _titleCtrl.clear();
              _descCtrl.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم إضافة التذكير'), backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
