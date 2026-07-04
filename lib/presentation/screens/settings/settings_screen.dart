import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSizeProvider = context.watch<FontSizeProvider>();
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الملف الشخصي
            _buildProfileSection(isDark),
            const SizedBox(height: 16),

            // ✅ المظهر
            _buildSectionHeader('المظهر', isDark),
            const SizedBox(height: 8),
            _buildAppearanceCard(isDark, fontSizeProvider),
            const SizedBox(height: 16),

            // ✅ الإشعارات
            _buildSectionHeader('الإشعارات', isDark),
            const SizedBox(height: 8),
            _buildCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    subtitle: 'تفعيل أو تعطيل الإشعارات',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSwitchTile(
                    icon: Icons.volume_up_rounded,
                    title: 'صوت الإشعارات',
                    subtitle: 'تفعيل صوت الإشعارات',
                    value: true,
                    onChanged: (_) {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSwitchTile(
                    icon: Icons.vibration_rounded,
                    title: 'اهتزاز الإشعارات',
                    subtitle: 'تفعيل الاهتزاز عند الإشعارات',
                    value: false,
                    onChanged: (_) {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ اللغة
            _buildSectionHeader('اللغة', isDark),
            const SizedBox(height: 8),
            _buildCard(
              child: _buildListTile(
                icon: Icons.language_rounded,
                title: 'اللغة',
                subtitle: 'العربية (الافتراضية)',
                onTap: () {},
                isDark: isDark,
                trailing: const Text(
                  'العربية',
                  style: TextStyle(color: Color(0xFF0D5257), fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الحساب
            _buildSectionHeader('الحساب', isDark),
            const SizedBox(height: 8),
            _buildCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.person_rounded,
                    title: 'الملف الشخصي',
                    subtitle: 'تعديل بياناتك الشخصية',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.lock_rounded,
                    title: 'تغيير كلمة المرور',
                    subtitle: 'تحديث كلمة المرور الخاصة بك',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.email_rounded,
                    title: 'البريد الإلكتروني',
                    subtitle: 'تحديث البريد الإلكتروني',
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الخصوصية والأمان
            _buildSectionHeader('الخصوصية والأمان', isDark),
            const SizedBox(height: 8),
            _buildCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.privacy_tip_rounded,
                    title: 'سياسة الخصوصية',
                    subtitle: 'عرض سياسة الخصوصية',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildSwitchTile(
                    icon: Icons.fingerprint_rounded,
                    title: 'المصادقة بالبصمة',
                    subtitle: 'استخدام البصمة لتسجيل الدخول',
                    value: false,
                    onChanged: (_) {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.data_usage_rounded,
                    title: 'البيانات والتخزين',
                    subtitle: 'إدارة بيانات التطبيق',
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الدعم
            _buildSectionHeader('الدعم', isDark),
            const SizedBox(height: 8),
            _buildCard(
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.help_rounded,
                    title: 'مركز المساعدة',
                    subtitle: 'الأسئلة الشائعة والدعم',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.feedback_rounded,
                    title: 'إرسال ملاحظات',
                    subtitle: 'شاركنا رأيك في التطبيق',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.share_rounded,
                    title: 'مشاركة التطبيق',
                    subtitle: 'دعوة الأصدقاء لاستخدام التطبيق',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildDivider(isDark),
                  _buildListTile(
                    icon: Icons.star_rounded,
                    title: 'تقييم التطبيق',
                    subtitle: 'قيم التطبيق في المتجر',
                    onTap: () {},
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ معلومات التطبيق
            _buildSectionHeader('عن التطبيق', isDark),
            const SizedBox(height: 8),
            _buildCard(
              child: _buildListTile(
                icon: Icons.info_rounded,
                title: 'عن صحتك',
                subtitle: 'الإصدار 1.1.0',
                onTap: () {},
                isDark: isDark,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'v1.1.0',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🧩 ويدجتس مساعدة
  // ============================================================
  Widget _buildProfileSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0D5257), const Color(0xFF0D5257).withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مستخدم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'user@example.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'نشط',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xFF1A2540) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: child,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: const Color(0xFF0D5257)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
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
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
      secondary: Icon(icon, color: const Color(0xFF0D5257)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0D5257),
    );
  }

  Widget _buildAppearanceCard(bool isDark, FontSizeProvider provider) {
    final fontScale = provider.fontScale;

    return _buildCard(
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode_rounded,
            title: 'الوضع المظلم',
            subtitle: 'تفعيل الوضع المظلم للتطبيق',
            value: isDark,
            onChanged: (value) {
              // ✅ تم التعليق مؤقتاً لحين إصلاح ThemeBloc
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSwitchTile(
            icon: Icons.brightness_auto_rounded,
            title: 'الوضع التلقائي',
            subtitle: 'متابعة إعدادات النظام',
            value: false,
            onChanged: (_) {},
            isDark: isDark,
          ),
          _buildDivider(isDark),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.text_fields_rounded, color: Color(0xFF0D5257)),
            title: Text(
              'حجم الخط',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              '${provider.fontSizePercent}% - ${provider.getScaleLabel()}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF0D5257)),
                  onPressed: () {
                    if (fontScale > 0.81) {
                      provider.setFontScale(fontScale - 0.05);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(fontScale * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: provider.getScaleColor(),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D5257)),
                  onPressed: () {
                    if (fontScale < 1.59) {
                      provider.setFontScale(fontScale + 0.05);
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          _buildDivider(isDark),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickSizeButton('صغير', 0.8, provider, isDark),
                _buildQuickSizeButton('متوسط', 1.0, provider, isDark),
                _buildQuickSizeButton('كبير', 1.3, provider, isDark),
                _buildQuickSizeButton('كبير جداً', 1.6, provider, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSizeButton(
    String label,
    double size,
    FontSizeProvider provider,
    bool isDark,
  ) {
    final isSelected = (provider.fontScale - size).abs() < 0.02;
    return GestureDetector(
      onTap: () => provider.setFontScale(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D5257)
              : (isDark ? const Color(0xFF1A2540) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D5257) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10 * (size / 1.0),
            color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(Logout());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
