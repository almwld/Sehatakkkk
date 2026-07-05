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
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _locationEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final fontProvider = context.watch<FontSizeProvider>();
    final fontScale = fontProvider.fontScale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            onPressed: () {
              fontProvider.resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إعادة حجم الخط إلى الافتراضي'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'إعادة تعيين حجم الخط',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ 1. المظهر
          _buildSectionHeader('المظهر', isDark),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'الوضع المظلم',
                  subtitle: 'تفعيل الوضع المظلم للتطبيق',
                  value: isDark,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(
                      value ? SetDarkTheme() : SetLightTheme(),
                    );
                  },
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.brightness_auto_rounded,
                  title: 'الوضع التلقائي',
                  subtitle: 'متابعة إعدادات النظام',
                  value: context.read<ThemeBloc>().state.themeMode == ThemeMode.system,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(SetSystemTheme());
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 2. حجم الخط - متحكم فيه
          _buildSectionHeader('حجم الخط', isDark),
          const SizedBox(height: 8),
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ عرض الحجم الحالي
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: fontProvider.getScaleColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          fontProvider.getScaleIcon(),
                          color: fontProvider.getScaleColor(),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حجم الخط الحالي',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: fontProvider.getScaleColor().withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${fontProvider.fontSizePercent}%',
                                    style: TextStyle(
                                      color: fontProvider.getScaleColor(),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  fontProvider.getScaleLabel(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ✅ مثال للخط
                      Text(
                        'نص',
                        style: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ✅ شريط التحكم
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: primaryColor),
                        onPressed: () {
                          if (fontScale > 0.81) {
                            fontProvider.setFontScale(fontScale - 0.05);
                          }
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: fontScale,
                          min: 0.8,
                          max: 1.6,
                          divisions: 16,
                          label: '${(fontScale * 100).round()}%',
                          onChanged: (value) {
                            fontProvider.setFontScale(value);
                          },
                          activeColor: primaryColor,
                          inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: primaryColor),
                        onPressed: () {
                          if (fontScale < 1.59) {
                            fontProvider.setFontScale(fontScale + 0.05);
                          }
                        },
                      ),
                    ],
                  ),

                  // ✅ أزرار سريعة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickSizeButton('صغير', 0.8, fontProvider, isDark),
                      _buildQuickSizeButton('متوسط', 1.0, fontProvider, isDark),
                      _buildQuickSizeButton('كبير', 1.3, fontProvider, isDark),
                      _buildQuickSizeButton('كبير جداً', 1.6, fontProvider, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 3. اللغة
          _buildSectionHeader('اللغة', isDark),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                _buildRadioTile(
                  icon: Icons.language_rounded,
                  title: 'العربية',
                  subtitle: 'اللغة الافتراضية',
                  value: 'ar',
                  groupValue: 'ar',
                  onChanged: (_) {},
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildRadioTile(
                  icon: Icons.language_rounded,
                  title: 'English',
                  subtitle: 'Default language',
                  value: 'en',
                  groupValue: 'ar',
                  onChanged: (_) {},
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 4. الإشعارات
          _buildSectionHeader('الإشعارات', isDark),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_rounded,
                  title: 'الإشعارات',
                  subtitle: 'تلقي إشعارات التطبيق',
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.volume_up_rounded,
                  title: 'الصوت',
                  subtitle: 'تشغيل صوت الإشعارات',
                  value: _soundEnabled,
                  onChanged: (value) => setState(() => _soundEnabled = value),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.vibration_rounded,
                  title: 'الاهتزاز',
                  subtitle: 'تفعيل الاهتزاز عند الإشعارات',
                  value: _vibrationEnabled,
                  onChanged: (value) => setState(() => _vibrationEnabled = value),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 5. الخصوصية والأمان
          _buildSectionHeader('الخصوصية والأمان', isDark),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.lock_rounded,
                  title: 'تغيير كلمة المرور',
                  subtitle: 'تحديث كلمة المرور الخاصة بك',
                  onTap: () {},
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'البصمة',
                  subtitle: 'تفعيل تسجيل الدخول بالبصمة',
                  onTap: () {},
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.location_on_rounded,
                  title: 'الموقع',
                  subtitle: 'السماح للتطبيق بالوصول إلى موقعك',
                  value: _locationEnabled,
                  onChanged: (value) => setState(() => _locationEnabled = value),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 6. الدعم
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
                  subtitle: 'قيم التطبيق على المتجر',
                  onTap: () {},
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 7. معلومات التطبيق
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 48,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'صحتك',
                    style: TextStyle(
                      fontSize: 20 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الإصدار 1.1.0',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'منصة صحتك الشاملة',
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 Sehatak Platform. All rights reserved.',
                    style: TextStyle(
                      fontSize: 10 * fontScale,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ 8. تسجيل الخروج
          _buildCard(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 Widgets مساعدة
  // ============================================================

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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildRadioTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: const Color(0xFF0D5257)),
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
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF0D5257),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: const Color(0xFF0D5257)),
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
          color: isSelected ? const Color(0xFF0D5257) : (isDark ? const Color(0xFF1A2540) : Colors.grey[200]),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(Logout());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
