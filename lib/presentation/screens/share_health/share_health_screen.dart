import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class ShareHealthScreen extends StatefulWidget {
  const ShareHealthScreen({super.key});

  @override
  State<ShareHealthScreen> createState() => _ShareHealthScreenState();
}

class _ShareHealthScreenState extends State<ShareHealthScreen> {
  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _shareWithDoctor = false;
  bool _shareWithFamily = false;
  bool _shareWithHospital = false;
  bool _shareAnonymous = false;

  String _selectedDoctor = '';
  String _selectedFamily = '';
  String _selectedHospital = '';
  String _shareNotes = '';

  List<Map<String, String>> _doctors = [];
  List<Map<String, String>> _familyMembers = [];
  List<Map<String, String>> _hospitals = [];

  Map<String, dynamic> _patientData = {};
  List<Map<String, dynamic>> _medicalRecords = [];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _patientData = data;
            _medicalRecords = List<Map<String, dynamic>>.from(data['medicalRecords'] ?? []);
          });
        }
      } catch (e) {
        print('❌ Error loading patient data: $e');
      }
    }

    try {
      final results = await Future.wait([
        _firestore.collection('doctors').limit(50).get(),
        _firestore.collection('family_members').limit(50).get(),
        _firestore.collection('hospitals').limit(50).get(),
      ]);
      if (mounted) {
        setState(() {
          _doctors = results[0].docs.map((d) => {
                'id': d.id,
                'name': (d.data()['name'] ?? d.data()['displayName'] ?? 'طبيب').toString(),
              }).toList();
          _familyMembers = results[1].docs.map((d) => {
                'id': d.id,
                'name': (d.data()['name'] ?? d.data()['displayName'] ?? 'فرد من العائلة').toString(),
              }).toList();
          _hospitals = results[2].docs.map((d) => {
                'id': d.id,
                'name': (d.data()['name'] ?? d.data()['displayName'] ?? 'مستشفى').toString(),
              }).toList();
        });
      }
    } catch (_) {
      // عدم وجود بيانات حقيقية يبقي القوائم فارغة.
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _shareHealthData() {
    final List<String> shareTargets = [];

    if (_shareWithDoctor && _selectedDoctor.isNotEmpty) {
      shareTargets.add('👨‍⚕️ ${_t(context, 'الطبيب:')} $_selectedDoctor');
    }
    if (_shareWithFamily && _selectedFamily.isNotEmpty) {
      shareTargets.add('👨‍👩‍👧‍👦 ${_t(context, 'العائلة:')} $_selectedFamily');
    }
    if (_shareWithHospital && _selectedHospital.isNotEmpty) {
      shareTargets.add('🏥 ${_t(context, 'المستشفى:')} $_selectedHospital');
    }

    if (shareTargets.isEmpty) {
      ToastService.showError(context, _t(context, 'يرجى اختيار جهة مشاركة واحدة على الأقل'));
      return;
    }

    final shareText = '''
📋 ${_t(context, 'المشاركة الصحية - صحتك')}
━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 ${_t(context, 'المريض:')} ${_patientData['name'] ?? _t(context, 'مستخدم')}
📧 ${_t(context, 'البريد:')} ${_patientData['email'] ?? _t(context, 'غير متوفر')}
📱 ${_t(context, 'الهاتف:')} ${_patientData['phone'] ?? _t(context, 'غير متوفر')}

📊 ${_t(context, 'المؤشرات الحيوية:')}
• ${_t(context, 'ضغط الدم:')} ${_patientData['bloodPressure'] ?? '--'}
• ${_t(context, 'السكر:')} ${_patientData['glucose'] ?? '--'} mg/dL
• ${_t(context, 'الوزن:')} ${_patientData['weight'] ?? '--'} ${_t(context, 'كجم')}
• ${_t(context, 'فصيلة الدم:')} ${_patientData['bloodType'] ?? _t(context, 'غير محدد')}

📋 ${_t(context, 'السجل الطبي:')}
${_medicalRecords.isEmpty ? _t(context, 'لا توجد سجلات طبية') : _medicalRecords.map((r) => '• ${r['title'] ?? _t(context, 'تقرير')} - ${r['date'] ?? ''}').join('\n')}

${_shareNotes.isNotEmpty ? '\n📝 ${_t(context, 'ملاحظات:')}\n$_shareNotes' : ''}

━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 ${_t(context, 'تمت المشاركة عبر تطبيق صحتك')}
${shareTargets.join('\n')}
''';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: Text(_t(context, 'مشاركة الملف الصحي'), style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareHealthData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ ملخص الملف الصحي
                  _buildHealthSummary(context, isDark),
                  const SizedBox(height: 20),
                  // ✅ خيارات المشاركة
                  _buildShareOptions(context, isDark),
                  const SizedBox(height: 20),
                  // ✅ ملاحظات
                  _buildNotesField(context, isDark),
                  const SizedBox(height: 20),
                  // ✅ زر المشاركة
                  _buildShareButton(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthSummary(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(context, 'ملخص الملف الصحي'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _infoRow(context, Icons.person_rounded, 'الاسم', _patientData['name'] ?? _t(context, 'مستخدم')),
          _infoRow(context, Icons.email_rounded, 'البريد', _patientData['email'] ?? _t(context, 'غير متوفر')),
          _infoRow(context, Icons.phone_rounded, 'الهاتف', _patientData['phone'] ?? _t(context, 'غير متوفر')),
          _infoRow(context, Icons.monitor_heart_rounded, 'ضغط الدم', _patientData['bloodPressure'] ?? '--'),
          _infoRow(context, Icons.biotech_rounded, 'السكر', _patientData['glucose'] != null ? '${_patientData['glucose']} mg/dL' : '--'),
          _infoRow(context, Icons.monitor_weight_rounded, 'الوزن', _patientData['weight'] != null ? '${_patientData['weight']} ${_t(context, 'كجم')}' : '--'),
          _infoRow(context, Icons.bloodtype_rounded, 'فصيلة الدم', _patientData['bloodType'] ?? _t(context, 'غير محدد')),
          _infoRow(context, Icons.description_rounded, 'السجلات الطبية', '${_medicalRecords.length} ${_t(context, 'سجل')}'),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '${_t(context, label)}: ',
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOptions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(context, 'اختر جهة المشاركة'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // ✅ مشاركة مع طبيب
          _buildShareOption(
            icon: Icons.medical_services_rounded,
            title: _t(context, 'مشاركة مع طبيب'),
            value: _shareWithDoctor,
            onChanged: (value) {
              setState(() => _shareWithDoctor = value);
              if (!value) setState(() => _selectedDoctor = '');
            },
            child: _shareWithDoctor
                ? _buildDropdown(
                    context: context,
                    value: _selectedDoctor,
                    items: _doctors,
                    onChanged: (value) => setState(() => _selectedDoctor = value!),
                    hint: _t(context, 'اختر الطبيب'),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          // ✅ مشاركة مع العائلة
          _buildShareOption(
            icon: Icons.family_restroom_rounded,
            title: _t(context, 'مشاركة مع العائلة'),
            value: _shareWithFamily,
            onChanged: (value) {
              setState(() => _shareWithFamily = value);
              if (!value) setState(() => _selectedFamily = '');
            },
            child: _shareWithFamily
                ? _buildDropdown(
                    context: context,
                    value: _selectedFamily,
                    items: _familyMembers,
                    onChanged: (value) => setState(() => _selectedFamily = value!),
                    hint: _t(context, 'اختر فرد العائلة'),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          // ✅ مشاركة مع مستشفى
          _buildShareOption(
            icon: Icons.local_hospital_rounded,
            title: _t(context, 'مشاركة مع مستشفى'),
            value: _shareWithHospital,
            onChanged: (value) {
              setState(() => _shareWithHospital = value);
              if (!value) setState(() => _selectedHospital = '');
            },
            child: _shareWithHospital
                ? _buildDropdown(
                    context: context,
                    value: _selectedHospital,
                    items: _hospitals,
                    onChanged: (value) => setState(() => _selectedHospital = value!),
                    hint: _t(context, 'اختر المستشفى'),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          // ✅ مشاركة مجهولة
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _t(context, 'مشاركة مجهولة'),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            subtitle: Text(
              _t(context, 'إخفاء الاسم والمعلومات الشخصية'),
              style: TextStyle(fontSize: 11, color: AppColors.grey),
            ),
            value: _shareAnonymous,
            onChanged: (value) => setState(() => _shareAnonymous = value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        if (child != null) Padding(
          padding: const EdgeInsets.only(left: 40, top: 4),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value.isNotEmpty ? value : null,
        hint: Text(_t(context, hint), style: const TextStyle(fontSize: 12)),
        isExpanded: true,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'],
            child: Text(item['name'] ?? '', style: const TextStyle(fontSize: 12)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNotesField(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t(context, 'ملاحظات (اختياري)'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _shareNotes),
            onChanged: (value) => _shareNotes = value,
            maxLines: 3,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: _t(context, 'أضف ملاحظاتك هنا...'),
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _shareHealthData,
        icon: const Icon(Icons.share_rounded),
        label: Text(
          _t(context, 'مشاركة الملف الصحي'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
