import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
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
  bool _obscureText = true;
  bool _loginOffline = false;
  bool _agreeTerms = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _hasBiometric = false;
  String _biometricName = 'البصمة';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
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

  Future<void> _handleAuth() async {
    if (widget.isSignUp) {
      await _register();
    } else {
      await _login();
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
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('كلمتا المرور غير متطابقتين', true);
      return;
    }
    if (!_agreeTerms) {
      _showMessage('يرجى الموافقة على الشروط والأحكام', true);
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
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _isUserSelected ? 'user' : 'doctor',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    final backgroundColor1 = isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC);
    final fieldBackgroundColor = isDark ? const Color(0xFF1A2540) : Colors.white;
    final inactiveTabColor = isDark ? const Color(0xFF111827) : const Color(0xFFE2E8F0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor1,
              primaryColor.withOpacity(isDark ? 0.4 : 0.15),
              primaryColor.withOpacity(isDark ? 0.7 : 0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // ✅ الهيدر والترحيب
                Text(
                  widget.isSignUp ? 'إنشاء حساب جديد' : 'مرحباً بعودتك',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansArabicUI',
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isSignUp ? 'أدخل بياناتك للانضمام إلى منصتنا' : 'قم بتسجيل الدخول للمتابعة',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NotoSansArabicUI',
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 35),

                // ✅ خانات تحديد نوع الحساب (مستخدم / طبيب)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isUserSelected = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isUserSelected ? fieldBackgroundColor : inactiveTabColor,
                            borderRadius: BorderRadius.circular(16),
                            border: _isUserSelected 
                                ? Border.all(color: primaryColor, width: 2)
                                : Border.all(color: Colors.transparent, width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: _isUserSelected ? primaryColor : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'مستخدم',
                                style: TextStyle(
                                  fontWeight: _isUserSelected ? FontWeight.bold : FontWeight.normal,
                                  fontFamily: 'NotoSansArabicUI',
                                  color: _isUserSelected ? (isDark ? Colors.white : const Color(0xFF1E293B)) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isUserSelected = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isUserSelected ? fieldBackgroundColor : inactiveTabColor,
                            borderRadius: BorderRadius.circular(16),
                            border: !_isUserSelected 
                                ? Border.all(color: primaryColor, width: 2)
                                : Border.all(color: Colors.transparent, width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_hospital_outlined,
                                color: !_isUserSelected ? primaryColor : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'طبيب',
                                style: TextStyle(
                                  fontWeight: !_isUserSelected ? FontWeight.bold : FontWeight.normal,
                                  fontFamily: 'NotoSansArabicUI',
                                  color: !_isUserSelected ? (isDark ? Colors.white : const Color(0xFF1E293B)) : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // ✅ حقل البريد الإلكتروني (أو رقم الموبايل)
                if (widget.isSignUp) ...[
                  TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل',
                      labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
                      filled: true,
                      fillColor: fieldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    labelText: widget.isSignUp ? 'البريد الإلكتروني' : 'البريد الإلكتروني أو رقم الموبايل',
                    labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
                    filled: true,
                    fillColor: fieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),

                if (widget.isSignUp) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
                      filled: true,
                      fillColor: fieldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ حقل كلمة المرور مع البصمة
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  textAlign: TextAlign.right,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
                    filled: true,
                    fillColor: fieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                            color: isDark ? Colors.white70 : Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                        if (_hasBiometric)
                          IconButton(
                            icon: Icon(
                              _biometricName == 'Face ID' ? Icons.face : Icons.fingerprint,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            onPressed: _loginWithBiometric,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (widget.isSignUp) ...[
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
                      filled: true,
                      fillColor: fieldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ الموافقة على الشروط والأحكام (للتسجيل فقط)
                if (widget.isSignUp) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                      ),
                      const Text(
                        'أوافق على ',
                        style: TextStyle(fontSize: 13),
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
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ تذكرني (للدخول فقط)
                if (!widget.isSignUp) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      ),
                      const Text(
                        'تذكرني',
                        style: TextStyle(fontSize: 13),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // ✅ زر الإجراء الرئيسي
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
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
                                ? (_isUserSelected ? 'إنشاء حساب' : 'إنشاء حساب طبيب')
                                : 'تسجيل الدخول',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansArabicUI',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ زر تصفح كضيف (للدخول فقط)
                if (!widget.isSignUp) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _guestLogin,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تصفح كضيف',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'NotoSansArabicUI',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ التنقل بين الشاشتين
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isSignUp ? 'لديك حساب بالفعل؟' : 'ليس لديك حساب؟',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        fontFamily: 'NotoSansArabicUI',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuthScreen(isSignUp: !widget.isSignUp),
                          ),
                        );
                      },
                      child: Text(
                        widget.isSignUp ? 'تسجيل الدخول' : 'إنشاء حساب',
                        style: TextStyle(
                          color: isDark ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
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
}
