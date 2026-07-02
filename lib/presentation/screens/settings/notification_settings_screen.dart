import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // ✅ إعدادات الإشعارات
  bool _allNotifications = true;
  bool _appointments = true;
  bool _messages = true;
  bool _medicationReminders = true;
  bool _promotions = false;
  bool _sound = true;
  bool _vibration = true;
  bool _popup = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allNotifications = prefs.getBool('notif_all') ?? true;
      _appointments = prefs.getBool('notif_appointments') ?? true;
      _messages = prefs.getBool('notif_messages') ?? true;
      _medicationReminders = prefs.getBool('notif_medication') ?? true;
      _promotions = prefs.getBool('notif_promotions') ?? false;
      _sound = prefs.getBool('notif_sound') ?? true;
      _vibration = prefs.getBool('notif_vibration') ?? true;
      _popup = prefs.getBool('notif_popup') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_all', _allNotifications);
    await prefs.setBool('notif_appointments', _appointments);
    await prefs.setBool('notif_messages', _messages);
    await prefs.setBool('notif_medication', _medicationReminders);
    await prefs.setBool('notif_promotions', _promotions);
    await prefs.setBool('notif_sound', _sound);
    await prefs.setBool('notif_vibration', _vibration);
    await prefs.setBool('notif_popup', _popup);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم حفظ إعدادات الإشعارات'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إعدادات الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _saveSettings,
            tooltip: 'حفظ الإعدادات',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ جميع الإشعارات
          _buildSwitchTile(
            icon: Icons.notifications_rounded,
            title: 'جميع الإشعارات',
            subtitle: 'تفعيل أو تعطيل جميع الإشعارات',
            value: _allNotifications,
            onChanged: (value) {
              setState(() {
                _allNotifications = value;
                if (!value) {
                  _appointments = false;
                  _messages = false;
                  _medicationReminders = false;
                  _promotions = false;
                }
              });
            },
            isDark: isDark,
          ),

          const SizedBox(height: 8),

          // ✅ أنواع الإشعارات
          if (_allNotifications) ...[
            _buildSectionTitle('أنواع الإشعارات', isDark),
            const SizedBox(height: 8),

            _buildSwitchTile(
              icon: Icons.calendar_month_rounded,
              title: 'المواعيد',
              subtitle: 'إشعارات المواعيد والتذكيرات',
              value: _appointments,
              onChanged: (value) => setState(() => _appointments = value),
              isDark: isDark,
            ),

            _buildSwitchTile(
              icon: Icons.chat_rounded,
              title: 'الرسائل',
              subtitle: 'إشعارات الرسائل الجديدة',
              value: _messages,
              onChanged: (value) => setState(() => _messages = value),
              isDark: isDark,
            ),

            _buildSwitchTile(
              icon: Icons.medication_rounded,
              title: 'تذكير الأدوية',
              subtitle: 'تذكيرات مواعيد تناول الأدوية',
              value: _medicationReminders,
              onChanged: (value) => setState(() => _medicationReminders = value),
              isDark: isDark,
            ),

            _buildSwitchTile(
              icon: Icons.local_offer_rounded,
              title: 'العروض والخصومات',
              subtitle: 'إشعارات العروض والخصومات',
              value: _promotions,
              onChanged: (value) => setState(() => _promotions = value),
              isDark: isDark,
            ),
          ],

          const SizedBox(height: 16),

          // ✅ طريقة العرض
          _buildSectionTitle('طريقة العرض', isDark),
          const SizedBox(height: 8),

          _buildSwitchTile(
            icon: Icons.volume_up_rounded,
            title: 'الصوت',
            subtitle: 'تشغيل صوت الإشعارات',
            value: _sound,
            onChanged: (value) => setState(() => _sound = value),
            isDark: isDark,
          ),

          _buildSwitchTile(
            icon: Icons.vibration_rounded,
            title: 'الاهتزاز',
            subtitle: 'اهتزاز الجهاز عند الإشعارات',
            value: _vibration,
            onChanged: (value) => setState(() => _vibration = value),
            isDark: isDark,
          ),

          _buildSwitchTile(
            icon: Icons.popup_rounded,
            title: 'نوافذ منبثقة',
            subtitle: 'عرض الإشعارات كنوافذ منبثقة',
            value: _popup,
            onChanged: (value) => setState(() => _popup = value),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
