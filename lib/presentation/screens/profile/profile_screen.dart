import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_assets.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userRole = 'مستخدم';
  String _userImage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? <String, dynamic>{};
      if (mounted) {
        setState(() {
          _userData = data;
          _userName = data['name'] ?? user.displayName ?? 'مستخدم';
          _userEmail = data['email'] ?? user.email ?? '';
          _userPhone = data['phone'] ?? '';
          _userRole = data['role'] ?? 'مستخدم';
          _userImage = data['photoUrl'] ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _value(String key, String fallback) {
    final value = _userData[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'الملف الشخصي',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: LocalAssetIcon(AppAssets.settingsIcon, color: isDark ? Colors.white : Colors.black87, size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildUserAvatar(isDark),
                  const SizedBox(height: 16),
                  Text(_userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(_userEmail, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(_userRole, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(isDark),
                  const SizedBox(height: 16),
                  _buildMeasurementsCard(isDark),
                  const SizedBox(height: 16),
                  _buildActionButtons(isDark),
                  const SizedBox(height: 16),
                  _buildLogoutButton(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildUserAvatar(bool isDark) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: _userImage.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    _userImage,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialAvatar(),
                  ),
                )
              : _initialAvatar(),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0xFF0B1121) : Colors.white, width: 2)),
            child: LocalAssetIcon(AppAssets.cameraIcon, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _initialAvatar() {
    return Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'م', style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold));
  }

  Widget _buildInfoCard(bool isDark) {
    final infoItems = [
      {'icon': AppAssets.userIcon, 'label': 'الاسم', 'value': _userName, 'key': 'name', 'editable': true},
      {'icon': AppAssets.emailIcon, 'label': 'البريد الإلكتروني', 'value': _userEmail, 'key': 'email', 'editable': false},
      {'icon': AppAssets.phoneIcon, 'label': 'رقم الهاتف', 'value': _userPhone.isNotEmpty ? _userPhone : 'غير مضاف', 'key': 'phone', 'editable': true},
      {'icon': AppAssets.verifyIcon, 'label': 'الدور', 'value': _userRole, 'key': 'role', 'editable': false},
    ];
    return _card(isDark, child: Column(children: infoItems.map((item) => _buildInfoRow(isDark, icon: item['icon'] as String, label: item['label'] as String, value: item['value'] as String, editable: item['editable'] as bool, fieldKey: item['key'] as String)).toList()));
  }

  Widget _buildMeasurementsCard(bool isDark) {
    final items = [
      {'icon': AppAssets.heightIcon, 'label': 'الطول', 'value': _value('height', 'غير مضاف'), 'key': 'height', 'unit': 'سم'},
      {'icon': AppAssets.weightIcon, 'label': 'الوزن', 'value': _value('weight', 'غير مضاف'), 'key': 'weight', 'unit': 'كجم'},
      {'icon': AppAssets.calendarIcon, 'label': 'العمر', 'value': _value('age', 'غير مضاف'), 'key': 'age', 'unit': 'سنة'},
      {'icon': AppAssets.bloodPressureIcon, 'label': 'فصيلة الدم', 'value': _value('bloodType', 'غير محدد'), 'key': 'bloodType', 'unit': ''},
    ];
    return _card(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('القياسات والبيانات الصحية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 8),
      ...items.map((item) {
        final value = item['value'] as String;
        final unit = item['unit'] as String;
        final display = value == 'غير مضاف' || value == 'غير محدد' ? value : '$value $unit';
        return _buildInfoRow(isDark, icon: item['icon'] as String, label: item['label'] as String, value: display, editable: true, fieldKey: item['key'] as String);
      }),
    ]));
  }

  Widget _buildInfoRow(bool isDark, {required String icon, required String label, required String value, required bool editable, required String fieldKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: LocalAssetIcon(icon, color: AppColors.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
        ])),
        if (editable)
          IconButton(
            tooltip: 'تعديل $label',
            icon: LocalAssetIcon(AppAssets.editIcon, color: AppColors.primary, size: 18),
            onPressed: () => _showEditDialog(fieldKey, label, value),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ]),
    );
  }

  Widget _card(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: child,
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final actions = [
      {'icon': AppAssets.healthFileIcon, 'label': 'السجل الطبي'},
      {'icon': AppAssets.calendarIcon, 'label': 'مواعيدي'},
      {'icon': AppAssets.notificationBellIcon, 'label': 'الإشعارات'},
      {'icon': AppAssets.helpIcon, 'label': 'المساعدة'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () => ToastService.showSuccess('جاري فتح ${action['label']}...'),
          child: Container(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(action['icon'] as String, color: AppColors.primary, size: 24), const SizedBox(width: 8), Text(action['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87))]),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: LocalAssetIcon(AppAssets.logoutIcon, color: Colors.red, size: 20),
        label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontSize: 16)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Future<void> _showEditDialog(String fieldKey, String label, String currentValue) async {
    final initial = currentValue == 'غير مضاف' || currentValue == 'غير محدد' ? '' : currentValue.replaceAll(RegExp(r'\s*(سم|كجم|سنة)$'), '');
    final controller = TextEditingController(text: initial);
    final isNumeric = fieldKey == 'height' || fieldKey == 'weight' || fieldKey == 'age';
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('تعديل $label'),
        content: TextField(controller: controller, autofocus: true, keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, textAlign: TextAlign.right, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('حفظ')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    if (isNumeric && double.tryParse(value) == null) {
      ToastService.showError('يرجى إدخال قيمة رقمية صحيحة');
      return;
    }
    if (fieldKey == 'age' && (int.tryParse(value) == null || int.parse(value) < 0 || int.parse(value) > 150)) {
      ToastService.showError('يرجى إدخال عمر صحيح');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final firestoreValue = fieldKey == 'age' ? int.parse(value) : (isNumeric ? double.parse(value) : value);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({fieldKey: firestoreValue, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        _userData[fieldKey] = firestoreValue;
        if (fieldKey == 'name') _userName = value;
        if (fieldKey == 'phone') _userPhone = value;
      });
      if (fieldKey == 'name') {
        await user.updateDisplayName(value);
        await user.reload();
      }
      if (mounted) setState(() {});
      ToastService.showSuccess('تم تحديث $label وحفظه في الحساب');
    } catch (e) {
      ToastService.showError('فشل حفظ $label: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
