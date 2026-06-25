import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';  // ✅ المسار الصحيح
import 'package:sehatak/presentation/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  
  // ✅ حقول المستخدم
  final _userNameCtrl = TextEditingController();
  final _userPhoneCtrl = TextEditingController();
  final _userEmailCtrl = TextEditingController();
  final _userPassCtrl = TextEditingController();
  final _userConfirmCtrl = TextEditingController();
  
  // ✅ حقول الطبيب
  final _docNameCtrl = TextEditingController();
  final _docPhoneCtrl = TextEditingController();
  final _docEmailCtrl = TextEditingController();
  final _docLicenseCtrl = TextEditingController();
  final _docSpecialtyCtrl = TextEditingController();
  final _docPassCtrl = TextEditingController();
  final _docConfirmCtrl = TextEditingController();
  
  bool _agreeTerms = false;
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _userNameCtrl.dispose();
    _userPhoneCtrl.dispose();
    _userEmailCtrl.dispose();
    _userPassCtrl.dispose();
    _userConfirmCtrl.dispose();
    _docNameCtrl.dispose();
    _docPhoneCtrl.dispose();
    _docEmailCtrl.dispose();
    _docLicenseCtrl.dispose();
    _docSpecialtyCtrl.dispose();
    _docPassCtrl.dispose();
    _docConfirmCtrl.dispose();
    super.dispose();
  }

  void _registerUser() {
    if (!_agreeTerms) {
      _showMsg('يجب الموافقة على الشروط والأحكام', true);
      return;
    }
    if (_userPassCtrl.text != _userConfirmCtrl.text) {
      _showMsg('كلمتا المرور غير متطابقتين', true);
      return;
    }
    if (_userPassCtrl.text.length < 6) {
      _showMsg('كلمة المرور يجب أن تكون 6 أحرف على الأقل', true);
      return;
    }
    context.read<AuthBloc>().add(
      RegisterWithEmail(
        name: _userNameCtrl.text.trim(),
        email: _userEmailCtrl.text.trim(),
        phone: _userPhoneCtrl.text.trim(),
        password: _userPassCtrl.text.trim(),
      ),
    );
  }

  void _registerDoctor() {
    if (!_agreeTerms) {
      _showMsg('يجب الموافقة على الشروط والأحكام', true);
      return;
    }
    if (_docPassCtrl.text != _docConfirmCtrl.text) {
      _showMsg('كلمتا المرور غير متطابقتين', true);
      return;
    }
    if (_docPassCtrl.text.length < 6) {
      _showMsg('كلمة المرور يجب أن تكون 6 أحرف على الأقل', true);
      return;
    }
    if (_docLicenseCtrl.text.isEmpty) {
      _showMsg('يجب إدخال رقم الترخيص', true);
      return;
    }
    context.read<AuthBloc>().add(
      RegisterDoctor(
        name: _docNameCtrl.text.trim(),
        email: _docEmailCtrl.text.trim(),
        phone: _docPhoneCtrl.text.trim(),
        password: _docPassCtrl.text.trim(),
        license: _docLicenseCtrl.text.trim(),
        specialty: _docSpecialtyCtrl.text.trim(),
      ),
    );
  }

  void _showMsg(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, s) {
          if (s is Authenticated) {
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (r) => false,
            );
          }
          if (s is AuthError) {
            _showMsg(s.message, true);
          }
        },
        builder: (ctx, s) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.person_add, size: 60, color: AppColors.primary),
              const SizedBox(height: 8),
              const Text(
                'انضم إلى منصة صحتك',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const Text(
                'اختر نوع الحساب',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ✅ بنر أخضر للتبويبات
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  onTap: (index) => setState(() {}),
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'مستخدم'),
                    Tab(text: 'طبيب'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ✅ محتوى التبويبات
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _tabCtrl.index == 0 ? 520 : 600,
                child: TabBarView(
                  controller: _tabCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // ✅ نموذج المستخدم
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTextField(_userNameCtrl, 'الاسم الكامل', Icons.person),
                          const SizedBox(height: 12),
                          _buildTextField(_userPhoneCtrl, 'رقم الهاتف', Icons.phone_android, keyboardType: TextInputType.phone),
                          const SizedBox(height: 12),
                          _buildTextField(_userEmailCtrl, 'البريد الإلكتروني', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          _buildPasswordField(_userPassCtrl, 'كلمة المرور'),
                          const SizedBox(height: 12),
                          _buildPasswordField(_userConfirmCtrl, 'تأكيد كلمة المرور', isConfirm: true),
                        ],
                      ),
                    ),
                    // ✅ نموذج الطبيب
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTextField(_docNameCtrl, 'الاسم الكامل', Icons.person),
                          const SizedBox(height: 12),
                          _buildTextField(_docPhoneCtrl, 'رقم الهاتف', Icons.phone_android, keyboardType: TextInputType.phone),
                          const SizedBox(height: 12),
                          _buildTextField(_docEmailCtrl, 'البريد الإلكتروني', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          _buildTextField(_docLicenseCtrl, 'رقم الترخيص', Icons.badge_outlined),
                          const SizedBox(height: 12),
                          _buildTextField(_docSpecialtyCtrl, 'التخصص', Icons.medical_services),
                          const SizedBox(height: 12),
                          _buildPasswordField(_docPassCtrl, 'كلمة المرور'),
                          const SizedBox(height: 12),
                          _buildPasswordField(_docConfirmCtrl, 'تأكيد كلمة المرور', isConfirm: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ أوافق على الشروط - رابط لصفحة الشروط الموجودة
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _agreeTerms = v!),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsScreen()),
                      );
                    },
                    child: const Text(
                      'أوافق على ',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsScreen()),
                      );
                    },
                    child: Text(
                      'الشروط والأحكام',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_agreeTerms && !_loading)
                      ? (_tabCtrl.index == 0 ? _registerUser : _registerDoctor)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: s is AuthLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _tabCtrl.index == 0 ? 'إنشاء حساب مستخدم' : 'إنشاء حساب طبيب',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2540)
            : AppColors.surfaceContainerLow.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label, {
    bool isConfirm = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isConfirm ? _obscureConfirm : _obscurePass,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            (isConfirm ? _obscureConfirm : _obscurePass)
                ? Icons.visibility_off
                : Icons.visibility,
            color: AppColors.grey,
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _obscureConfirm = !_obscureConfirm;
              } else {
                _obscurePass = !_obscurePass;
              }
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2540)
            : AppColors.surfaceContainerLow.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
