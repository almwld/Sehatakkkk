import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/saved_accounts_service.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String _deviceName = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceName();
  }

  Future<void> _loadDeviceName() async {
    try {
      final info = await _deviceInfo.androidInfo;
      if (!mounted) return;
      setState(() => _deviceName = '${info.manufacturer} ${info.model}'.trim());
    } catch (_) {}
  }

  Future<void> _signOutCurrentDevice() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await SavedAccountsService.saveCurrentAccount(user);
      }
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) ToastService.showError('${_t('تعذر تسجيل الخروج:')} $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOutAllDevices() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _t('تسجيل الخروج من جميع الأجهزة')),
        content: Text(
          _t('سيتم إبطال جلسات تسجيل الدخول الحالية على جميع الأجهزة، ثم تسجيل خروجك من هذا الجهاز أيضاً.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(
          _t('إلغاء'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(
          _t('متابعة'))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await SavedAccountsService.saveCurrentAccount(user);
      }
      await FirebaseFunctions.instance.httpsCallable('revokeAllSessions').call();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    } on FirebaseFunctionsException catch (e) {
      if (mounted) ToastService.showError('${_t('تعذر إبطال الجلسات:')} ${e.message ?? e.code}');
    } catch (e) {
      if (mounted) ToastService.showError('${_t('تعذر إبطال الجلسات:')} $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount() async {
    if (FirebaseAuth.instance.currentUser == null || _busy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _t('حذف الحساب نهائياً')),
        content: Text(
          _t('سيتم حذف حساب تسجيل الدخول وملف المستخدم من صحتك. هذا الإجراء لا يمكن التراجع عنه. هل تريد المتابعة؟'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(
          _t('إلغاء'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
          _t('حذف الحساب')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await FirebaseFunctions.instance.httpsCallable('deleteMyAccount').call();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    } on FirebaseFunctionsException catch (e) {
      if (mounted) ToastService.showError('${_t('تعذر حذف الحساب:')} ${e.message ?? e.code}');
    } catch (e) {
      if (mounted) ToastService.showError('${_t('تعذر حذف الحساب:')} $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF7F9FA),
      appBar: CustomAppBar(
        title: _t('الأمان والأجهزة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.phone_android, color: Colors.white),
              ),
              title: Text(_deviceName.isEmpty ? _t('الجهاز الحالي') : _deviceName),
              subtitle: Text(user?.email ?? _t('الحساب الحالي')),
              trailing: Chip(label: Text(_t('نشطة'))),
            ),
          ),
          const SizedBox(height: 16),
          Text(_t('الجلسات والأجهزة'), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.primary),
                  title: Text(
          _t('تسجيل الخروج من هذا الجهاز')),
                  subtitle: Text(
          _t('إنهاء جلسة التطبيق الحالية فقط')),
                  onTap: _busy ? null : _signOutCurrentDevice,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.devices, color: AppColors.primary),
                  title: Text(
          _t('تسجيل الخروج من جميع الأجهزة')),
                  subtitle: Text(
          _t('إبطال جلسات تسجيل الدخول الأخرى عبر Firebase')),
                  onTap: _busy ? null : _signOutAllDevices,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(_t('حذف الحساب'), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: Text(
          _t('حذف حسابي'), style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              subtitle: Text(
          _t('حذف حساب تسجيل الدخول وملف المستخدم نهائياً')),
              onTap: _busy ? null : _deleteAccount,
            ),
          ),
          const SizedBox(height: 16),
          Text(
          _t('تسجيل الخروج من جميع الأجهزة يلغي رموز الجلسات القابلة للتجديد من خادم Firebase.'),
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}