import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class NextcloudSettingsScreen extends StatefulWidget {
  const NextcloudSettingsScreen({super.key});

  @override
  State<NextcloudSettingsScreen> createState() => _NextcloudSettingsScreenState();
}

class _NextcloudSettingsScreenState extends State<NextcloudSettingsScreen> {
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
    setState(() {
      _baseUrlController.text = _nextcloud.baseUrl;
      _usernameController.text = _nextcloud.username;
      _passwordController.text = _nextcloud.password;
    });
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() => _isLoading = true);
    try {
      _isConnected = await _nextcloud.checkServerStatus();
    } catch (e) {
      _isConnected = false;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _nextcloud.updateConfig(
        baseUrl: _baseUrlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _checkConnection();
      
      if (_isConnected) {
        ToastService.showSuccess('✅ تم حفظ الإعدادات والاتصال بالخادم');
      } else {
        ToastService.showWarning('⚠️ تم حفظ الإعدادات ولكن لا يمكن الاتصال بالخادم');
      }
    } catch (e) {
      ToastService.showError('❌ فشل حفظ الإعدادات: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('إعدادات Nextcloud'),
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
                        const Text(
                          '☁️ Nextcloud مفتوح المصدر',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nextcloud هو خادم مفتوح المصدر بالكامل، يمكنك تثبيته على خادمك الخاص.\n\n'
                      '✅ مجاني 100%\n'
                      '✅ لا يحتاج مفاتيح API\n'
                      '✅ بياناتك ملكك أنت فقط\n'
                      '✅ يمكن تثبيته على أي خادم',
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
                            ? '✅ متصل بخادم Nextcloud'
                            : '❌ غير متصل بخادم Nextcloud',
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!_isConnected)
                      TextButton(
                        onPressed: _checkConnection,
                        child: const Text('إعادة المحاولة'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ عنوان الخادم
              TextFormField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'عنوان خادم Nextcloud',
                  hintText: 'https://nextcloud.example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cloud_rounded),
                  helperText: 'أدخل عنوان IP أو دومين الخادم الخاص بك',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال عنوان الخادم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ✅ اسم المستخدم
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  hintText: 'admin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_rounded),
                  helperText: 'اسم المستخدم الذي أنشأته في Nextcloud',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المستخدم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ✅ كلمة المرور
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  hintText: '••••••••',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_rounded),
                  helperText: 'كلمة مرور مستخدم Nextcloud',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
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
                      : const Text(
                          'حفظ الإعدادات',
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
