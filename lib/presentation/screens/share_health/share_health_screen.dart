import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ShareHealthScreen extends StatefulWidget {
  const ShareHealthScreen({super.key});

  @override
  State<ShareHealthScreen> createState() => _ShareHealthScreenState();
}

class _ShareHealthScreenState extends State<ShareHealthScreen> {
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

  final List<Map<String, String>> _doctors = [
    {'id': '1', 'name': 'د. أحمد المولد'},
    {'id': '2', 'name': 'د. فاطمة صديقي'},
    {'id': '3', 'name': 'د. خالد النخلاني'},
  ];

  final List<Map<String, String>> _familyMembers = [
    {'id': '1', 'name': 'أم محمد'},
    {'id': '2', 'name': 'أبو محمد'},
    {'id': '3', 'name': 'سارة محمد'},
  ];

  final List<Map<String, String>> _hospitals = [
    {'id': '1', 'name': 'مستشفى الثورة العام'},
    {'id': '2', 'name': 'مستشفى المتحدون التخصصي'},
    {'id': '3', 'name': 'مستشفى الأطفال التخصصي'},
  ];

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

    setState(() => _isLoading = false);
  }

  void _shareHealthData() {
    final List<String> shareTargets = [];

    if (_shareWithDoctor && _selectedDoctor.isNotEmpty) {
      shareTargets.add('👨‍⚕️ الطبيب: $_selectedDoctor');
    }
    if (_shareWithFamily && _selectedFamily.isNotEmpty) {
      shareTargets.add('👨‍👩‍👧‍👦 العائلة: $_selectedFamily');
    }
    if (_shareWithHospital && _selectedHospital.isNotEmpty) {
      shareTargets.add('🏥 المستشفى: $_selectedHospital');
    }

    if (shareTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى اختيار جهة مشاركة واحدة على الأقل'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final shareText = '''
📋 المشاركة الصحية - صحتك
━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 المريض: ${_patientData['name'] ?? 'مستخدم'}
📧 البريد: ${_patientData['email'] ?? 'غير متوفر'}
📱 الهاتف: ${_patientData['phone'] ?? 'غير متوفر'}

📊 المؤشرات الحيوية:
• ضغط الدم: ${_patientData['bloodPressure'] ?? '--'}
• السكر: ${_patientData['glucose'] ?? '--'} mg/dL
• الوزن: ${_patientData['weight'] ?? '--'} كجم
• فصيلة الدم: ${_patientData['bloodType'] ?? 'غير محدد'}

📋 السجل الطبي:
${_medicalRecords.isEmpty ? 'لا توجد سجلات طبية' : _medicalRecords.map((r) => '• ${r['title'] ?? 'تقرير'} - ${r['date'] ?? ''}').join('\n')}

${_shareNotes.isNotEmpty ? '\n📝 ملاحظات:\n$_shareNotes' : ''}

━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 تم المشاركة عبر تطبيق صحتك
${shareTargets.join('\n')}
''';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('مشاركة الملف الصحي', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  _buildHealthSummary(isDark),
                  const SizedBox(height: 20),
                  // ✅ خيارات المشاركة
                  _buildShareOptions(isDark),
                  const SizedBox(height: 20),
                  // ✅ ملاحظات
                  _buildNotesField(isDark),
                  const SizedBox(height: 20),
                  // ✅ زر المشاركة
                  _buildShareButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthSummary(bool isDark) {
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
          const Text(
            'ملخص الملف الصحي',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.person_rounded, 'الاسم', _patientData['name'] ?? 'مستخدم'),
          _infoRow(Icons.email_rounded, 'البريد', _patientData['email'] ?? 'غير متوفر'),
          _infoRow(Icons.phone_rounded, 'الهاتف', _patientData['phone'] ?? 'غير متوفر'),
          _infoRow(Icons.monitor_heart_rounded, 'ضغط الدم', _patientData['bloodPressure'] ?? '--'),
          _infoRow(Icons.biotech_rounded, 'السكر', _patientData['glucose'] != null ? '${_patientData['glucose']} mg/dL' : '--'),
          _infoRow(Icons.monitor_weight_rounded, 'الوزن', _patientData['weight'] != null ? '${_patientData['weight']} كجم' : '--'),
          _infoRow(Icons.bloodtype_rounded, 'فصيلة الدم', _patientData['bloodType'] ?? 'غير محدد'),
          _infoRow(Icons.description_rounded, 'السجلات الطبية', '${_medicalRecords.length} سجل'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
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

  Widget _buildShareOptions(bool isDark) {
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
          const Text(
            'اختر جهة المشاركة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // ✅ مشاركة مع طبيب
          _buildShareOption(
            icon: Icons.medical_services_rounded,
            title: 'مشاركة مع طبيب',
            value: _shareWithDoctor,
            onChanged: (value) {
              setState(() => _shareWithDoctor = value);
              if (!value) setState(() => _selectedDoctor = '');
            },
            child: _shareWithDoctor
                ? _buildDropdown(
                    value: _selectedDoctor,
                    items: _doctors,
                    onChanged: (value) => setState(() => _selectedDoctor = value!),
                    hint: 'اختر الطبيب',
                  )
                : null,
          ),
          const SizedBox(height: 12),
          // ✅ مشاركة مع العائلة
          _buildShareOption(
            icon: Icons.family_restroom_rounded,
            title: 'مشاركة مع العائلة',
            value: _shareWithFamily,
            onChanged: (value) {
              setState(() => _shareWithFamily = value);
              if (!value) setState(() => _selectedFamily = '');
            },
            child: _shareWithFamily
                ? _buildDropdown(
                    value: _selectedFamily,
                    items: _familyMembers,
                    onChanged: (value) => setState(() => _selectedFamily = value!),
                    hint: 'اختر فرد العائلة',
                  )
                : null,
          ),
          const SizedBox(height: 12),
          // ✅ مشاركة مع مستشفى
          _buildShareOption(
            icon: Icons.local_hospital_rounded,
            title: 'مشاركة مع مستشفى',
            value: _shareWithHospital,
            onChanged: (value) {
              setState(() => _shareWithHospital = value);
              if (!value) setState(() => _selectedHospital = '');
            },
            child: _shareWithHospital
                ? _buildDropdown(
                    value: _selectedHospital,
                    items: _hospitals,
                    onChanged: (value) => setState(() => _selectedHospital = value!),
                    hint: 'اختر المستشفى',
                  )
                : null,
          ),
          const SizedBox(height: 8),
          // ✅ مشاركة مجهولة
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'مشاركة مجهولة',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            subtitle: const Text(
              'إخفاء الاسم والمعلومات الشخصية',
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
        hint: Text(hint, style: const TextStyle(fontSize: 12)),
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

  Widget _buildNotesField(bool isDark) {
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
          const Text(
            'ملاحظات (اختياري)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: _shareNotes),
            onChanged: (value) => _shareNotes = value,
            maxLines: 3,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'أضف ملاحظاتك هنا...',
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

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _shareHealthData,
        icon: const Icon(Icons.share_rounded),
        label: const Text(
          'مشاركة الملف الصحي',
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
