import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // ✅ الدور الافتراضي
  String _selectedRole = 'مستخدم';
  
  // ✅ مصفوفة الأدوار مدعومة بـ الهوية البصرية الموحدة لصحتك
  final List<Map<String, dynamic>> _roles = [
    {'id': 'user', 'name': 'مستخدم', 'icon': Icons.person_outline},
    {'id': 'doctor', 'name': 'طبيب', 'icon': Icons.local_hospital_outlined},
    {'id': 'pharmacist', 'name': 'صيدلي', 'icon': Icons.local_pharmacy_outlined},
    {'id': 'lab_tech', 'name': 'مخبري', 'icon': Icons.science_outlined},
    {'id': 'veterinarian', 'name': 'بيطري', 'icon': Icons.pets_outlined},
    {'id': 'paramedic', 'name': 'مسعف', 'icon': Icons.health_and_safety_outlined},
    {'id': 'delivery', 'name': 'موصل طلبات', 'icon': Icons.delivery_dining_outlined},
    {'id': 'service', 'name': 'خدمي', 'icon': Icons.support_agent_outlined},
    {'id': 'other', 'name': 'أخرى', 'icon': Icons.more_horiz_outlined},
  ];

  // ✅ الحقول المشتركة
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ✅ الحقول المخصصة للأدوار الطبية والخدمية
  final _experienceController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _licenseController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _pharmacyAddressController = TextEditingController();
  final _pharmacyLicenseController = TextEditingController();
  final _labNameController = TextEditingController();
  final _labAddressController = TextEditingController();
  final _labLicenseController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _departmentController = TextEditingController();
  final _areaController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();

  // ✅ متغيرات القوائم المنسدلة
  String _selectedSpecialty = 'باطنية';
  String _selectedGender = 'ذكر';
  String _selectedVehicleType = 'دراجة';
  String _selectedServiceType = 'خدمة عملاء';
  
  final List<String> _specialties = [
    'باطنية', 'قلبية', 'أطفال', 'نساء وولادة', 'جلدية', 'عظام',
    'أعصاب', 'أنف وأذن وحنجرة', 'عيون', 'مسالك بولية', 'جراحة عامة',
    'طب نفسي', 'علاج طبيعي', 'تغذية', 'أخرى',
  ];

  final List<String> _genders = ['ذكر', 'أنثى'];
  final List<String> _vehicleTypes = ['دراجة', 'سيارة', 'شاحنة', 'أخرى'];
  final List<String> _serviceTypes = ['خدمة عملاء', 'دعم فني', 'إداري', 'تسويق', 'أخرى'];

  bool _obscureText = true;
  bool _agreeTerms = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _hasBiometric = false;
  String _biometricName = 'البصمة';
  
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _licenseController.dispose();
    _pharmacyNameController.dispose();
    _pharmacyAddressController.dispose();
    _pharmacyLicenseController.dispose();
    _labNameController.dispose();
    _labAddressController.dispose();
    _labLicenseController.dispose();
    _hospitalController.dispose();
    _departmentController.dispose();
    _areaController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
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
        if (password != null) _passwordController.text = password;
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

  String _getRoleId(String roleName) {
    final role = _roles.firstWhere((r) => r['name'] == roleName, orElse: () => _roles.first);
    return role['id'] as String;
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

    // التحقق المخصص من الحقول المطلوبة لكل دور لمنع رفع بيانات فارغة
    if (_selectedRole == 'طبيب' && _licenseController.text.isEmpty) {
      _showMessage('يرجى إدخال رقم ترخيص مزاولة المهنة الطبي', true);
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
        'role': _getRoleId(_selectedRole),
        'roleName': _selectedRole,
        'gender': _selectedGender,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'isActive': true,
      };

      // دمج الحقول الإضافية بناءً على خيار الشبكة المختار
      switch (_selectedRole) {
        case 'طبيب':
          userData.addAll({
            'specialty': _selectedSpecialty,
            'experience': _experienceController.text.trim(),
            'clinicName': _clinicNameController.text.trim(),
            'clinicAddress': _clinicAddressController.text.trim(),
            'licenseNumber': _licenseController.text.trim(),
            'rating': 0.0,
            'reviewCount': 0,
            'isAvailable': true,
          });
          break;
        case 'صيدلي':
          userData.addAll({
            'pharmacyName': _pharmacyNameController.text.trim(),
            'pharmacyAddress': _pharmacyAddressController.text.trim(),
            'pharmacyLicense': _pharmacyLicenseController.text.trim(),
            'isAvailable': true,
          });
          break;
        case 'مخبري':
          userData.addAll({
            'labName': _labNameController.text.trim(),
            'labAddress': _labAddressController.text.trim(),
            'labLicense': _labLicenseController.text.trim(),
            'isAvailable': true,
          });
          break;
        case 'بيطري':
          userData.addAll({
            'experience': _experienceController.text.trim(),
            'clinicName': _clinicNameController.text.trim(),
            'clinicAddress': _clinicAddressController.text.trim(),
            'licenseNumber': _licenseController.text.trim(),
            'isAvailable': true,
          });
          break;
        case 'مسعف':
          userData.addAll({
            'hospital': _hospitalController.text.trim(),
            'department': _departmentController.text.trim(),
            'isAvailable': true,
          });
          break;
        case 'موصل طلبات':
          userData.addAll({
            'vehicleType': _selectedVehicleType,
            'area': _areaController.text.trim(),
            'isAvailable': true,
          });
          break;
        case 'خدمي':
          userData.addAll({
            'company': _companyController.text.trim(),
            'position': _positionController.text.trim(),
            'serviceType': _selectedServiceType,
          });
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
        _showMessage('يرجى تسجيل الدخول العادي أولاً لربط الحساب الحركي', true);
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
        content: Text(message, style: const TextStyle(fontFamily: 'NotoSansArabicUI')),
        backgroundColor: isError ? Colors.red : AppColors.primary,
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
              primaryColor.withOpacity(isDark ? 0.3 : 0.1),
              primaryColor.withOpacity(isDark ? 0.6 : 0.35),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
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
                  widget.isSignUp ? 'اختر نوع الحساب وأدخل بياناتك الطبية' : 'قم بتسجيل الدخول للمتابعة',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'NotoSansArabicUI',
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ الجزء الخاص بـ شبكة تحديد الأدوار الديناميكية (Matte Style)
                if (widget.isSignUp) ...[
                  const Text(
                    'نوع الحساب الحالي:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabicUI'),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _roles.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final role = _roles[index];
                        final isSelected = _selectedRole == role['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRole = role['name'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? fieldBackgroundColor : fieldBackgroundColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  role['icon'] as IconData,
                                  color: isSelected ? primaryColor : Colors.grey,
                                  size: 26,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  role['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? (isDark ? Colors.white : const Color(0xFF1E293B)) : Colors.grey,
                                    fontFamily: 'NotoSansArabicUI',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ✅ الحقول المشتركة
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person_outline,
                  isDark: isDark,
                  fieldBackgroundColor: fieldBackgroundColor,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  fieldBackgroundColor: fieldBackgroundColor,
                  primaryColor: primaryColor,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف المتنقل',
                  icon: Icons.phone_android,
                  isDark: isDark,
                  fieldBackgroundColor: fieldBackgroundColor,
                  primaryColor: primaryColor,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                // ✅ استدعاء الحقول الشرطية المخصصة حسب شبكة الأدوار المحددة
                if (widget.isSignUp) ...[
                  if (_selectedRole == 'طبيب') ...[
                    _buildDoctorFields(isDark, fieldBackgroundColor, primaryColor),
                  ] else if (_selectedRole == 'صيدلي') ...[
                    _buildPharmacistFields(isDark, fieldBackgroundColor, primaryColor),
                  ] else if (_selectedRole == 'مخبري') ...[
                    _buildLabTechFields(isDark, fieldBackgroundColor, primaryColor),
                  ] else if (_selectedRole == 'بيطري') ...[
                    _buildVeterinarianFields(isDark, fieldBackgroundColor, primaryColor),
                  ] else if (_selectedRole == 'مسعف') ...[
                    _buildParamedicFields(isDark, fieldBackgroundColor, primaryColor),
                  ] else if (_selectedRole == 'موصل طلبات') ...[
                    _buildDeliveryFields(isDark, fieldBackgroundColor, primaryColor),
                  ] else if (_selectedRole == 'خدمي') ...[
                    _buildServiceFields(isDark, fieldBackgroundColor, primaryColor),
                  ],
                ],

                // ✅ حقول الحماية وكلمات المرور
                _buildPasswordFields(isDark, fieldBackgroundColor, primaryColor),
                const SizedBox(height: 18),

                // ✅ الشروط والأحكام
                if (widget.isSignUp) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        activeColor: primaryColor,
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                      ),
                      const Text('أوافق على ', style: TextStyle(fontSize: 13, fontFamily: 'NotoSansArabicUI')),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
                        },
                        child: Text(
                          'الشروط والأحكام الطبية',
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

                // ✅ ميزة تذكرني في وضع الدخول
                if (!widget.isSignUp) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: primaryColor,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      ),
                      const Text('تذكرني على هذا الجهاز', style: TextStyle(fontSize: 13, fontFamily: 'NotoSansArabicUI')),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text('نسيت كلمة المرور؟', style: TextStyle(color: primaryColor, fontSize: 12, fontFamily: 'NotoSansArabicUI')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // ✅ زر الضغط الرئيسي والتنفيذي
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.isSignUp ? 'إنشاء حساب كـ $_selectedRole' : 'تسجيل الدخول المنظم',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabicUI'),
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                // ✅ خيار تصفح كضيف خارج الحساب
                if (!widget.isSignUp) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _guestLogin,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'تصفح كضيف عابر',
                        style: TextStyle(color: isDark ? Colors.white : primaryColor, fontSize: 15, fontFamily: 'NotoSansArabicUI'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ✅ التبديل السفلي التبادلي
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isSignUp ? 'لديك حساب مسجل بالفعل؟' : 'ليس لديك حساب طبي؟',
                      style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontFamily: 'NotoSansArabicUI'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => AuthScreen(isSignUp: !widget.isSignUp)),
                        );
                      },
                      child: Text(
                        widget.isSignUp ? 'سجل دخولك' : 'أنشئ حسابك الآن',
                        style: TextStyle(color: isDark ? Colors.white : primaryColor, fontWeight: FontWeight.bold, fontFamily: 'NotoSansArabicUI'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color fieldBackgroundColor,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
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
        prefixIcon: Icon(icon, color: primaryColor),
      ),
    );
  }

  Widget _buildDoctorFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedSpecialty,
          decoration: InputDecoration(
            labelText: 'التخصص الطبي الدقيق',
            labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedSpecialty = v!),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 14),
        _buildTextField(controller: _experienceController, label: 'عدد سنوات الخبرة', icon: Icons.work_outline, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor, keyboardType: TextInputType.number),
        const SizedBox(height: 14),
        _buildTextField(controller: _clinicNameController, label: 'اسم العيادة المقر', icon: Icons.apartment_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _clinicAddressController, label: 'عنوان وتفاصيل موقع العيادة', icon: Icons.location_on_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _licenseController, label: 'رقم ترخيص مزاولة المهنة المعتمد', icon: Icons.verified_user_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildPharmacistFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        _buildTextField(controller: _pharmacyNameController, label: 'اسم الصيدلية التجارية', icon: Icons.local_pharmacy_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _pharmacyAddressController, label: 'عنوان الصيدلية بالتفصيل', icon: Icons.location_on_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _pharmacyLicenseController, label: 'رقم ترخيص المنشأة الصيدلانية', icon: Icons.card_membership_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildLabTechFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        _buildTextField(controller: _labNameController, label: 'اسم معمل التحاليل / المختبر', icon: Icons.science_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _labAddressController, label: 'المقر الجغرافي للمختبر', icon: Icons.location_on_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _labLicenseController, label: 'رقم ترخيص المختبر الطبي الوطني', icon: Icons.assignment_turned_in_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildVeterinarianFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        _buildTextField(controller: _experienceController, label: 'سنوات الخبرة البيطرية', icon: Icons.timeline, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor, keyboardType: TextInputType.number),
        const SizedBox(height: 14),
        _buildTextField(controller: _clinicNameController, label: 'اسم المركز / العيادة البيطرية', icon: Icons.pets_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _clinicAddressController, label: 'عنوان المركز البيطري', icon: Icons.map_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _licenseController, label: 'رقم ترخيص المزاولة البيطرية', icon: Icons.gavel_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildParamedicFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        _buildTextField(controller: _hospitalController, label: 'جهة العمل (المستشفى أو هيئة الإسعاف)', icon: Icons.emergency_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        _buildTextField(controller: _departmentController, label: 'القسم أو الفرقة التابع لها', icon: Icons.medical_services_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildDeliveryFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedVehicleType,
          decoration: InputDecoration(
            labelText: 'وسيلة النقل المتاحة للتوصيل',
            labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          items: _vehicleTypes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => _selectedVehicleType = v!),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 14),
        _buildTextField(controller: _areaController, label: 'نطاق المربع السكني / منطقة التوصيل', icon: Icons.my_location_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildServiceFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        _buildTextField(controller: _companyController, label: 'اسم الشركة أو مؤسسة الرعاية المشغلة', icon: Icons.corporate_fare_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _selectedServiceType,
          decoration: InputDecoration(
            labelText: 'مجال الدعم والخدمة',
            labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          items: _serviceTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedServiceType = v!),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 14),
        _buildTextField(controller: _positionController, label: 'المسمى الوظيفي الإداري الكلي', icon: Icons.badge_outlined, isDark: isDark, fieldBackgroundColor: fieldBackgroundColor, primaryColor: primaryColor),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildPasswordFields(bool isDark, Color fieldBackgroundColor, Color primaryColor) {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscureText,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            labelText: 'كلمة المرور الحصينة',
            labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
            prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                if (_hasBiometric)
                  IconButton(
                    icon: Icon(_biometricName == 'Face ID' ? Icons.face_retouching_natural : Icons.fingerprint, color: primaryColor, size: 26),
                    onPressed: _loginWithBiometric,
                  ),
              ],
            ),
          ),
        ),
        if (widget.isSignUp) ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
            decoration: InputDecoration(
              labelText: 'تأكيد تطابق كلمة المرور',
              labelStyle: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14),
              filled: true,
              fillColor: fieldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
              prefixIcon: Icon(Icons.lock_clock_outlined, color: primaryColor),
            ),
          ),
        ]
      ],
    );
  }
}
