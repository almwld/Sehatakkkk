import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/sound_manager.dart';
import 'package:sehatak/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notification_settings_screen.dart';
import '../rate_app/rate_app_screen.dart';
import '../share_app/share_app_screen.dart';
import '../about/about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'ar';
  String _selectedFontSize = 'متوسط';

  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
  ];

  final List<String> _fontSizes = ['صغير', 'متوسط', 'كبير'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'ar';
      _selectedFontSize = prefs.getString('font_size') ?? 'متوسط';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('font_size', _selectedFontSize);

    if (!_soundEnabled) {
      SoundManager().stopAll();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showFCMToken() async {
    final token = await NotificationService().getToken();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SelectableText('🔑 $token'),
        duration: const Duration(seconds: 30),
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
          'الإعدادات',
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
          // ✅ المظهر
          _buildSection(
            title: 'المظهر',
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'الوضع المظلم',
                subtitle: 'تفعيل الوضع المظلم للتطبيق',
                value: _isDarkMode,
                onChanged: (value) => setState(() => _isDarkMode = value),
              ),
              _buildDropdownTile(
                icon: Icons.language_rounded,
                title: 'اللغة',
                subtitle: 'اختر لغة التطبيق',
                value: _selectedLanguage,
                items: _languages,
                onChanged: (value) => setState(() => _selectedLanguage = value!),
              ),
              _buildDropdownTile2(
                icon: Icons.text_fields_rounded,
                title: 'حجم الخط',
                subtitle: 'اختر حجم النص',
                value: _selectedFontSize,
                items: _fontSizes,
                onChanged: (value) => setState(() => _selectedFontSize = value!),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ الصوت والاهتزاز
          _buildSection(
            title: 'الصوت والاهتزاز',
            children: [
              _buildSwitchTile(
                icon: Icons.volume_up_rounded,
                title: 'النغمات',
                subtitle: 'تفعيل نغمات التطبيق',
                value: _soundEnabled,
                onChanged: (value) => setState(() => _soundEnabled = value),
              ),
              _buildSwitchTile(
                icon: Icons.notifications_rounded,
                title: 'الإشعارات',
                subtitle: 'استلام الإشعارات من التطبيق',
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchTile(
                icon: Icons.vibration_rounded,
                title: 'الاهتزاز',
                subtitle: 'اهتزاز عند استلام الإشعارات',
                value: _vibrationEnabled,
                onChanged: (value) => setState(() => _vibrationEnabled = value),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ معلومات
          _buildSection(
            title: 'معلومات',
            children: [
              _buildInfoTile(
                icon: Icons.info_rounded,
                title: 'عن التطبيق',
                subtitle: 'صحتك - منصة صحية شاملة',
                onTap: () => _showAboutDialog(),
              ),
              _buildInfoTile(
                icon: Icons.privacy_tip_rounded,
                title: 'سياسة الخصوصية',
                subtitle: 'عرض سياسة الخصوصية',
                onTap: () => _launchUrl('https://sehatak.com/privacy'),
              ),
              _buildInfoTile(
                icon: Icons.description_rounded,
                title: 'الشروط والأحكام',
                subtitle: 'عرض الشروط والأحكام',
                onTap: () => _launchUrl('https://sehatak.com/terms'),
              ),
              _buildInfoTile(
                icon: Icons.share_rounded,
                title: 'مشاركة التطبيق',
                subtitle: 'شارك التطبيق مع أصدقائك',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShareAppScreen(),
                    ),
                  );
                },
              ),
              _buildInfoTile(
                icon: Icons.star_rounded,
                title: 'قيّم التطبيق',
                subtitle: 'شاركنا رأيك',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RateAppScreen(),
                    ),
                  );
                },
              ),
              // ✅ زر عرض FCM Token (باستخدام SVG)
              _buildInfoTileSVG(
                icon: 'assets/icons/core/notifications_active.svg',
                title: 'عرض FCM Token',
                subtitle: 'انسخ التوكن لإرسال الإشعارات',
                onTap: _showFCMToken,
              ),
              // ✅ زر إعدادات الإشعارات (باستخدام SVG)
              _buildInfoTileSVG(
                icon: 'assets/icons/core/notifications_active.svg',
                title: 'إعدادات الإشعارات',
                subtitle: 'تخصيص إشعارات التطبيق',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✅ الإصدار
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'الإصدار',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1.1.0+2',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Sehatak Platform',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 Widgets
  // ============================================================

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
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
            color: AppColors.grey,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        secondary: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
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
            color: AppColors.grey,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['code'],
              child: Text(item['name']!),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildDropdownTile2({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
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
            color: AppColors.grey,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
        ),
      ),
    );
  }

  // ✅ دالة جديدة للأيقونات SVG
  Widget _buildInfoTileSVG({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
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
            color: AppColors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_rounded,
          size: 14,
          color: AppColors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
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
            color: AppColors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_rounded,
          size: 14,
          color: AppColors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // 🔧 Functions
  // ============================================================

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text('عن التطبيق'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'صحتك',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'منصة الرعاية الصحية الشاملة في اليمن',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'الإصدار: 1.1.0+2',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              '© 2026 Sehatak Platform. جميع الحقوق محفوظة.',
              style: TextStyle(fontSize: 11, color: AppColors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
        ),
      );
    }
  }
}
