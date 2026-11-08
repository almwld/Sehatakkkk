import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

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
  String _t(String value) => AppStrings.of(context).translate(value);

  String _localizedField(Map<String, dynamic> data, String field, {String fallback = ''}) {
    final raw = data[field];
    final rawText = raw is String ? raw.trim() : '';
    final safeFallback = rawText.isNotEmpty ? _t(rawText) : fallback;
    return localizedField(data, field, AppStrings.of(context).locale, fallback: safeFallback);
  }
  final _types = ['الكل', 'تقارير', 'تحاليل', 'أشعة', 'وصفات', 'ملاحظات'];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(title: _t('الملفات الطبية'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: Center(child: Text(_t('يرجى تسجيل الدخول'))),
      );
    }
    final recordsQuery = _firestore.collection('medical_records').where('patientId', isEqualTo: user.uid).orderBy('date', descending: true);
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(_t('الملفات الطبية'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                if (snapshot.hasError) return Center(child: Text('${_t('حدث خطأ')}: ${snapshot.error}'));
                var records = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                final query = _searchCtrl.text.trim().toLowerCase();
                if (query.isNotEmpty) {
                  records = records.where((doc) {
                    final data = doc.data();
                    final searchable = '${_localizedField(data, 'title')} ${_localizedField(data, 'doctorName')} ${_localizedField(data, 'description')}'.toLowerCase();
                    return searchable.contains(query);
                  }).toList();
                }
                if (_filterType != 'الكل') records = records.where((doc) => doc.data()['type'] == _filterType).toList();
                if (records.isEmpty) return Center(child: Text(AppStrings.of(context).translate('لا توجد ملفات طبية')));
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
    child: UnifiedSearchBar(controller: _searchCtrl, onChanged: (_) => setState(() {}), hintText: _t('ابحث عن ملف طبي...')),
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
        return ChoiceChip(label: Text(_t(type)), selected: _filterType == type, onSelected: (_) => setState(() => _filterType = type));
      },
    ),
  );

  Widget _buildRecordCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawDate = data['date'];
    final date = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();
    final type = '${data['type'] ?? 'تقارير'}';
    final typeLabel = _localizedField(data, 'type', fallback: _t('تقارير'));
    final title = _localizedField(data, 'title', fallback: _t('ملف طبي'));
    final doctorName = _localizedField(data, 'doctorName', fallback: _t('طبيب'));
    final description = _localizedField(data, 'description');
    final color = type == 'تحاليل' ? AppColors.info : type == 'أشعة' ? AppColors.purple : type == 'وصفات' ? AppColors.success : type == 'ملاحظات' ? AppColors.warning : AppColors.primary;
    final attachments = (data['attachments'] as List?)?.cast<dynamic>() ?? const <dynamic>[];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)), child: Text(typeLabel, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600))), const Spacer(), Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 10, color: AppColors.grey))]),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(doctorName, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            if (description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.attachment, size: 14, color: AppColors.grey), const SizedBox(width: 4), Text('${attachments.length} ${_t('مرفق')}', style: const TextStyle(fontSize: 10, color: AppColors.grey)), const Spacer(), IconButton(icon: const Icon(Icons.share, size: 18, color: AppColors.primary), onPressed: () => _shareRecord(data)), IconButton(icon: const Icon(Icons.download, size: 18, color: AppColors.primary), onPressed: () => _openFirstAttachment(attachments))]),
          ],
        ),
      ),
    );
  }

  Future<void> _shareRecord(Map<String, dynamic> data) async {
    final title = _localizedField(data, 'title', fallback: _t('ملف طبي'));
    final doctorName = _localizedField(data, 'doctorName');
    final description = _localizedField(data, 'description');
    final content = [title, doctorName, description].where((value) => value.isNotEmpty).join('\n');
    await Share.share(content, subject: _t('ملف طبي من صحتك'));
  }

  Future<void> _openFirstAttachment(List<dynamic> attachments) async {
    if (attachments.isEmpty) { ToastService.showInfo(_t('لا يوجد مرفق لهذا الملف')); return; }
    final uri = Uri.tryParse('${attachments.first}');
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) { ToastService.showWarning(_t('المرفق لا يحتوي على رابط صالح')); return; }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) ToastService.showError(_t('تعذر فتح المرفق'));
  }

  Future<void> _showAddRecordDialog(BuildContext context) async {
    final title = TextEditingController();
    final doctor = TextEditingController();
    final type = TextEditingController(text: 'تقارير');
    final desc = TextEditingController();
    bool saving = false;
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(_t('إضافة ملف طبي')),
          content: SingleChildScrollView(child: Column(children: [TextField(controller: title, decoration: InputDecoration(labelText: _t('العنوان'))), TextField(controller: doctor, decoration: InputDecoration(labelText: _t('اسم الطبيب'))), TextField(controller: type, decoration: InputDecoration(labelText: _t('النوع'))), TextField(controller: desc, maxLines: 3, decoration: InputDecoration(labelText: _t('الوصف')))])),
          actions: [TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext, false), child: Text(_t('إلغاء'))), ElevatedButton(onPressed: saving ? null : () async {
            if (title.text.trim().isEmpty) { ToastService.showWarning(_t('يرجى إدخال عنوان الملف')); return; }
            setDialogState(() => saving = true);
            try {
              final user = _auth.currentUser;
              if (user == null) throw Exception('unauthenticated');
              await _firestore.collection('medical_records').add({'patientId': user.uid, 'patientName': user.displayName ?? _t('مريض'), 'title': title.text.trim(), 'doctorName': doctor.text.trim(), 'type': type.text.trim(), 'description': desc.text.trim(), 'attachments': [], 'date': FieldValue.serverTimestamp(), 'createdAt': FieldValue.serverTimestamp()});
              if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              if (mounted) ToastService.showSuccess(_t('تمت إضافة الملف الطبي'));
            } catch (_) {
              if (dialogContext.mounted) setDialogState(() => saving = false);
              if (mounted) ToastService.showError(_t('تعذر حفظ الملف الطبي، حاول مرة أخرى'));
            }
          }, child: saving ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)) : Text(_t('حفظ')))],
        ));
        },
      );
      if (ok != true) return;
    } finally {
      title.dispose(); doctor.dispose(); type.dispose(); desc.dispose();
    }
  }
}
