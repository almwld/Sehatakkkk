import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});
  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _location = true;
  bool _camera = true;
  bool _microphone = false;
  bool _notifications = true;
  bool _contacts = false;
  bool _storage = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _location = p.getBool('perm_location') ?? true;
      _camera = p.getBool('perm_camera') ?? true;
      _microphone = p.getBool('perm_microphone') ?? false;
      _notifications = p.getBool('perm_notifications') ?? true;
      _contacts = p.getBool('perm_contacts') ?? false;
      _storage = p.getBool('perm_storage') ?? true;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final p = await SharedPreferences.getInstance();
      await Future.wait([
        p.setBool('perm_location', _location), p.setBool('perm_camera', _camera),
        p.setBool('perm_microphone', _microphone), p.setBool('perm_notifications', _notifications),
        p.setBool('perm_contacts', _contacts), p.setBool('perm_storage', _storage),
      ]);
      if (mounted) ToastService.showSuccess('تم حفظ إعدادات الأذونات');
    } catch (e) {
      if (mounted) ToastService.showError('تعذر حفظ إعدادات الأذونات');
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: const Text('الأذونات', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withOpacity(0.2))),
            child: const Row(children: [Icon(Icons.info, color: AppColors.warning), SizedBox(width: 8), Expanded(child: Text('تحكم في الأذونات التي تمنحها للتطبيق. بعض الميزات قد لا تعمل بدون الأذونات الضرورية.', style: TextStyle(fontSize: 11, color: AppColors.darkGrey)))]),
          ),
          const SizedBox(height: 16),
          _permissionCard(Icons.location_on, 'الموقع الجغرافي', 'للعثور على أقرب مستشفى وصيدلية', _location, true, (v) => setState(() => _location = v)),
          _permissionCard(Icons.camera_alt, 'الكاميرا', 'لالتقاط صور الوصفات والتقارير الطبية', _camera, false, (v) => setState(() => _camera = v)),
          _permissionCard(Icons.mic, 'الميكروفون', 'للبحث الصوتي والتسجيل', _microphone, false, (v) => setState(() => _microphone = v)),
          _permissionCard(Icons.notifications_active, 'الإشعارات', 'للتذكير بالمواعيد والأدوية', _notifications, true, (v) => setState(() => _notifications = v)),
          _permissionCard(Icons.contacts, 'جهات الاتصال', 'لإضافة جهات اتصال الطوارئ', _contacts, false, (v) => setState(() => _contacts = v)),
          _permissionCard(Icons.storage, 'التخزين', 'لحفظ التقارير والملفات', _storage, false, (v) => setState(() => _storage = v)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)), child: _saving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('حفظ'))),
        ]),
      ),
    );
  }

  Widget _permissionCard(IconData icon, String title, String desc, bool value, bool required, Function(bool) onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)]),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? AppColors.primary : AppColors.grey, size: 24),
        title: Row(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), if (required) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('ضروري', style: TextStyle(fontSize: 8, color: AppColors.error)))]],),
        subtitle: Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
        value: value,
        activeColor: AppColors.primary,
        onChanged: required ? null : onChange,
      ),
    );
  }
}
