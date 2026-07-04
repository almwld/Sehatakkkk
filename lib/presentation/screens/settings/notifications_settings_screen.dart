import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _appointmentsEnabled = true;
  bool _promotionsEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
        backgroundColor: const Color(0xFF0D5257),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitchTile(
            title: 'الإشعارات الفورية',
            subtitle: 'استلام إشعارات فورية من التطبيق',
            value: _pushEnabled,
            onChanged: (v) => setState(() => _pushEnabled = v),
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: 'الإشعارات عبر البريد',
            subtitle: 'استلام إشعارات عبر البريد الإلكتروني',
            value: _emailEnabled,
            onChanged: (v) => setState(() => _emailEnabled = v),
            isDark: isDark,
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'تذكير المواعيد',
            subtitle: 'تذكير بالمواعيد القادمة',
            value: _appointmentsEnabled,
            onChanged: (v) => setState(() => _appointmentsEnabled = v),
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: 'العروض والتخفيضات',
            subtitle: 'إشعارات العروض والتخفيضات',
            value: _promotionsEnabled,
            onChanged: (v) => setState(() => _promotionsEnabled = v),
            isDark: isDark,
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'صوت الإشعارات',
            subtitle: 'تشغيل صوت عند الإشعارات',
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
            isDark: isDark,
          ),
          _buildSwitchTile(
            title: 'الاهتزاز',
            subtitle: 'تشغيل الاهتزاز عند الإشعارات',
            value: _vibrationEnabled,
            onChanged: (v) => setState(() => _vibrationEnabled = v),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0D5257),
    );
  }
}
