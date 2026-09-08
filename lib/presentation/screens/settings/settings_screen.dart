import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/profile/profile_screen.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/settings/change_password_screen.dart';
import 'package:sehatak/presentation/screens/settings/language_screen.dart';
import 'package:sehatak/presentation/screens/settings/privacy_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/settings/help_screen.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricSupported = false;
  bool _isBiometricEnabled = false;
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
      final available = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (mounted) setState(() => _isBiometricSupported = available && supported);
    } catch (_) {
      if (mounted) setState(() => _isBiometricSupported = false);
    }
  }

  Future<void> _loadBiometricPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) setState(() => _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false);
    } catch (_) {}
  }

  void _loadThemeMode() {
    final mode = context.read<ThemeBloc>().state.themeMode;
    if (mounted) setState(() => _isSystemMode = mode == ThemeMode.system);
  }

  Future<void> _toggleBiometric(bool value) async {
    try {
      if (value) {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'سجل باستخدام بصمة الإصبع لتأكيد الهوية',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );
        if (!authenticated) {
          ToastService.showError('فشل التحقق من البصمة، حاول مرة أخرى');
          return;
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', value);
      if (mounted) setState(() => _isBiometricEnabled = value);
      ToastService.showSuccess(value ? 'تم تفعيل تسجيل الدخول بالبصمة' : 'تم إلغاء تفعيل تسجيل الدخول بالبصمة');
    } catch (_) {
      ToastService.showError('تعذر تحديث إعداد البصمة');
    }
  }

  Widget _localImage(String path, {double size = 24, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _localTileIcon(String path, {double size = 24}) => _localImage(path, size: size, color: AppColors.primary);

  Widget _arrow(bool dark, {Color? color}) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 8),
    child: Text('‹', style: TextStyle(fontSize: 28, height: 1, color: color ?? (dark ? Colors.grey.shade500 : Colors.grey.shade500))),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontProvider = context.watch<FontSizeProvider>();
    final scale = fontProvider.fontScale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF7F9FA),
      appBar: CustomAppBar(
        title: 'الإعدادات',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: _localImage(AppImages.uiSettingsGear, color: Colors.white),
            onPressed: _loadThemeMode,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('المظهر', isDark),
          _card(isDark, Column(children: [
            _switchTile(AppImages.uiSettingsGear, 'الوضع المظلم', 'تفعيل الوضع المظلم للتطبيق', isDark, isDark, (v) {
              context.read<ThemeBloc>().setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
              setState(() => _isSystemMode = false);
            }),
            _divider(isDark),
            _switchTile(AppImages.uiSettingsGear, 'الوضع التلقائي', 'متابعة إعدادات النظام', isDark, _isSystemMode, (v) {
              context.read<ThemeBloc>().setThemeMode(v ? ThemeMode.system : ThemeMode.light);
              setState(() => _isSystemMode = v);
            }),
          ])),
          const SizedBox(height: 16),

          if (_isBiometricSupported) ...[
            _section('الأمان', isDark),
            _card(isDark, Column(children: [
              _switchTile(AppImages.uiUserProfile, 'تسجيل الدخول بالبصمة', _isBiometricEnabled ? 'تم التفعيل - استخدم بصمتك للدخول' : 'تفعيل تسجيل الدخول باستخدام بصمة الإصبع', isDark, _isBiometricEnabled, _toggleBiometric),
              _divider(isDark),
              _listTileAsset(AppImages.uiSettingsGear, 'المصادقة الثنائية', 'تفعيل المصادقة الثنائية لمزيد من الأمان', isDark, () => ToastService.showSuccess('سيتم تفعيل المصادقة الثنائية قريباً')),
            ])),
            const SizedBox(height: 16),
          ],

          _section('حجم الخط', isDark),
          _card(isDark, Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                _localTileIcon(AppImages.uiSettingsGear),
                const SizedBox(width: 12),
                Expanded(child: Text('حجم الخط الحالي', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87))),
                Text('${(scale * 100).round()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ]),
              Row(children: [
                IconButton(
                  onPressed: () => fontProvider.setFontScale((scale - .05).clamp(.8, 1.6)),
                  icon: const Text('−', style: TextStyle(fontSize: 26, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  tooltip: 'تصغير الخط',
                ),
                Expanded(child: Slider(value: scale.clamp(.8, 1.6), min: .8, max: 1.6, divisions: 16, activeColor: AppColors.primary, onChanged: fontProvider.setFontScale)),
                IconButton(
                  onPressed: () => fontProvider.setFontScale((scale + .05).clamp(.8, 1.6)),
                  icon: const Text('+', style: TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  tooltip: 'تكبير الخط',
                ),
              ]),
              Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                _sizeButton('صغير', .8, fontProvider, isDark),
                _sizeButton('متوسط', 1.0, fontProvider, isDark),
                _sizeButton('كبير', 1.3, fontProvider, isDark),
                _sizeButton('كبير جداً', 1.6, fontProvider, isDark),
              ]),
            ]),
          )),
          const SizedBox(height: 16),

          _section('الحساب', isDark),
          _card(isDark, Column(children: [
            _listTileAsset(AppImages.uiUserProfile, 'الملف الشخصي', 'تعديل بياناتك الشخصية', isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            _divider(isDark),
            _listTileAsset(AppImages.uiSettingsGear, 'تغيير كلمة المرور', 'تحديث كلمة المرور الخاصة بك', isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
            _divider(isDark),
            _listTileAsset(AppImages.notificationsIcon, 'الإشعارات', 'إدارة إعدادات الإشعارات', isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          ])),
          const SizedBox(height: 16),

          _section('التطبيق', isDark),
          _card(isDark, Column(children: [
            _listTileAsset(AppImages.uiSettingsGear, 'اللغة', 'تغيير لغة التطبيق', isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()))),
            _divider(isDark),
            _listTileAsset(AppImages.uiHelpCenter, 'المساعدة والدعم', 'الأسئلة الشائعة والدعم الفني', isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()))),
            _divider(isDark),
            _listTileAsset(AppImages.uiPrivacy, 'الخصوصية', 'سياسة الخصوصية والأمان', isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()))),
            _divider(isDark),
            _listTileAsset(AppImages.uiAboutApp, 'عن التطبيق', 'الإصدار 1.1.0', isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
          ])),
          const SizedBox(height: 16),

          _card(isDark, ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: _localImage(AppImages.uiReportProblem, color: Colors.red),
            title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            trailing: _arrow(isDark, color: Colors.red),
            onTap: () => _showLogoutDialog(context),
          )),
          const SizedBox(height: 20),
          Center(child: Text('صحتك - الإصدار 1.1.0', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _section(String title, bool dark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: dark ? Colors.grey[400] : Colors.grey[600])),
  );

  Widget _card(bool dark, Widget child) => Card(
    color: dark ? const Color(0xFF1A2540) : Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: child,
  );

  Widget _divider(bool dark) => Divider(height: 1, color: dark ? Colors.grey[800] : Colors.grey[200], indent: 16, endIndent: 16);

  Widget _switchTile(String iconPath, String title, String subtitle, bool dark, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    secondary: _localTileIcon(iconPath),
    title: Text(title, style: TextStyle(color: dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: dark ? Colors.grey[400] : Colors.grey[600])),
    value: value,
    activeColor: AppColors.primary,
    onChanged: onChanged,
  );

  Widget _listTileAsset(String path, String title, String subtitle, bool dark, VoidCallback onTap) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: _localTileIcon(path),
    title: Text(title, style: TextStyle(color: dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: dark ? Colors.grey[400] : Colors.grey[600])),
    trailing: _arrow(dark),
    onTap: onTap,
  );

  Widget _sizeButton(String label, double size, FontSizeProvider provider, bool dark) {
    final selected = (provider.fontScale - size).abs() < .02;
    return GestureDetector(
      onTap: () => provider.setFontScale(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: selected ? AppColors.primary : (dark ? const Color(0xFF25314D) : Colors.grey[200]), borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(fontSize: 11 * size, color: selected ? Colors.white : (dark ? Colors.grey[300] : Colors.grey[700]), fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              } catch (e) {
                ToastService.showError('خطأ في تسجيل الخروج: $e');
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
