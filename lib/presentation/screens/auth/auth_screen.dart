import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/roles.dart';
import 'package:sehatak/core/constants/medical_specialties.dart';
import 'package:sehatak/core/models/user_model.dart';
import 'package:sehatak/core/services/biometric_service.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';
import 'package:sehatak/presentation/screens/onboarding/role_onboarding_screen.dart';
import 'package:sehatak/presentation/screens/verification/verification_screen.dart';
import 'package:sehatak/presentation/screens/platform/dashboard/platform_dashboard.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  const AuthScreen({super.key, this.isSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  // ✅ Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  // ✅ متغيرات الحالة
  bool _obscureText = true;
  bool _agreeTerms = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _hasBiometric = false;
  String _biometricName = 'البصمة';
  String _selectedRole = 'user';
  String? _selectedSpecialty;
  bool _showAdminTab = false;
  bool _showAllSpecialties = false;

  // ✅ قائمة الأدوار
  final List<Map<String, dynamic>> _allRoles = [
    {'id': 'user', 'name': 'مستخدم', 'icon': Icons.person_outline, 'color': 0xFF0D5257},
    {'id': 'doctor', 'name': 'طبيب', 'icon': Icons.local_hospital_outlined, 'color': 0xFF2196F3},
    {'id': 'nurse', 'name': 'ممرض', 'icon': Icons.medical_services_outlined, 'color': 0xFF00BCD4},
    {'id': 'midwife', 'name': 'قابلة وتوليد', 'icon': Icons.pregnant_woman, 'color': 0xFFE91E63},
    {'id': 'physiotherapist', 'name': 'علاج فيزيائي', 'icon': Icons.fitness_center, 'color': 0xFFFF9800},
    {'id': 'pharmacist', 'name': 'صيدلي', 'icon': Icons.local_pharmacy_outlined, 'color': 0xFF4CAF50},
    {'id': 'lab', 'name': 'مختبر', 'icon': Icons.science_outlined, 'color': 0xFF9C27B0},
    {'id': 'paramedic', 'name': 'مسعف', 'icon': Icons.emergency, 'color': 0xFFF44336},
    {'id': 'delivery', 'name': 'موصل طلبات', 'icon': Icons.delivery_dining, 'color': 0xFFFF5722},
    {'id': 'service', 'name': 'خدمي', 'icon': Icons.handyman, 'color': 0xFF607D8B},
    {'id': 'veterinarian', 'name': 'بيطري', 'icon': Icons.pets, 'color': 0xFF795548},
    {'id': 'admin', 'name': 'مشرف', 'icon': Icons.admin_panel_settings, 'color': 0xFFFF5722},
  ];

  List<Map<String, dynamic>> get _availableRoles {
    if (_showAdminTab) return _allRoles;
    return _allRoles.where((role) => role['id'] != 'admin').toList();
  }

  List<String> get _roleSpecialties {
    return MedicalSpecialties.getSpecialtiesForRole(_selectedRole);
  }

  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _loadSavedCredentials();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final role = doc.data()?['role'] ?? 'user';
          if (role == 'admin' || role == 'superAdmin') {
            setState(() => _showAdminTab = true);
          }
        }
      } catch (e) {}
    }
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
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final role = doc.data()?['role'] ?? 'user';
          if (role == 'admin' || role == 'superAdmin') {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PlatformDashboard()),
              );
            }
            return;
          }
        }
      }
      
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

    if (_selectedRole == 'doctor' && _selectedSpecialty == null) {
      _showMessage('يرجى اختيار التخصص', true);
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
        'specialty': _selectedSpecialty,
        'licenseNumber': _licenseController.text.trim(),
        'experience': _experienceController.text.trim(),
        'isVerified': false,
        'verificationStatus': 'notSubmitted',
        'rating': 0.0,
        'reviewCount': 0,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);

      if (mounted) {
        final userModel = UserModel.fromFirestore(userData, user.uid);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleOnboardingScreen(
              role: _getUserRole(_selectedRole),
              onComplete: () {
                // ✅ التحقق من الحاجة للتوثيق
                if (AppRoles.needsVerification(_selectedRole)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerificationScreen(userModel: userModel),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              },
            ),
          ),
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

  UserRole _getUserRole(String roleId) {
    switch (roleId) {
      case 'doctor': return UserRole.doctor;
      case 'nurse': return UserRole.doctor;
      case 'midwife': return UserRole.doctor;
      case 'physiotherapist': return UserRole.doctor;
      case 'pharmacist': return UserRole.pharmacist;
      case 'lab': return UserRole.lab;
      case 'paramedic': return UserRole.doctor;
      case 'veterinarian': return UserRole.veterinarian;
      default: return UserRole.user;
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
    final isSignUp = widget.isSignUp;

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
                  isSignUp ? 'إنشاء حساب جديد' : 'مرحباً بعودتك',
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
                  isSignUp
                      ? 'اختر نوع حسابك وأدخل بياناتك للانضمام'
                      : 'قم بتسجيل الدخول للمتابعة',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontFamily: 'NotoSansArabicUI',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // ✅ اختيار الدور (للتسجيل فقط)
                if (isSignUp) ...[
                  _buildRoleSelector(isDark, primaryColor),
                  const SizedBox(height: 20),
                ],

                // ✅ اختيار التخصص
                if (isSignUp && _roleSpecialties.isNotEmpty) ...[
                  _buildSpecialtySelector(isDark, primaryColor),
                  const SizedBox(height: 16),
                ],

                // ✅ الحقول
                if (isSignUp) ...[
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
                  label: isSignUp ? 'البريد الإلكتروني' : 'رقم الموبايل أو البريد الإلكتروني',
                  icon: Icons.alternate_email_outlined,
                  isDark: isDark,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                if (isSignUp) ...[
                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_android,
                    isDark: isDark,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                ],

                if (isSignUp && AppRoles.needsVerification(_selectedRole)) ...[
                  _buildTextField(
                    controller: _licenseController,
                    label: 'رقم الترخيص المهني',
                    icon: Icons.verified_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                ],

                if (isSignUp && _selectedRole == 'doctor') ...[
                  _buildTextField(
                    controller: _experienceController,
                    label: 'سنوات الخبرة',
                    icon: Icons.work_outline,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildPasswordField(isDark, primaryColor),
                const SizedBox(height: 16),

                if (isSignUp) ...[
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                ],

                if (!isSignUp) ...[
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

                if (isSignUp) ...[
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
                    onPressed: _isLoading ? null : (isSignUp ? _register : _login),
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
                            isSignUp
                                ? 'إنشاء حساب'
                                : (_selectedRole == 'admin' || _selectedRole == 'superAdmin' 
                                    ? 'تسجيل الدخول كمشرف' 
                                    : 'تسجيل الدخول'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NotoSansArabicUI',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                if (!isSignUp) ...[
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
                      isSignUp ? 'لديك حساب بالفعل؟' : 'ليس لديك حساب؟',
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
                            builder: (_) => AuthScreen(isSignUp: !isSignUp),
                          ),
                        );
                      },
                      child: Text(
                        isSignUp ? 'تسجيل الدخول' : 'أنشئ حسابك الآن',
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

  // ✅ منتقي الدور
  Widget _buildRoleSelector(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540).withOpacity(0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _availableRoles.map((role) {
            final isSelected = _selectedRole == role['id'];
            final color = Color(role['color'] as int);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = role['id'] as String;
                    _selectedSpecialty = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        role['icon'] as IconData,
                        color: isSelected ? color : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        role['name'] as String,
                        style: TextStyle(
                          color: isSelected ? color : Colors.grey,
                          fontSize: 11,
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
    );
  }

  // ✅ منتقي التخصص
  Widget _buildSpecialtySelector(bool isDark, Color primaryColor) {
    final specialties = _roleSpecialties;
    
    if (specialties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedRole == 'doctor' ? 'اختر تخصصك الطبي' : 'اختر مجال عملك',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey[700],
            fontFamily: 'NotoSansArabicUI',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540).withOpacity(0.3) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllSpecialties = !_showAllSpecialties;
                      if (!_showAllSpecialties) {
                        _selectedSpecialty = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _showAllSpecialties 
                          ? primaryColor.withOpacity(0.15) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showAllSpecialties ? primaryColor : Colors.grey,
                        width: _showAllSpecialties ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.list, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'جميع التخصصات',
                          style: TextStyle(
                            fontSize: 11,
                            color: _showAllSpecialties ? primaryColor : Colors.grey,
                            fontWeight: _showAllSpecialties ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...(_showAllSpecialties ? MedicalSpecialties.all : specialties).map((specialty) {
                  final isSelected = _selectedSpecialty == specialty;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpecialty = specialty;
                        _showAllSpecialties = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.grey[700]),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'NotoSansArabicUI',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
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
          borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
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
          borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
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
