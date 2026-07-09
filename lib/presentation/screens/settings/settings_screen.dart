import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';

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
    final theme = Theme.of(context);
    final fontSizeProvider = context.watch<FontSizeProvider>();
    final fontScale = fontSizeProvider.fontScale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            onPressed: () {
              fontSizeProvider.resetToDefault();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إعادة حجم الخط إلى الافتراضي'),
                  backgroundColor: AppColors.success,
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
          _buildSectionHeader('حجم الخط', isDark),
          const SizedBox(height: 8),
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: fontSizeProvider.getScaleColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          fontSizeProvider.getScaleIcon(),
                          color: fontSizeProvider.getScaleColor(),
                          size: 24,
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
                                    color: fontSizeProvider.getScaleColor().withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${fontSizeProvider.fontSizePercent}%',
                                    style: TextStyle(
                                      color: fontSizeProvider.getScaleColor(),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  fontSizeProvider.getScaleLabel(),
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
                      Text(
                        'نص',
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          if (fontScale > 0.81) {
                            fontSizeProvider.setFontScale(fontScale - 0.05);
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
                            fontSizeProvider.setFontScale(value);
                          },
                          activeColor: AppColors.primary,
                          inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: () {
                          if (fontScale < 1.59) {
                            fontSizeProvider.setFontScale(fontScale + 0.05);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickSizeButton('صغير', 0.8, fontSizeProvider, isDark),
                      _buildQuickSizeButton('متوسط', 1.0, fontSizeProvider, isDark),
                      _buildQuickSizeButton('كبير', 1.3, fontSizeProvider, isDark),
                      _buildQuickSizeButton('كبير جداً', 1.6, fontSizeProvider, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                  icon: Icons.notifications_rounded,
                  title: 'الإشعارات',
                  subtitle: 'إدارة إعدادات الإشعارات',
                  onTap: () {},
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    size: 48,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'صحتك',
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'الإصدار 1.1.0',
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'منصة صحتك الشاملة',
                    style: TextStyle(
                      fontSize: 12 * fontScale,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildQuickSizeButton(String label, double size, FontSizeProvider provider, bool isDark) {
    final isSelected = (provider.fontScale - size).abs() < 0.02;
    return GestureDetector(
      onTap: () => provider.setFontScale(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
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
      secondary: Icon(icon, color: AppColors.primary),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
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
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppColors.primary,
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
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
                MaterialPageRoute(builder: (_) => const AuthScreen()),
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
