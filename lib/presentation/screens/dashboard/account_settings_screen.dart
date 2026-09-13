import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String _role = 'user';
  String _name = 'المستخدم';
  bool _loading = true;

  static const Map<String, String> _roleNames = {
    'user': 'المستخدم',
    'doctor': 'الطبيب',
    'nurse': 'الممرض',
    'midwife': 'القابلة',
    'physiotherapist': 'أخصائي العلاج الطبيعي',
    'pharmacist': 'الصيدلي',
    'lab': 'المختبر',
    'paramedic': 'المسعف الميداني',
    'delivery': 'مندوب التوصيل',
    'service': 'مقدم الخدمة',
    'veterinarian': 'الطبيب البيطري',
    'admin': 'مدير النظام',
    'superAdmin': 'المدير العام',
  };

  static const Map<String, List<String>> _roleServices = {
    'user': ['الملف الصحي', 'المواعيد', 'الوصفات والأدوية', 'السجلات الطبية', 'المحفظة'],
    'doctor': ['إدارة المواعيد', 'الاستشارات', 'السجلات الطبية المصرح بها', 'مجتمع صحتك', 'المحفظة'],
    'nurse': ['إدارة خدمات التمريض', 'المواعيد', 'متابعة المرضى', 'التواصل الصحي'],
    'midwife': ['إدارة خدمات القبالة', 'متابعة الحالات', 'المواعيد', 'التواصل الصحي'],
    'physiotherapist': ['إدارة جلسات العلاج الطبيعي', 'المواعيد', 'متابعة الحالات', 'التواصل الصحي'],
    'pharmacist': ['إدارة الصيدلية', 'المنتجات والمخزون', 'الطلبات', 'المحفظة'],
    'lab': ['إدارة خدمات المختبر', 'طلبات الفحوصات', 'النتائج', 'المواعيد'],
    'paramedic': ['إدارة خدمات الإسعاف', 'الطلبات الطارئة', 'التواصل الصحي'],
    'delivery': ['إدارة التوصيل', 'الطلبات', 'المهام الحالية', 'المحفظة'],
    'service': ['إدارة الخدمات', 'الطلبات', 'المواعيد', 'المحفظة'],
    'veterinarian': ['إدارة خدمات الطب البيطري', 'المواعيد', 'السجلات', 'التواصل الصحي'],
    'admin': ['إدارة المستخدمين', 'إدارة مقدمي الخدمات', 'الإعلانات', 'مراقبة المنصة'],
    'superAdmin': ['إدارة المنصة', 'إدارة الصلاحيات', 'مراجعة مقدمي الخدمات', 'الإعدادات العامة'],
  };

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snapshot.data() ?? <String, dynamic>{};
      final role = (data['role'] ?? 'user').toString();
      if (!mounted) return;
      setState(() {
        _role = role;
        _name = (data['name'] ?? user.displayName ?? _roleNames[role] ?? 'المستخدم').toString();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _roleName => _roleNames[_role] ?? _role;
  List<String> get _services => _roleServices[_role] ?? _roleServices['user']!;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات $_roleName'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.manage_accounts, color: AppColors.primary, size: 34),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(_roleName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('إدارة الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _item(context, Icons.person_outline, 'الملف الشخصي', 'تعديل بيانات الحساب والملف الشخصي', AppRouter.profile),
                _item(context, Icons.tune, 'التفضيلات', 'اللغة والمظهر وخيارات الاستخدام', AppRouter.settings),
                _item(context, Icons.notifications_none, 'الإشعارات', 'إدارة إشعارات الحساب والخدمات', AppRouter.notifications),
                _item(context, Icons.security_outlined, 'الخصوصية والأمان', 'خيارات الوصول وحماية الحساب', null),
                const SizedBox(height: 20),
                const Text('خدمات الدور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ..._services.map((service) => Card(
                      color: dark ? const Color(0xFF172033) : Colors.white,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0x1A0A8F83),
                          child: Icon(Icons.medical_services_outlined, color: AppColors.primary),
                        ),
                        title: Text(service, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('خدمة مرتبطة بحسابك حسب الدور المسجل'),
                        trailing: const Icon(Icons.chevron_left),
                      ),
                    )),
              ],
            ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String subtitle, String? route) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: route == null ? null : () => context.push(route),
      ),
    );
  }
}
