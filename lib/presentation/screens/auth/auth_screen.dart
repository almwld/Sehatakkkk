import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:sehatak/presentation/screens/auth/forgot_password_screen.dart';

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
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  // ✅ State variables
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _agreeTerms = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _hasBiometric = false;
  String _biometricName = 'البصمة';
  String _selectedRole = 'user';
  String? _selectedSpecialty;
  bool _showAdminTab = false;
  bool _isFirstTimeUser = false;

  // ✅ قوة كلمة المرور
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;
  double _passwordStrengthValue = 0.0;

  // ✅ Primary roles
  final List<Map<String, dynamic>> _primaryRoles = [
    {'id': 'user', 'name': 'مستخدم', 'icon': Icons.person_outline, 'color': 0xFF0D5257},
    {'id': 'doctor', 'name': 'طبيب', 'icon': Icons.local_hospital_outlined, 'color': 0xFF2196F3},
  ];

  // ✅ Secondary roles
  final List<Map<String, dynamic>> _secondaryRoles = [
    {'id': 'nurse', 'name': 'ممرض', 'icon': Icons.medical_services_outlined, 'color': 0xFF00BCD4},
    {'id': 'midwife', 'name': 'قابلة وتوليد', 'icon': Icons.pregnant_woman, 'color': 0xFFE91E63},
    {'id': 'physiotherapist', 'name': 'علاج فيزيائي', 'icon': Icons.fitness_center, 'color': 0xFFFF9800},
    {'id': 'pharmacist', 'name': 'صيدلي', 'icon': Icons.local_pharmacy_outlined, 'color': 0xFF4CAF50},
    {'id': 'lab', 'name': 'مختبر', 'icon': Icons.science_outlined, 'color': 0xFF9C27B0},
    {'id': 'paramedic', 'name': 'مسعف', 'icon': Icons.emergency, 'color': 0xFFF44336},
    {'id': 'delivery', 'name': 'موصل طلبات', 'icon': Icons.delivery_dining, 'color': 0xFFFF5722},
    {'id': 'service', 'name': 'خدمي', 'icon': Icons.handyman, 'color': 0xFF607D8B},
    {'id': 'admin', 'name': 'مشرف', 'icon': Icons.admin_panel_settings, 'color': 0xFFFF5722},
  ];

  // ✅ All roles
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
    {'id': 'admin', 'name': 'مشرف', 'icon': Icons.admin_panel_settings, 'color': 0xFFFF5722},
  ];

  // ✅ أيقونات السوشيال ميديا - بنفس نظام الدفع
  final List<Map<String, dynamic>> _socialIcons = [
    {'id': 'google', 'name': 'Google', 'icon': 'assets/images/social/google.png', 'color': Colors.red},
    {'id': 'apple', 'name': 'Apple', 'icon': 'assets/images/social/apple.png', 'color': Colors.black},
    {'id': 'facebook', 'name': 'Facebook', 'icon': 'assets/images/social/facebook.png', 'color': Colors.blue.shade700},
    {'id': 'instagram', 'name': 'Instagram', 'icon': 'assets/images/social/instagram.png', 'color': Colors.purple.shade700},
    {'id': 'twitter', 'name': 'Twitter', 'icon': 'assets/images/social/x_twitter.png', 'color': Colors.blue.shade600},
    {'id': 'youtube', 'name': 'YouTube', 'icon': 'assets/images/social/youtube.png', 'color': Colors.red.shade700},
    {'id': 'tiktok', 'name': 'TikTok', 'icon': 'assets/images/social/tiktok.png', 'color': Colors.black},
  ];

  List<String> get _roleSpecialties {
    return MedicalSpecialties.getSpecialtiesForRole(_selectedRole);
  }

  final BiometricService _biometricService = BiometricService();

  // ✅ دالة التحقق من قوة كلمة المرور
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
        _passwordStrengthValue = 0.0;
      });
      return;
    }

    int score = 0;
    bool hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowerCase = RegExp(r'[a-z]').hasMatch(password);

    if (password.length >= 8) score++;
    if (hasLetters) score++;
    if (hasNumbers) score++;
    if (hasSpecial) score++;
    if (hasUpperCase && hasLowerCase) score++;
    if (password.length >= 12) score++;

    if (score <= 1) {
      setState(() {
        _passwordStrength = 'ضعيفة جداً';
        _passwordStrengthColor = Colors.red;
        _passwordStrengthValue = 0.1;
      });
    } else if (score <= 2) {
      setState(() {
        _passwordStrength = 'ضعيفة';
        _passwordStrengthColor = Colors.orange;
        _passwordStrengthValue = 0.3;
      });
    } else if (score <= 3) {
      setState(() {
        _passwordStrength = 'متوسطة';
        _passwordStrengthColor = Colors.blue;
        _passwordStrengthValue = 0.5;
      });
    } else if (score <= 4) {
      setState(() {
        _passwordStrength = 'جيدة';
        _passwordStrengthColor = Colors.teal;
        _passwordStrengthValue = 0.7;
      });
    } else {
      setState(() {
        _passwordStrength = 'قوية جداً';
        _passwordStrengthColor = Colors.green;
        _passwordStrengthValue = 0.9;
      });
    }
  }

  bool _isPasswordMatch() {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      return false;
    }
    return _passwordController.text == _confirmPasswordController.text;
  }

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _checkBiometric();
    _loadSavedCredentials();
    _checkAdminStatus();
    
    _passwordController.addListener(() {
      _checkPasswordStrength(_passwordController.text);
      if (mounted) setState(() {});
    });
    _confirmPasswordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool('is_first_time') ?? true;
    if (isFirst) {
      await prefs.setBool('is_first_time', false);
    }
    if (mounted) {
      setState(() => _isFirstTimeUser = isFirst);
    }
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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

  bool _needsVerification(String role) {
    return role == 'doctor' || role == 'pharmacist' || role == 'lab';
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          ),
        ),
      ),
    );
  }

  void _hideLoading() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _showSuccessAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: const Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور', true);
      return;
    }

    _showLoading();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _saveCredentials();

      _hideLoading();
      await _showSuccessAnimation();

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
      _hideLoading();
      String message = 'حدث خطأ في تسجيل الدخول';
      if (e.code == 'user-not-found') message = 'المستخدم غير موجود';
      else if (e.code == 'wrong-password') message = 'كلمة المرور غير صحيحة';
      else if (e.code == 'invalid-email') message = 'البريد الإلكتروني غير صحيح';
      _showMessage(message, true);
    } catch (e) {
      _hideLoading();
      _showMessage('حدث خطأ غير متوقع', true);
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

    if (_passwordStrengthValue < 0.3) {
      _showMessage('كلمة المرور ضعيفة جداً، يرجى اختيار كلمة مرور أقوى', true);
      return;
    }

    if (_roleSpecialties.isNotEmpty && _selectedSpecialty == null) {
      _showMessage('يرجى اختيار التخصص', true);
      return;
    }

    _showLoading();
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
      final userModel = UserModel.fromFirestore(userData, user.uid);
      _showOnboarding(userModel);

      _hideLoading();
      await _showSuccessAnimation();

      if (mounted) {
        final userModel = UserModel.fromFirestore(userData, user.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleOnboardingScreen(
              role: _getUserRole(_selectedRole),
              onComplete: () {
                if (_needsVerification(_selectedRole)) {
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
      _hideLoading();
      String message = 'حدث خطأ في إنشاء الحساب';
      if (e.code == 'email-already-in-use') message = 'البريد الإلكتروني مستخدم بالفعل';
      else if (e.code == 'weak-password') message = 'كلمة المرور ضعيفة جداً';
      _showMessage(message, true);
    } catch (e) {
      _hideLoading();
      _showMessage('حدث خطأ غير متوقع', true);
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
      default: return UserRole.user;
    }
  }

  Future<void> _loginWithBiometric() async {
    _showLoading();
    final authenticated = await _biometricService.authenticate(
      reason: 'تسجيل الدخول باستخدام $_biometricName',
    );
    _hideLoading();
    if (authenticated) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _showSuccessAnimation();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        _showMessage('يرجى تسجيل الدخول أولاً', true);
      }
    } else {
      _showMessage('فشل التحقق من $_biometricName', true);
    }
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ============================================================
  // ✅ أيقونات السوشيال ميديا - بنفس نظام الدفع
  // ============================================================
  Widget _buildSocialIcon(Map<String, dynamic> social, bool isDark) {
    final fallbackIcons = {
      'google': Icons.g_mobiledata,
      'apple': Icons.apple,
      'facebook': Icons.facebook,
      'instagram': Icons.photo_camera,
      'twitter': Icons.timeline,
      'youtube': Icons.youtube_searched_for,
      'tiktok': Icons.music_note,
    };

    return InkWell(
      onTap: () => _launchUrl('https://www.${social['id']}.com'),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white30 : Colors.grey[300]!,
            width: 1.5,
          ),
          color: isDark ? Colors.transparent : Colors.white,
        ),
        child: Image.asset(
          social['icon'] as String,
          width: 30,
          height: 30,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              fallbackIcons[social['id']] ?? Icons.circle,
              color: social['color'] as Color,
              size: 36,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // 🔧 دوال البناء
  // ============================================================

  Widget _buildSignUpRoleTabs(bool isDark, Color primaryColor) {
    final scrollableRoles = _showAdminTab
        ? _allRoles.where((r) => r['id'] != 'admin').toList().sublist(2)
        : _secondaryRoles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540).withOpacity(0.5) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: _primaryRoles.map((role) {
              final isSelected = _selectedRole == role['id'];
              final color = Color(role['color'] as int);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = role['id'] as String;
                      _selectedSpecialty = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(role['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          role['name'] as String,
                          style: TextStyle(
                            color: isSelected ? color : Colors.grey,
                            fontSize: 14,
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

        if (scrollableRoles.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: scrollableRoles.length,
              itemBuilder: (context, index) {
                final role = scrollableRoles[index];
                final isSelected = _selectedRole == role['id'];
                final color = Color(role['color'] as int);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRole = role['id'] as String;
                        _selectedSpecialty = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(role['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 16),
                          const SizedBox(width: 6),
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
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginRoleTabs(bool isDark, Color primaryColor) {
    return Container(
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
              isSelected: _selectedRole == 'user',
              onTap: () => setState(() => _selectedRole = 'user'),
              isDark: isDark,
              primaryColor: primaryColor,
            ),
          ),
          Expanded(
            child: _buildSegmentTab(
              title: 'طبيب',
              icon: Icons.local_hospital_outlined,
              isSelected: _selectedRole == 'doctor',
              onTap: () => setState(() => _selectedRole = 'doctor'),
              isDark: isDark,
              primaryColor: primaryColor,
            ),
          ),
        ],
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

  Widget _buildSelectedRoleDisplay(bool isDark, Color primaryColor) {
    final role = _allRoles.firstWhere(
      (r) => r['id'] == _selectedRole,
      orElse: () => _allRoles.first,
    );
    final color = Color(role['color'] as int);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(role['icon'] as IconData, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              'الدور المختار: ${role['name']}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'NotoSansArabicUI',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyDropdown(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر تخصصك',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey[700],
            fontFamily: 'NotoSansArabicUI',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selectedSpecialty != null ? primaryColor : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              width: _selectedSpecialty != null ? 2 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedSpecialty,
              hint: Row(
                children: [
                  Icon(Icons.medical_services_outlined, color: isDark ? Colors.white70 : primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'اختر التخصص',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontFamily: 'NotoSansArabicUI',
                    ),
                  ),
                ],
              ),
              icon: Icon(Icons.arrow_drop_down, color: primaryColor),
              dropdownColor: isDark ? const Color(0xFF1A2540) : Colors.white,
              items: _roleSpecialties.map((specialty) {
                return DropdownMenuItem<String>(
                  value: specialty,
                  child: Row(
                    children: [
                      Icon(Icons.medical_services_outlined, color: primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontFamily: 'NotoSansArabicUI',
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedSpecialty = v),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicFields(bool isDark, Color primaryColor) {
    final fields = <Widget>[];

    if (_needsVerification(_selectedRole)) {
      fields.add(_buildTextField(
        controller: _licenseController,
        label: 'رقم الترخيص المهني',
        icon: Icons.verified_outlined,
        isDark: isDark,
      ));
      fields.add(const SizedBox(height: 16));
    }

    if (_selectedRole == 'doctor') {
      fields.add(_buildTextField(
        controller: _experienceController,
        label: 'سنوات الخبرة',
        icon: Icons.work_outline,
        isDark: isDark,
        keyboardType: TextInputType.number,
      ));
      fields.add(const SizedBox(height: 16));
    }

    return fields;
  }

  String _getRoleDisplayName(String roleId) {
    final role = _allRoles.firstWhere(
      (r) => r['id'] == roleId,
      orElse: () => {'name': ''},
    );
    return role['name'] as String;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
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
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF0D5257)),
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
          borderSide: BorderSide(color: const Color(0xFF0D5257), width: 2),
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

  Widget _buildPasswordStrengthIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: _passwordStrengthValue,
                child: Container(
                  decoration: BoxDecoration(
                    color: _passwordStrengthColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _passwordStrength,
              style: TextStyle(
                color: _passwordStrengthColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansArabicUI',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'كلمة المرور يجب أن تحتوي على حروف وأرقام وأحرف خاصة',
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            fontFamily: 'NotoSansArabicUI',
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(bool isDark, Color primaryColor) {
    final isMatch = _isPasswordMatch();
    final showMatch = _confirmPasswordController.text.isNotEmpty;

    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmText,
      textAlign: TextAlign.right,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[600],
          fontFamily: 'NotoSansArabicUI',
        ),
        prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : primaryColor),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMatch)
              Icon(
                isMatch ? Icons.check_circle : Icons.cancel,
                color: isMatch ? Colors.green : Colors.red,
                size: 20,
              ),
            IconButton(
              icon: Icon(
                _obscureConfirmText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
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
                  isSignUp
                      ? 'إنشاء حساب جديد'
                      : (_isFirstTimeUser ? 'أهلاً بك في منصة صحتك' : 'مرحباً بعودتك'),
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

                if (!isSignUp) ...[
                  _buildLoginRoleTabs(isDark, primaryColor),
                  const SizedBox(height: 35),
                ],

                if (isSignUp) ...[
                  _buildSignUpRoleTabs(isDark, primaryColor),
                  const SizedBox(height: 16),
                  _buildSelectedRoleDisplay(isDark, primaryColor),
                  const SizedBox(height: 16),
                ],

                if (isSignUp && _roleSpecialties.isNotEmpty) ...[
                  _buildSpecialtyDropdown(isDark, primaryColor),
                  const SizedBox(height: 16),
                ],

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

                if (isSignUp) ...[
                  ..._buildDynamicFields(isDark, primaryColor),
                ],

                _buildPasswordField(isDark, primaryColor),
                if (isSignUp && _passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildPasswordStrengthIndicator(),
                ],
                const SizedBox(height: 16),

                if (isSignUp) ...[
                  _buildConfirmPasswordField(isDark, primaryColor),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
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
                  height: 64,
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
                    child: Text(
                      isSignUp
                          ? 'إنشاء حساب ${_getRoleDisplayName(_selectedRole)}'
                          : 'تسجيل الدخول',
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

                  // ✅ أيقونات السوشيال ميديا - صف أول (Google, Apple)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(_socialIcons[0], isDark), // Google
                      const SizedBox(width: 20),
                      _buildSocialIcon(_socialIcons[1], isDark), // Apple
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'منصة شاملة تجمع كل ما يهم صحتك في آن واحد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D5257),
                      fontFamily: 'NotoSansArabicUI',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ندعم جميع خدمات الرعاية الصحية المتكاملة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'NotoSansArabicUI',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // ✅ أيقونات السوشيال ميديا - صف ثاني (Facebook, Instagram, Twitter, YouTube, TikTok)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(_socialIcons[2], isDark), // Facebook
                      const SizedBox(width: 10),
                      _buildSocialIcon(_socialIcons[3], isDark), // Instagram
                      const SizedBox(width: 10),
                      _buildSocialIcon(_socialIcons[4], isDark), // Twitter
                      const SizedBox(width: 10),
                      _buildSocialIcon(_socialIcons[5], isDark), // YouTube
                      const SizedBox(width: 10),
                      _buildSocialIcon(_socialIcons[6], isDark), // TikTok
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
}
import 'package:sehatak/presentation/screens/onboarding/role_onboarding_screen.dart';
import 'package:sehatak/presentation/screens/verification/verification_screen.dart';

  // ✅ عرض الشاشة التعليمية بعد التسجيل
  void _showOnboarding(UserModel userModel) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RoleOnboardingScreen(
          role: userModel.role,
          specialty: userModel.specialty,
          onComplete: () {
            // ✅ بعد انتهاء الشاشة التعليمية
            if (AppRoles.needsVerification(userModel.role)) {
              // ✅ إذا كان الدور يحتاج توثيق
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => VerificationScreen(userModel: userModel),
                ),
              );
            } else {
              // ✅ الانتقال للرئيسية
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
