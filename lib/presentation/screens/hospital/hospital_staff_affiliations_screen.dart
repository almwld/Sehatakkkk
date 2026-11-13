import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class HospitalStaffAffiliationsScreen extends StatefulWidget {
  const HospitalStaffAffiliationsScreen({super.key});
  @override
  State<HospitalStaffAffiliationsScreen> createState() => _HospitalStaffAffiliationsScreenState();
}

class _HospitalStaffAffiliationsScreenState extends State<HospitalStaffAffiliationsScreen> {
  final _db = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  bool _loadingRole = true, _isHospital = false, _busy = false;
  String _t(String value) => AppStrings.of(context).translate(value);

  @override
  void initState() { super.initState(); _loadRole(); }

  Future<void> _loadRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { if (mounted) setState(() => _loadingRole = false); return; }
    try {
      final user = await _db.collection('users').doc(uid).get();
      if (mounted) setState(() { _isHospital = user.data()?['role'] == 'hospital'; _loadingRole = false; });
    } catch (_) { if (mounted) setState(() => _loadingRole = false); }
  }

  Future<void> _invite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final staffId = TextEditingController(), jobTitle = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var selectedDepartmentId = '';
    List<QueryDocumentSnapshot<Map<String, dynamic>>> departments = [];
    try {
      final result = await _db.collection('hospital_departments')
          .where('hospitalId', isEqualTo: uid)
          .where('isActive', isEqualTo: true).get();
      departments = result.docs;
    } catch (_) {
      // Department selection is optional; invitation can still be sent.
    }
    final accepted = await showDialog<bool>(context: context, builder: (dialogContext) =>
      StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(_t('دعوة ممارس صحي')),
        content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: staffId, decoration: InputDecoration(labelText: _t('معرّف حساب الممارس')),
            validator: (v) => v == null || v.trim().isEmpty ? _t('هذا الحقل مطلوب') : null),
          TextFormField(controller: jobTitle, decoration: InputDecoration(labelText: _t('المسمى الوظيفي')),
            validator: (v) => v == null || v.trim().isEmpty ? _t('هذا الحقل مطلوب') : null),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedDepartmentId,
            decoration: InputDecoration(labelText: _t('القسم الطبي')),
            items: [
              DropdownMenuItem<String>(value: '', child: Text(_t('بدون قسم محدد'))),
              ...departments.map((doc) => DropdownMenuItem<String>(
                value: doc.id, child: Text(doc.data()['name']?.toString() ?? _t('قسم طبي')),
              )),
            ],
            onChanged: (value) => setDialogState(() => selectedDepartmentId = value ?? ''),
          ),
          const SizedBox(height: 8),
          Text(_t('يجب أن يكون الحساب موثقاً. ستصل الدعوة إلى صاحب الحساب ليوافق عليها بنفسه.'),
            style: Theme.of(context).textTheme.bodySmall),
        ]))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(_t('إلغاء'))),
          FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true); },
            child: Text(_t('إرسال الدعوة'))),
        ],
      )),
    );
    if (accepted == true) {
      await _runAction(() async {
        await _functions.httpsCallable('createHospitalStaffInvitation').call({
          'staffId': staffId.text.trim(), 'jobTitle': jobTitle.text.trim(),
          'departmentId': selectedDepartmentId, 'isPublic': true,
        });
      }, _t('تم إرسال الدعوة للممارس'));
    }
    staffId.dispose(); jobTitle.dispose();
  }

  Future<void> _respond(String invitationId, String decision) async {
    await _runAction(() async {
      await _functions.httpsCallable('respondHospitalStaffInvitation').call({
        'invitationId': invitationId, 'decision': decision,
      });
    }, decision == 'accept' ? _t('تم قبول الانتساب') : _t('تم رفض الدعوة'));
  }

  Future<void> _end(String hospitalId, String staffId) async {
    final confirm = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(_t('إنهاء الانتساب')),
      content: Text(_t('سيتم إخفاء هذا الارتباط من دليل كادر المستشفى.')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(_t('إلغاء'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(_t('إنهاء'))),
      ],
    ));
    if (confirm != true) return;
    await _runAction(() async {
      await _functions.httpsCallable('endHospitalStaffAffiliation').call({
        'hospitalId': hospitalId, 'staffId': staffId,
      });
    }, _t('تم إنهاء الانتساب'));
  }

  Future<void> _runAction(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
    } on FirebaseFunctionsException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? _t('تعذر تنفيذ العملية'))));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('تعذر تنفيذ العملية'))));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_loadingRole) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (uid == null) return Scaffold(body: Center(child: Text(_t('يجب تسجيل الدخول'))));
    return Scaffold(
      appBar: AppBar(title: Text(_t('الانتسابات المهنية')), backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [if (_isHospital) IconButton(tooltip: _t('دعوة ممارس صحي'),
          onPressed: _busy ? null : _invite, icon: const Icon(Icons.person_add_alt_1))]),
      body: _isHospital ? _hospitalLinks(uid) : _professionalLinks(uid),
    );
  }

  Widget _hospitalLinks(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('hospital_staff_links').where('hospitalId', isEqualTo: uid)
        .where('status', isEqualTo: 'active').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text(_t('تعذر تحميل الكادر')));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView(padding: const EdgeInsets.all(16), children: [
          _intro(_t('الكادر المرتبط بالمستشفى'), _t('لا يظهر أي ممارس في الدليل العام إلا بعد موافقته على الدعوة وتوثيق حسابه.')),
          Align(alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(onPressed: _busy ? null : _invite,
              icon: const Icon(Icons.add), label: Text(_t('إضافة كادر عبر دعوة')))),
          const SizedBox(height: 12),
          if (docs.isEmpty) _empty(_t('لا توجد انتسابات نشطة حالياً')),
          ...docs.map((doc) {
            final data = doc.data(), staffId = doc.data()['staffId']?.toString() ?? '';
            return Card(child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.medical_services_outlined)),
              title: Text(data['jobTitle']?.toString() ?? _t('ممارس صحي')),
              subtitle: Text((data['staffRole'] ?? '').toString() + ' • ' + (data['departmentName'] ?? '').toString() + '\n' + staffId),
              isThreeLine: true,
              trailing: IconButton(tooltip: _t('إنهاء الانتساب'),
                onPressed: _busy ? null : () => _end(uid, staffId),
                icon: const Icon(Icons.link_off, color: Colors.redAccent)),
            ));
          }),
        ]);
      },
    );
  }

  Widget _professionalLinks(String uid) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _intro(_t('دعوات الانتساب'), _t('راجع دعوات المستشفيات ووافق فقط على الانتسابات التي تخصك.')),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('hospital_staff_invitations').where('staffId', isEqualTo: uid)
          .where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(_t('تعذر تحميل الدعوات'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return _empty(_t('لا توجد دعوات معلقة'));
          return Column(children: snapshot.data!.docs.map((doc) {
            final data = doc.data();
            return Card(child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.local_hospital_outlined)),
              title: Text((data['hospitalName'] ?? '').toString().isNotEmpty ? data['hospitalName'].toString() : _t('مستشفى')),
              subtitle: Text((data['jobTitle'] ?? '').toString() + '\n' + (data['hospitalId'] ?? '').toString()),
              isThreeLine: true,
              trailing: Wrap(spacing: 2, children: [
                IconButton(tooltip: _t('قبول'), onPressed: _busy ? null : () => _respond(doc.id, 'accept'),
                  icon: const Icon(Icons.check_circle, color: Colors.green)),
                IconButton(tooltip: _t('رفض'), onPressed: _busy ? null : () => _respond(doc.id, 'reject'),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent)),
              ]),
            ));
          }).toList());
        },
      ),
      const SizedBox(height: 22),
      Text(_t('انتساباتي النشطة'), style: Theme.of(context).textTheme.titleMedium),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('hospital_staff_links').where('staffId', isEqualTo: uid)
          .where('status', isEqualTo: 'active').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(_t('تعذر تحميل الانتسابات'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return _empty(_t('لا توجد انتسابات نشطة'));
          return Column(children: snapshot.data!.docs.map((doc) {
            final data = doc.data(), hospitalId = doc.data()['hospitalId']?.toString() ?? '';
            return Card(child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.apartment)),
              title: Text((data['hospitalName'] ?? _t('مستشفى')).toString()),
              subtitle: Text((data['jobTitle'] ?? '').toString() + '\n' + hospitalId),
              isThreeLine: true,
              trailing: IconButton(tooltip: _t('إنهاء الانتساب'),
                onPressed: _busy ? null : () => _end(hospitalId, uid),
                icon: const Icon(Icons.link_off, color: Colors.redAccent)),
            ));
          }).toList());
        },
      ),
    ]);
  }

  Widget _intro(String title, String subtitle) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5), Text(subtitle),
    ]),
  );

  Widget _empty(String value) => Padding(
    padding: const EdgeInsets.all(24), child: Center(child: Text(value, textAlign: TextAlign.center)),
  );
}
