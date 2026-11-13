import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class NextcloudSettingsScreen extends StatefulWidget {
  const NextcloudSettingsScreen({super.key});

  @override
  State<NextcloudSettingsScreen> createState() => _NextcloudSettingsScreenState();
}

class _NextcloudSettingsScreenState extends State<NextcloudSettingsScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final NextcloudService _nextcloud = NextcloudService();
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    await _nextcloud.loadConfig();
    if (!mounted) return;
    setState(() {
      _baseUrlController.text = _nextcloud.baseUrl;
      _usernameController.text = _nextcloud.username;
      _passwordController.text = _nextcloud.password;
    });
    await _checkConnection();
  }

  Future<void> _checkConnection() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _isConnected = await _nextcloud.checkServerStatus();
    } catch (_) {
      _isConnected = false;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _nextcloud.updateConfig(
        baseUrl: _baseUrlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text, // Preserve app-password characters exactly.
      );

      await _checkConnection();
      
      if (!mounted) return;
      if (_isConnected) {
        ToastService.showSuccess(_t('تم حفظ الإعدادات والاتصال بالخادم'));
      } else {
        ToastService.showWarning(_t('تم حفظ الإعدادات ولكن لا يمكن الاتصال بالخادم'));
      }
    } catch (e) {
      if (mounted) ToastService.showError('${_t('فشل حفظ الإعدادات:')} $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_t('إعدادات Nextcloud')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ شرح Nextcloud
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _t('☁️ Nextcloud مفتوح المصدر'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _t('Nextcloud هو خادم مفتوح المصدر بالكامل، يمكنك تثبيته على خادمك الخاص.\n\n✅ مجاني 100%\n✅ لا يحتاج مفاتيح API\n✅ بياناتك ملكك أنت فقط\n✅ يمكن تثبيته على أي خادم'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ حالة الاتصال
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isConnected ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isConnected
                            ? _t('متصل بخادم Nextcloud')
                            : _t('غير متصل بخادم Nextcloud'),
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!_isConnected)
                      TextButton(
                        onPressed: _checkConnection,
                        child: Text(_t('إعادة المحاولة')),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ عنوان الخادم
              TextFormField(
                controller: _baseUrlController,
                decoration: InputDecoration(
                  labelText: _t('عنوان خادم Nextcloud'),
                  hintText: 'https://nextcloud.example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cloud_rounded),
                  helperText: _t('أدخل عنوان IP أو دومين الخادم الخاص بك'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('يرجى إدخال عنوان الخادم');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ✅ اسم المستخدم
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: _t('اسم المستخدم'),
                  hintText: 'admin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_rounded),
                  helperText: _t('اسم المستخدم الذي أنشأته في Nextcloud'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('يرجى إدخال اسم المستخدم');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ✅ كلمة المرور
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _t('كلمة المرور'),
                  hintText: '••••••••',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_rounded),
                  helperText: _t('كلمة مرور مستخدم Nextcloud'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _t('يرجى إدخال كلمة المرور');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ✅ زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _t('حفظ الإعدادات'),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
