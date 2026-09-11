import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: CustomAppBar(title: const Text('التذكيرات', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white, actions: [IconButton(icon: const Icon(Icons.add), onPressed: user == null ? null : () => _showAddReminderDialog(context))]),
      body: user == null ? const Center(child: Text('يرجى تسجيل الدخول')) : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('reminders').where('userId', isEqualTo: user.uid).orderBy('dateTime').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.alarm, size: 60, color: AppColors.grey), SizedBox(height: 16), Text('لا توجد تذكيرات', style: TextStyle(color: AppColors.grey))]));
          return ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (context, index) {
            final doc = docs[index]; final data = doc.data(); final raw = data['dateTime']; final dateTime = raw is Timestamp ? raw.toDate() : DateTime.now(); final completed = data['completed'] == true;
            return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
              leading: Checkbox(value: completed, onChanged: (value) => doc.reference.update({'completed': value == true, 'completedAt': value == true ? FieldValue.serverTimestamp() : null})),
              title: Text(data['title']?.toString() ?? 'تذكير', style: TextStyle(fontWeight: FontWeight.bold, decoration: completed ? TextDecoration.lineThrough : null)),
              subtitle: Text('${data['description']?.toString() ?? ''}\n${DateFormat('yyyy-MM-dd - hh:mm a').format(dateTime)}'),
              isThreeLine: true,
              trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => doc.reference.delete()),
            ));
          });
        },
      ),
    );
  }

  Future<void> _showAddReminderDialog(BuildContext context) async {
    _selectedDate = DateTime.now(); _selectedTime = TimeOfDay.now();
    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
      title: const Text('إضافة تذكير'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'العنوان', prefixIcon: Icon(Icons.title))),
        const SizedBox(height: 8),
        TextField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'الوصف (اختياري)', prefixIcon: Icon(Icons.note))),
        const SizedBox(height: 12),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today, color: AppColors.primary), title: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)), onTap: () async { final d = await showDatePicker(context: dialogContext, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (d != null) setDialogState(() => _selectedDate = d); }),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.access_time, color: AppColors.primary), title: Text(_selectedTime.format(dialogContext)), onTap: () async { final t = await showTimePicker(context: dialogContext, initialTime: _selectedTime); if (t != null) setDialogState(() => _selectedTime = t); }),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), ElevatedButton(onPressed: () async {
        final user = _auth.currentUser;
        if (user == null || _titleCtrl.text.trim().isEmpty) { await ToastService.showWarning('يرجى إدخال العنوان'); return; }
        final dateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
        await _firestore.collection('reminders').add({'userId': user.uid, 'title': _titleCtrl.text.trim(), 'description': _descCtrl.text.trim(), 'dateTime': Timestamp.fromDate(dateTime), 'completed': false, 'createdAt': FieldValue.serverTimestamp()});
        _titleCtrl.clear(); _descCtrl.clear(); if (dialogContext.mounted) Navigator.pop(dialogContext); await ToastService.showSuccess('تم إضافة التذكير');
      }, child: const Text('حفظ'))],
    )));
  }
}
