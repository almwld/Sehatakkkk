import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/notification_service.dart';
import 'package:sehatak/core/utils/permission_helper.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> with WidgetsBindingObserver {
  final NotificationService _notifications = NotificationService();
  bool _pushEnabled = false;
  bool _emailEnabled = false;
  bool _appointmentsEnabled = true;
  bool _promotionsEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refreshPermission());
  }

  Future<void> _refreshPermission() async {
    final granted = await PermissionHelper.checkNotificationPermission();
    if (!mounted) return;
    setState(() {
      _pushEnabled = granted;
      _loading = false;
    });
  }

  Future<void> _setPushEnabled(bool enabled) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (enabled) {
        final granted = await _notifications.requestNotificationPermission();
        if (!granted) {
          if (mounted) {
            setState(() => _pushEnabled = false);
            await _showPermissionHelp();
          }
          return;
        }
      }
      if (mounted) setState(() => _pushEnabled = enabled);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showPermissionHelp() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإشعارات غير مفعلة'),
        content: const Text('لضمان وصول الرسائل والمكالمات والتنبيهات المهمة، فعّل إشعارات تطبيق صحتك من إعدادات النظام.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لاحقاً')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionHelper.openAppSettings();
            },
            child: const Text('فتح إعدادات التطبيق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'إعدادات الإشعارات', backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(_pushEnabled ? Icons.notifications_active : Icons.notifications_off, color: _pushEnabled ? AppColors.primary : Colors.grey),
                    title: Text(_pushEnabled ? 'خدمة التنبيهات تعمل' : 'خدمة التنبيهات متوقفة'),
                    subtitle: Text(_pushEnabled ? 'الرسائل والمكالمات والتنبيهات الفورية جاهزة.' : 'اضغط على الإشعارات الفورية لتفعيلها.'),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSwitchTile(title: 'الإشعارات الفورية', subtitle: _pushEnabled ? 'مفعلة من إعدادات الجهاز' : 'موقوفة من إعدادات الجهاز', value: _pushEnabled, onChanged: _setPushEnabled, isDark: isDark),
                _buildSwitchTile(title: 'الإشعارات عبر البريد', subtitle: 'استلام إشعارات عبر البريد الإلكتروني', value: _emailEnabled, onChanged: (v) => setState(() => _emailEnabled = v), isDark: isDark),
                const Divider(),
                _buildSwitchTile(title: 'تذكير المواعيد', subtitle: 'تذكير بالمواعيد القادمة', value: _appointmentsEnabled, onChanged: (v) => setState(() => _appointmentsEnabled = v), isDark: isDark),
                _buildSwitchTile(title: 'العروض والتخفيضات', subtitle: 'إشعارات العروض والتخفيضات', value: _promotionsEnabled, onChanged: (v) => setState(() => _promotionsEnabled = v), isDark: isDark),
                const Divider(),
                _buildSwitchTile(title: 'صوت الإشعارات', subtitle: 'تشغيل صوت عند الإشعارات', value: _soundEnabled, onChanged: (v) => setState(() => _soundEnabled = v), isDark: isDark),
                _buildSwitchTile(title: 'الاهتزاز', subtitle: 'تشغيل الاهتزاز عند الإشعارات', value: _vibrationEnabled, onChanged: (v) => setState(() => _vibrationEnabled = v), isDark: isDark),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged, required bool isDark}) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
      value: value,
      onChanged: _busy ? null : onChanged,
      activeColor: AppColors.primary,
    );
  }
}
