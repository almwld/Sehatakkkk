import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/profile/profile_screen.dart';
import 'package:sehatak/presentation/screens/settings/notification_settings_screen.dart';
import 'package:sehatak/presentation/screens/settings/change_password_screen.dart';
import 'package:sehatak/presentation/screens/settings/language_screen.dart';
import 'package:sehatak/presentation/screens/settings/privacy_screen.dart';
import 'package:sehatak/presentation/screens/settings/location_selection_screen.dart';
import 'package:sehatak/presentation/screens/settings/security_settings_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/settings/help_screen.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/saved_accounts_service.dart';
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
  String? _deliveryArea;
  String? _deliveryAddress;

  static const String _logoutIcon = 'assets/images/ui/logout.webp';
  static const String _languageIcon = 'assets/icons/settings/app_language.webp';
  static const String _autoModeIcon = 'assets/icons/settings/auto_mode.webp';
  static const String _changePasswordIcon = 'assets/icons/settings/change_password.webp';
  static const String _fontSizeIcon = 'assets/icons/settings/font_size.webp';
  static const String _locationIcon = 'assets/icons/settings/select_location.webp';
  static const String _fingerprintIcon = 'assets/icons/fingerprint_lines_transparent.webp';

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadBiometricPrefs();
    _loadThemeMode();
    _loadDeliveryArea();
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

  Future<void> _loadDeliveryArea() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _deliveryArea = prefs.getString('delivery_area');
          _deliveryAddress = prefs.getString('delivery_address');
        });
      }
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
          localizedReason: AppStrings.of(context).translate('سجل باستخدام بصمة الإصبع لتأكيد الهوية'),
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );
        if (!authenticated) {
          ToastService.showError(AppStrings.of(context).translate('فشل التحقق من البصمة، حاول مرة أخرى'));
          return;
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', value);
      if (mounted) setState(() => _isBiometricEnabled = value);
      ToastService.showSuccess(AppStrings.of(context).translate(value ? 'تم تفعيل تسجيل الدخول بالبصمة' : 'تم إلغاء تفعيل تسجيل الدخول بالبصمة'));
    } catch (_) {
      ToastService.showError(AppStrings.of(context).translate('تعذر تحديث إعداد البصمة'));
    }
  }

  Widget _localImage(String path, {double size = 24, Color? color}) => Image.asset(
    path,
    width: size,
    height: size,
    fit: BoxFit.contain,
    color: color,
    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
  );

  Widget _localTileIcon(String path, {double size = 24, bool tint = true}) => _localImage(path, size: size, color: tint ? AppColors.primary : null);

  Widget _arrow(bool dark, {Color? color}) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 8),
    child: Text('‹', style: TextStyle(fontSize: 28, height: 1, color: color ?? Colors.grey.shade500)),
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fontProvider = context.watch<FontSizeProvider>();
    final scale = fontProvider.fontScale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF7F9FA),
      appBar: CustomAppBar(
        title: strings.settings,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: AppStrings.of(context).translate('الإعدادات'),
            icon: _localImage(AppImages.uiSettingsGear, color: Colors.white),
            onPressed: _loadThemeMode,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(strings.appearance, isDark),
          _card(isDark, Column(children: [
            _switchTile(AppImages.uiSettingsGear, strings.darkMode, strings.darkModeDescription, isDark, isDark, (v) {
              context.read<ThemeBloc>().setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
              setState(() => _isSystemMode = false);
            }),
            _divider(isDark),
            _switchTile(_autoModeIcon, strings.automaticMode, strings.systemModeDescription, isDark, _isSystemMode, (v) {
              context.read<ThemeBloc>().setThemeMode(v ? ThemeMode.system : ThemeMode.light);
              setState(() => _isSystemMode = v);
            }, tint: false),
          ])),
          const SizedBox(height: 16),
          _section(strings.locationAndDelivery, isDark),
          _card(isDark, Column(children: [
            _listTileAsset(
              _locationIcon,
              strings.locationTitle,
              _deliveryArea == null
                  ? strings.chooseLocation
                  : (_deliveryAddress == null || _deliveryAddress!.isEmpty
                      ? '${AppStrings.of(context).translate('المحافظة')}: $_deliveryArea'
                      : '$_deliveryArea — $_deliveryAddress'),
              isDark,
              () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSelectionScreen()));
                _loadDeliveryArea();
              },
              tint: false,
            ),
          ])),
          const SizedBox(height: 16),
          _section(strings.security, isDark),
          _card(isDark, Column(children: [
            if (_isBiometricSupported) ...[
              _switchTile(
                _fingerprintIcon,
                AppStrings.of(context).translate('تسجيل الدخول بالبصمة'),
                AppStrings.of(context).translate(_isBiometricEnabled ? 'تم التفعيل - استخدم بصمتك للدخول' : 'تفعيل تسجيل الدخول باستخدام بصمة الإصبع'),
                isDark,
                _isBiometricEnabled,
                _toggleBiometric,
                tint: false,
              ),
              _divider(isDark),
            ],
            _listTileAsset(
              AppImages.uiSettingsGear,
              strings.securityDevices,
              strings.manageSessions,
              isDark,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen())),
            ),
          ])),
          const SizedBox(height: 16),
          _section(strings.fontSize, isDark),
          _card(isDark, Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                _localTileIcon(_fontSizeIcon, tint: false),
                const SizedBox(width: 12),
                Expanded(child: Text(strings.currentFontSize, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87))),
                Text('${(scale * 100).round()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ]),
              Row(children: [
                IconButton(onPressed: () => fontProvider.setFontScale((scale - .05).clamp(.8, 1.6)), icon: const Text('−', style: TextStyle(fontSize: 26, color: AppColors.primary, fontWeight: FontWeight.w600)), tooltip: AppStrings.of(context).translate('تصغير الخط')),
                Expanded(child: Slider(value: scale.clamp(.8, 1.6), min: .8, max: 1.6, divisions: 16, activeColor: AppColors.primary, onChanged: fontProvider.setFontScale)),
                IconButton(onPressed: () => fontProvider.setFontScale((scale + .05).clamp(.8, 1.6)), icon: const Text('+', style: TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.w600)), tooltip: AppStrings.of(context).translate('تكبير الخط')),
              ]),
              Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                _sizeButton(strings.small, .8, fontProvider, isDark),
                _sizeButton(strings.medium, 1.0, fontProvider, isDark),
                _sizeButton(strings.large, 1.3, fontProvider, isDark),
                _sizeButton(strings.extraLarge, 1.6, fontProvider, isDark),
              ]),
            ]),
          )),
          const SizedBox(height: 16),
          _section(strings.account, isDark),
          _card(isDark, Column(children: [
            _listTileAsset(AppImages.uiUserProfile, strings.profile, strings.editPersonalInfo, isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
            _divider(isDark),
            _listTileAsset(_changePasswordIcon, strings.changePassword, strings.updatePassword, isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())), tint: false),
            _divider(isDark),
            _listTileAsset(AppImages.notificationsIcon, strings.notifications, strings.notifications, isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()))),
          ])),
          const SizedBox(height: 16),
          _section(strings.appSection, isDark),
          _card(isDark, Column(children: [
            _listTileAsset(_languageIcon, strings.language, strings.changeLanguage, isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())), tint: false),
            _divider(isDark),
            _listTileAsset(AppImages.uiHelpCenter, strings.helpSupport, strings.helpSupport, isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())), tint: false),
            _divider(isDark),
            _listTileAsset(AppImages.uiPrivacy, strings.privacy, strings.privacy, isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())), tint: false),
            _divider(isDark),
            _listTileAsset(AppImages.uiAboutApp, strings.about, AppStrings.of(context).translate('الإصدار 1.1.0'), isDark, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())), tint: false),
          ])),
          const SizedBox(height: 16),
          _card(isDark, ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: _localImage(_logoutIcon),
            title: Text(strings.logout, style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            trailing: _arrow(isDark, color: Colors.red),
            onTap: () => _showLogoutDialog(context),
          )),
          const SizedBox(height: 20),
          Center(child: Text(AppStrings.of(context).translate('صحتك - الإصدار 1.1.0'), style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
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

  Widget _switchTile(String iconPath, String title, String subtitle, bool dark, bool value, ValueChanged<bool> onChanged, {bool tint = true}) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    secondary: _localTileIcon(iconPath, tint: tint),
    title: Text(title, style: TextStyle(color: dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: dark ? Colors.grey[400] : Colors.grey[600])),
    value: value,
    activeColor: AppColors.primary,
    onChanged: onChanged,
  );

  Widget _listTileAsset(String path, String title, String subtitle, bool dark, VoidCallback onTap, {bool tint = true}) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    leading: _localTileIcon(path, tint: tint),
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
        title: Text(AppStrings.of(context).logout),
        content: Text(AppStrings.of(context).confirmLogout),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.of(context).cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await SavedAccountsService.saveCurrentAccount(user);
                }
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
              } catch (e) {
                ToastService.showError('${AppStrings.of(context).translate('خطأ في تسجيل الخروج')}: $e');
              }
            },
            child: Text(AppStrings.of(context).logout),
          ),
        ],
      ),
    );
  }
}