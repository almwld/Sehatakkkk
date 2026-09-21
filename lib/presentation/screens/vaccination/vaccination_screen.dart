import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});
  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _firestore.collection('users').doc(uid).collection('vaccinations');

  DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _fmt(DateTime? value) =>
      value == null ? '' : DateFormat('dd/MM/yyyy').format(value);

  Future<void> _add() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _msg('يرجى تسجيل الدخول أولاً');
      return;
    }
    final name = TextEditingController();
    final location = TextEditingController();
    DateTime? date;
    DateTime? nextDate;
    String status = 'مكتمل';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إضافة تطعيم'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'اسم اللقاح *'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'الحالة'),
                  items: const [
                    DropdownMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                    DropdownMenuItem(value: 'قادم', child: Text('قادم')),
                    DropdownMenuItem(value: 'متأخر', child: Text('متأخر')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => status = v);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(date == null ? 'تاريخ التطعيم' : _fmt(date)),
                  leading: const Icon(Icons.event),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setDialogState(() => date = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(nextDate == null
                      ? 'الجرعة القادمة (اختياري)'
                      : _fmt(nextDate)),
                  leading: const Icon(Icons.event_available),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: nextDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setDialogState(() => nextDate = d);
                  },
                ),
                TextField(
                  controller: location,
                  decoration:
                      const InputDecoration(labelText: 'المركز / المستشفى'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  _msg('أدخل اسم اللقاح');
                  return;
                }
                try {
                  await _items(uid).add({
                    'name': name.text.trim(),
                    'status': status,
                    'date': date == null ? null : Timestamp.fromDate(date!),
                    'nextDate': nextDate == null
                        ? null
                        : Timestamp.fromDate(nextDate!),
                    'location': location.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } catch (e) {
                  debugPrint('save vaccination failed: $e');
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('تعذر حفظ التطعيم')),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    location.dispose();
    if (saved == true) _msg('تم حفظ التطعيم');
  }

  Future<void> _delete(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _items(uid).doc(id).delete();
  }

  void _msg(String value) {
    if (mounted) ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول لعرض تطعيماتك')),
      );
    }

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('التطعيمات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _add,
            icon: const Icon(Icons.add),
            tooltip: 'إضافة تطعيم',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _items(uid).orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('تعذر تحميل تطعيماتك. حاول مرة أخرى.'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.vaccines_outlined, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد تطعيمات مسجلة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('ستظهر هنا التطعيمات التي تسجلها في حسابك.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة تطعيم'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data();
              final status = data['status']?.toString() ?? 'قادم';
              final date = _date(data['date']);
              final next = _date(data['nextDate']);
              final color = status == 'مكتمل'
                  ? Colors.green
                  : status == 'متأخر'
                      ? Colors.red
                      : AppColors.primary;

              return Dismissible(
                key: ValueKey(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('حذف التطعيم'),
                    content: const Text('هل تريد حذف هذا السجل؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                ),
                onDismissed: (_) => _delete(doc.id),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.vaccines_outlined),
                    ),
                    title: Text(
                      data['name']?.toString() ?? 'تطعيم',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (date != null) Text('تاريخ التطعيم: ' + _fmt(date)),
                        if (next != null)
                          Text('الجرعة القادمة: ' + _fmt(next)),
                        if ((data['location']?.toString() ?? '').trim().isNotEmpty)
                          Text(data['location'].toString()),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(status),
                      labelStyle: TextStyle(color: color, fontSize: 11),
                      backgroundColor: color.withOpacity(0.1),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
