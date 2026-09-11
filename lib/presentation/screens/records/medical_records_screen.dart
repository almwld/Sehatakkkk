import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});
  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _searchCtrl = TextEditingController();
  String _filterType = 'الكل';
  final _types = ['الكل', 'تقارير', 'تحاليل', 'أشعة', 'وصفات', 'ملاحظات'];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'الملفات الطبية', backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: Text('يرجى تسجيل الدخول')),
      );
    }
    final recordsQuery = _firestore.collection('medical_records').where('patientId', isEqualTo: user.uid).orderBy('date', descending: true);
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('الملفات الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddRecordDialog(context))],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: recordsQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                var records = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                final query = _searchCtrl.text.trim().toLowerCase();
                if (query.isNotEmpty) {
                  records = records.where((doc) {
                    final data = doc.data();
                    return '${data['title'] ?? ''} ${data['doctorName'] ?? ''}'.toLowerCase().contains(query);
                  }).toList();
                }
                if (_filterType != 'الكل') records = records.where((doc) => doc.data()['type'] == _filterType).toList();
                if (records.isEmpty) return const Center(child: Text('لا توجد ملفات طبية'));
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: records.length,
                  itemBuilder: (context, index) => _buildRecordCard(records[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.all(12),
    child: TextField(
      controller: _searchCtrl,
      onChanged: (_) => setState(() {}),
      textAlign: TextAlign.right,
      decoration: InputDecoration(hintText: 'ابحث عن ملف طبي...', prefixIcon: const Icon(Icons.search, color: AppColors.primary), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    ),
  );

  Widget _buildFilterChips() => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _types.length,
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemBuilder: (_, i) {
        final type = _types[i];
        return ChoiceChip(label: Text(type), selected: _filterType == type, onSelected: (_) => setState(() => _filterType = type));
      },
    ),
  );

  Widget _buildRecordCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawDate = data['date'];
    final date = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();
    final type = '${data['type'] ?? 'تقارير'}';
    final color = type == 'تحاليل' ? AppColors.info : type == 'أشعة' ? AppColors.purple : type == 'وصفات' ? AppColors.success : type == 'ملاحظات' ? AppColors.warning : AppColors.primary;
    final attachments = (data['attachments'] as List?)?.cast<dynamic>() ?? const <dynamic>[];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)), child: Text(type, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600))), const Spacer(), Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 10, color: AppColors.grey))]),
            const SizedBox(height: 8),
            Text('${data['title'] ?? 'ملف طبي'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${data['doctorName'] ?? 'طبيب'}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            if (data['description'] != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text('${data['description']}', maxLines: 2, overflow: TextOverflow.ellipsis)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.attachment, size: 14, color: AppColors.grey), const SizedBox(width: 4), Text('${attachments.length} مرفق', style: const TextStyle(fontSize: 10, color: AppColors.grey)), const Spacer(), IconButton(icon: const Icon(Icons.share, size: 18, color: AppColors.primary), onPressed: () => _shareRecord(data)), IconButton(icon: const Icon(Icons.download, size: 18, color: AppColors.primary), onPressed: () => _openFirstAttachment(attachments))]),
          ],
        ),
      ),
    );
  }

  Future<void> _shareRecord(Map<String, dynamic> data) async => Share.share('${data['title'] ?? 'ملف طبي'}\n${data['doctorName'] ?? ''}\n${data['description'] ?? ''}', subject: 'ملف طبي من صحتك');

  Future<void> _openFirstAttachment(List<dynamic> attachments) async {
    if (attachments.isEmpty) { ToastService.showInfo('لا يوجد مرفق لهذا الملف'); return; }
    final uri = Uri.tryParse('${attachments.first}');
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) { ToastService.showWarning('المرفق لا يحتوي على رابط صالح'); return; }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) ToastService.showError('تعذر فتح المرفق');
  }

  Future<void> _showAddRecordDialog(BuildContext context) async {
    final title = TextEditingController();
    final doctor = TextEditingController();
    final type = TextEditingController(text: 'تقارير');
    final desc = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('إضافة ملف طبي'),
          content: SingleChildScrollView(child: Column(children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'العنوان')), TextField(controller: doctor, decoration: const InputDecoration(labelText: 'اسم الطبيب')), TextField(controller: type, decoration: const InputDecoration(labelText: 'النوع')), TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'الوصف'))])),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ'))],
        ),
      );
      if (ok != true) return;
      final user = _auth.currentUser;
      if (user == null || title.text.trim().isEmpty) { ToastService.showWarning('يرجى إدخال عنوان الملف'); return; }
      try {
        await _firestore.collection('medical_records').add({'patientId': user.uid, 'patientName': user.displayName ?? 'مريض', 'title': title.text.trim(), 'doctorName': doctor.text.trim(), 'type': type.text.trim(), 'description': desc.text.trim(), 'attachments': [], 'date': FieldValue.serverTimestamp(), 'createdAt': FieldValue.serverTimestamp()});
        if (mounted) ToastService.showSuccess('تمت إضافة الملف الطبي');
      } catch (e) { if (mounted) ToastService.showError('تعذر حفظ الملف الطبي'); }
    } finally {
      title.dispose(); doctor.dispose(); type.dispose(); desc.dispose();
    }
  }
}
