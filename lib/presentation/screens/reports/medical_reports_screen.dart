import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});
  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _searchCtrl = TextEditingController();
  String _filterType = 'الكل';
  final _types = const ['الكل', 'تحاليل', 'أشعة', 'تقارير', 'وصفات'];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(appBar: const CustomAppBar(title: Text('التقارير الطبية')), body: const Center(child: Text('يرجى تسجيل الدخول')));
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('التقارير الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddReportDialog(context))],
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(
          controller: _searchCtrl, onChanged: (_) => setState(() {}), textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: 'ابحث عن تقرير...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
        )),
        SizedBox(height: 40, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: _types.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) { final type = _types[i]; final selected = type == _filterType; return GestureDetector(
            onTap: () => setState(() => _filterType = type),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(20)), child: Text(type, style: TextStyle(color: selected ? Colors.white : Colors.grey.shade700))),
          ); },
        )),
        const SizedBox(height: 8),
        Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('reports').where('patientId', isEqualTo: user.uid).orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final query = _searchCtrl.text.trim().toLowerCase();
            final docs = (snapshot.data?.docs ?? []).where((doc) {
              final d = doc.data();
              final typeOk = _filterType == 'الكل' || d['type']?.toString() == _filterType;
              final text = '${d['title'] ?? ''} ${d['doctorName'] ?? ''}'.toLowerCase();
              return typeOk && (query.isEmpty || text.contains(query));
            }).toList();
            if (docs.isEmpty) return const Center(child: Text('لا توجد تقارير'));
            return ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (_, i) => _buildReportCard(docs[i].data()));
          },
        )),
      ]),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> data) {
    final rawDate = data['createdAt'];
    final date = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();
    return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text(data['type']?.toString() ?? 'تقرير', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)), const Spacer(), Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey))]),
      const SizedBox(height: 6), Text(data['title']?.toString() ?? 'تقرير طبي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4), Text(data['doctorName']?.toString() ?? 'طبيب', style: const TextStyle(color: Colors.grey)),
      if (data['notes'] != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(data['notes'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis)),
      const SizedBox(height: 8), Text('${data['attachments'] ?? 0} مرفق', style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ])));
  }

  void _showAddReportDialog(BuildContext context) {
    final title = TextEditingController(), doctor = TextEditingController(), type = TextEditingController(), notes = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('إضافة تقرير طبي'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان التقرير')),
        TextField(controller: doctor, decoration: const InputDecoration(labelText: 'اسم الطبيب')),
        TextField(controller: type, decoration: const InputDecoration(labelText: 'النوع')),
        TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'ملاحظات')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
        ElevatedButton(onPressed: () async {
          final user = _auth.currentUser;
          if (user == null || title.text.trim().isEmpty || doctor.text.trim().isEmpty) { ToastService.showError(context, 'يرجى ملء الحقول'); return; }
          await _firestore.collection('reports').add({'patientId': user.uid, 'title': title.text.trim(), 'doctorName': doctor.text.trim(), 'type': type.text.trim(), 'notes': notes.text.trim(), 'attachments': 0, 'createdAt': FieldValue.serverTimestamp()});
          if (dialogContext.mounted) Navigator.pop(dialogContext);
          if (mounted) ToastService.showSuccess(context, 'تم إضافة التقرير');
        }, child: const Text('حفظ')),
      ],
    ));
  }
}
