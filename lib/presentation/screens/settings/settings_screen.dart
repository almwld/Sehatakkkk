import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/core/utils/icon_helper.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/profile/profile_screen.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/settings/change_password_screen.dart';
import 'package:sehatak/presentation/screens/settings/language_screen.dart';
import 'package:sehatak/presentation/screens/settings/privacy_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/settings/help_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricSupported = false;
  bool _isBiometricEnabled = false;
  bool _isDarkMode = false;
  bool _isSystemMode = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadBiometricPrefs();
    _loadThemeMode();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricSupported = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      print('Biometric check error: $e');
      setState(() {
        _isBiometricSupported = false;
      });
    }
  }

  Future<void> _loadBiometricPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      });
    } catch (e) {
      print('Error loading biometric prefs: $e');
    }
  }

  void _loadThemeMode() {
    final state = context.read<ThemeBloc>().state;
    setState(() {
      _isDarkMode = state.themeMode == ThemeMode.dark;
      _isSystemMode = state.themeMode == ThemeMode.system;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    try {
      if (value) {
        final isAuthenticated = await _localAuth.authenticate(
          localizedReason: 'سجل باستخدام بصمة الإصبع لتأكيد الهوية',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (!isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ فشل التحقق من البصمة، حاول مرة أخرى'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isBiometricEnabled = false;
          });
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تفعيل تسجيل الدخول بالبصمة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ تم إلغاء تفعيل تسجيل الدخول بالبصمة'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      setState(() {
        _isBiometricEnabled = value;
      });
    } catch (e) {
      print('Error toggling biometric: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
      await _loadBiometricPrefs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontSizeProvider = context.watch<FontSizeProvider>();
    final fontScale = fontSizeProvider.fontScale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: 'الإعدادات',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {});
              _loadThemeMode();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ قسم المظهر
          _buildSectionHeader('المظهر', isDark),
          const SizedBox(height: 8),
          _buildCard(
            isDark: isDark,
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
                    setState(() {
                      _isDarkMode = value;
                      _isSystemMode = false;
                    });
                  },
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  icon: Icons.brightness_auto_rounded,
                  title: 'الوضع التلقائي',
                  subtitle: 'متابعة إعدادات النظام',
                  value: _isSystemMode,
                  onChanged: (value) {
                    // ✅ تفعيل الوضع التلقائي
                    setState(() {
                      _isSystemMode = value;
                      _isDarkMode = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔄 تم تفعيل الوضع التلقائي - متابعة إعدادات النظام'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ قسم البصمة
          if (_isBiometricSupported)
            Column(
              children: [
                _buildSectionHeader('الأمان', isDark),
                const SizedBox(height: 8),
                _buildCard(
                  isDark: isDark,
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'تسجيل الدخول بالبصمة',
                        subtitle: _isBiometricEnabled
                            ? '✅ تم التفعيل - استخدم بصمتك للدخول'
                            : 'تفعيل تسجيل الدخول باستخدام بصمة الإصبع',
                        value: _isBiometricEnabled,
                        onChanged: _toggleBiometric,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildListTile(
                        icon: Icons.security_rounded,
                        title: 'المصادقة الثنائية',
                        subtitle: 'تفعيل المصادقة الثنائية لمزيد من الأمان',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔐 سيتم تفعيل المصادقة الثنائية قريباً'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

          // ✅ قسم حجم الخط
          _buildSectionHeader('حجم الخط', isDark),
          const SizedBox(height: 8),
          _buildCard(
            isDark: isDark,
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

          // ✅ قسم الحساب
          _buildSectionHeader('الحساب', isDark),
          const SizedBox(height: 8),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.person_rounded,
                  title: 'الملف الشخصي',
                  subtitle: 'تعديل بياناتك الشخصية',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.lock_rounded,
                  title: 'تغيير كلمة المرور',
                  subtitle: 'تحديث كلمة المرور الخاصة بك',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.notifications_rounded,
                  title: 'الإشعارات',
                  subtitle: 'إدارة إعدادات الإشعارات',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ قسم التطبيق
          _buildSectionHeader('التطبيق', isDark),
          const SizedBox(height: 8),
          _buildCard(
            isDark: isDark,
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.language_rounded,
                  title: 'اللغة',
                  subtitle: 'تغيير لغة التطبيق',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguageScreen()),
                    );
                  },
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.help_outline_rounded,
                  title: 'المساعدة والدعم',
                  subtitle: 'الأسئلة الشائعة والدعم الفني',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    );
                  },
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'الخصوصية',
                  subtitle: 'سياسة الخصوصية والأمان',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                    );
                  },
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildListTile(
                  icon: Icons.info_outline_rounded,
                  title: 'عن التطبيق',
                  subtitle: 'الإصدار 1.1.0',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ قسم تسجيل الخروج
          _buildCard(
            isDark: isDark,
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

          Center(
            child: Text(
              'صحتك - الإصدار 1.1.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 10),
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

  Widget _buildCard({
    required Widget child,
    required bool isDark,
  }) {
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
      indent: 16,
      endIndent: 16,
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
          fontWeight: FontWeight.w500,
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
          fontWeight: FontWeight.w500,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: 'تسجيل الخروج',
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في تسجيل الخروج: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
