import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/roles.dart';
import 'package:sehatak/core/services/biometric_service.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  const AuthScreen({super.key, this.isSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isUserSelected = true;
  String _selectedRole = 'user';
  bool _obscureText = true;
  bool _agreeTerms = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _hasBiometric = false;
  String _biometricName = 'البصمة';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remember_email');
    final password = prefs.getString('remember_password');
    final remember = prefs.getBool('remember_me') ?? false;

    setState(() {
      _rememberMe = remember;
      if (remember && email != null) {
        _emailController.text = email;
        if (password != null) {
          _passwordController.text = password;
        }
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remember_email', _emailController.text.trim());
      await prefs.setString('remember_password', _passwordController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remember_email');
      await prefs.remove('remember_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isAvailable();
    if (available) {
      final types = await _biometricService.getAvailableTypes();
      setState(() {
        _hasBiometric = true;
        _biometricName = _biometricService.getBiometricName(types);
      });
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور', true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _saveCredentials();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ في تسجيل الدخول';
      if (e.code == 'user-not-found') message = 'المستخدم غير موجود';
      else if (e.code == 'wrong-password') message = 'كلمة المرور غير صحيحة';
      else if (e.code == 'invalid-email') message = 'البريد الإلكتروني غير صحيح';
      _showMessage(message, true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('يرجى ملء جميع الحقول المطلوبة', true);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('كلمتا المرور غير متطابقتين', true);
      return;
    }
    if (!_agreeTerms) {
      _showMessage('يرجى الموافقة على الشروط والأحكام', true);
      return;
    }

    if (_selectedRole == 'doctor' && _specialtyController.text.isEmpty) {
      _showMessage('يرجى إدخال التخصص', true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = credential.user!;
      await user.updateDisplayName(_nameController.text.trim());

      final userData = {
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      switch (_selectedRole) {
        case 'doctor':
          userData.addAll({
            'specialty': _specialtyController.text.trim(),
            'experience': _experienceController.text.trim(),
            'licenseNumber': _licenseController.text.trim(),
            'isVerified': false,
            'rating': 0.0,
            'reviewCount': 0,
            'isAvailable': true,
          });
          break;
        default:
          break;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'حدث خطأ في إنشاء الحساب';
      if (e.code == 'email-already-in-use') message = 'البريد الإلكتروني مستخدم بالفعل';
      else if (e.code == 'weak-password') message = 'كلمة المرور ضعيفة جداً';
      _showMessage(message, true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithBiometric() async {
    setState(() => _isLoading = true);
    final authenticated = await _biometricService.authenticate(
      reason: 'تسجيل الدخول باستخدام $_biometricName',
    );
    if (authenticated) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showMessage('يرجى تسجيل الدخول أولاً', true);
      }
    } else {
      _showMessage('فشل التحقق من $_biometricName', true);
    }
    setState(() => _isLoading = false);
  }

  void _guestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0B1121), const Color(0xFF1A2540)]
                : [const Color(0xFFF8FAFC), primaryColor.withOpacity(0.15)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                Text(
                  widget.isSignUp ? 'إنشاء حساب جديد' : 'مرحباً بعودتك',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontFamily: 'NotoSansArabicUI',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isSignUp
                      ? 'اختر مهنتك وأدخل بياناتك للانضمام'
                      : 'قم بتسجيل الدخول للمتابعة',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontFamily: 'NotoSansArabicUI',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                if (!widget.isSignUp) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540).withOpacity(0.5) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentTab(
                            title: 'مستخدم',
                            icon: Icons.person_outline,
                            isSelected: _isUserSelected,
                            onTap: () => setState(() => _isUserSelected = true),
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentTab(
                            title: 'طبيب',
                            icon: Icons.local_hospital_outlined,
                            isSelected: !_isUserSelected,
                            onTap: () => setState(() => _isUserSelected = false),
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                ],

                if (widget.isSignUp) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540).withOpacity(0.5) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppRoles.all.map((role) {
                          final isSelected = _selectedRole == role['id'];
                          final color = Color(role['color'] as int);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedRole = role['id'] as String),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(role['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      role['name'] as String,
                                      style: TextStyle(
                                        color: isSelected ? color : Colors.grey,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontFamily: 'NotoSansArabicUI',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                if (widget.isSignUp) ...[
                  _buildTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    icon: Icons.person_outline,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  controller: _emailController,
                  label: widget.isSignUp ? 'البريد الإلكتروني' : 'رقم الموبيل أو البريد الإلكتروني',
                  icon: Icons.alternate_email_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                if (widget.isSignUp) ...[
                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_android,
                    isDark: isDark,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                ],

                if (widget.isSignUp && _selectedRole == 'doctor') ...[
                  _buildTextField(
                    controller: _specialtyController,
                    label: 'التخصص',
                    icon: Icons.medical_services_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _experienceController,
                    label: 'سنوات الخبرة',
                    icon: Icons.work_outline,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _licenseController,
                    label: 'رقم الترخيص',
                    icon: Icons.verified_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ حقل كلمة المرور - بدون البصمة في إنشاء الحساب
                _buildPasswordField(isDark, primaryColor),
                const SizedBox(height: 16),

                if (widget.isSignUp) ...[
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                ],

                if (!widget.isSignUp) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (v) => setState(() => _rememberMe = v ?? false),
                            activeColor: primaryColor,
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            'تذكرني على هذا الجهاز',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                              fontFamily: 'NotoSansArabicUI',
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            fontSize: 13,
                            color: primaryColor,
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                if (widget.isSignUp) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                        activeColor: primaryColor,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        'أوافق على ',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontFamily: 'NotoSansArabicUI',
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
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (widget.isSignUp ? _register : _login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isSignUp
                                ? 'إنشاء حساب'
                                : (_isUserSelected ? 'تسجيل الدخول كـ عميل' : 'تسجيل الدخول كـ طبيب'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansArabicUI',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                if (!widget.isSignUp) ...[
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _guestLogin,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? Colors.white30 : Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                      child: const Text(
                        'تصفح كضيف',
                        style: TextStyle(fontSize: 15, fontFamily: 'NotoSansArabicUI'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'أو سجل الدخول عبر',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'NotoSansArabicUI'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        onTap: () {},
                        isDark: isDark,
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.apple,
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isSignUp ? 'لديك حساب بالفعل؟' : 'ليس لديك حساب؟',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontFamily: 'NotoSansArabicUI',
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuthScreen(isSignUp: !widget.isSignUp),
                          ),
                        );
                      },
                      child: Text(
                        widget.isSignUp ? 'تسجيل الدخول' : 'أنشئ حسابك الآن',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'NotoSansArabicUI',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey,
                fontSize: 14,
                fontFamily: 'NotoSansArabicUI',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    final primaryColor = const Color(0xFF0D5257);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[600],
          fontFamily: 'NotoSansArabicUI',
        ),
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : primaryColor),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildPasswordField(bool isDark, Color primaryColor) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      textAlign: TextAlign.right,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[600],
          fontFamily: 'NotoSansArabicUI',
        ),
        prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : primaryColor),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            // ✅ زر البصمة يظهر فقط في تسجيل الدخول (ليس في إنشاء الحساب)
            if (_hasBiometric && !widget.isSignUp)
              IconButton(
                icon: Icon(Icons.fingerprint, color: primaryColor),
                onPressed: _loginWithBiometric,
              ),
          ],
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white30 : Colors.grey[300]!,
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
