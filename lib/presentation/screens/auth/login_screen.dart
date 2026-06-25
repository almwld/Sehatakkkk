import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/biometric_service.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/auth/register_screen.dart';
import 'package:sehatak/presentation/screens/auth/terms_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool _rememberMe = false;
  bool _usePhoneLogin = false;
  
  bool _obscure = true;
  final BiometricService _bio = BiometricService();
  bool _hasBiometric = false;
  String _bioName = 'البصمة';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final a = await _bio.isAvailable();
    if (a) {
      final t = await _bio.getAvailableTypes();
      setState(() {
        _hasBiometric = true;
        _bioName = _bio.getBiometricName(t);
      });
    }
  }

  void _guest() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (r) => false,
  );

  void _login() {
    if (_usePhoneLogin) {
      if (_phone.text.isEmpty || _pass.text.isEmpty) {
        _showMsg('املأ الحقول', true);
        return;
      }
      context.read<AuthBloc>().add(
        LoginWithPhone(
          phone: _phone.text.trim(),
          password: _pass.text.trim(),
        ),
      );
    } else {
      if (_email.text.isEmpty || _pass.text.isEmpty) {
        _showMsg('املأ الحقول', true);
        return;
      }
      context.read<AuthBloc>().add(
        LoginWithEmail(
          email: _email.text.trim(),
          password: _pass.text.trim(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, s) {
        if (s is Authenticated) {
          Navigator.of(ctx).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, a, __, ch) => FadeTransition(opacity: a, child: ch),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (r) => false,
          );
        }
        if (s is AuthError) _showMsg(s.message, true);
      },
      builder: (ctx, s) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: d
                  ? [const Color(0xFF0B1121), const Color(0xFF1A2540)]
                  : AppColors.primaryGradient,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 38,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'صحتك',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: d ? const Color(0xFF1A2540) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ TabBar
                          Container(
                            margin: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: d ? const Color(0xFF0B1121) : Colors.grey[100],
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
                                Tab(text: 'تسجيل الدخول'),
                                Tab(text: 'إنشاء حساب'),
                              ],
                            ),
                          ),
                          
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: _tabCtrl.index == 0 ? 400 : 300,
                            child: TabBarView(
                              controller: _tabCtrl,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // ✅ تبويب تسجيل الدخول
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      // ✅ تبديل بين الإيميل والهاتف
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(() => _usePhoneLogin = false),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: !_usePhoneLogin ? AppColors.primary : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'البريد الإلكتروني',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: !_usePhoneLogin ? Colors.white : AppColors.grey,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(() => _usePhoneLogin = true),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: _usePhoneLogin ? AppColors.primary : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'رقم الهاتف',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: _usePhoneLogin ? Colors.white : AppColors.grey,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // ✅ حقل البريد أو الهاتف
                                      if (!_usePhoneLogin)
                                        TextField(
                                          controller: _email,
                                          textAlign: TextAlign.right,
                                          decoration: InputDecoration(
                                            labelText: 'البريد الإلكتروني',
                                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                        )
                                      else
                                        TextField(
                                          controller: _phone,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelText: 'رقم الهاتف',
                                            prefixIcon: const Icon(Icons.phone_android, size: 20),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      
                                      TextField(
                                        controller: _pass,
                                        obscureText: _obscure,
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          labelText: 'كلمة المرور',
                                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                            onPressed: () => setState(() => _obscure = !_obscure),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                      
                                      // ✅ تذكرني
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            activeColor: AppColors.primary,
                                            onChanged: (v) => setState(() => _rememberMe = v!),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                              style: TextStyle(fontSize: 12, color: AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: ElevatedButton(
                                          onPressed: s is AuthLoading ? null : _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: s is AuthLoading
                                              ? const CircularProgressIndicator(color: Colors.white)
                                              : const Text('تسجيل الدخول', style: TextStyle(fontSize: 15)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // ✅ تبويب إنشاء حساب (اختصار)
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      const Text(
                                        'ليس لديك حساب؟',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const RegisterScreen(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'إنشاء حساب جديد',
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'أو',
                                        style: TextStyle(color: AppColors.grey),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: OutlinedButton(
                                          onPressed: _guest,
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.white30),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            backgroundColor: Colors.white.withOpacity(0.1),
                                          ),
                                          child: const Text(
                                            'تصفح كضيف',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ أزرار Google و Apple
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: () => context.read<AuthBloc>().add(LoginWithGoogle()),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.15),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata, color: Colors.white, size: 20),
                                  SizedBox(width: 4),
                                  Text("Google", style: TextStyle(fontSize: 13, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.15),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.apple, color: Colors.white, size: 20),
                                  SizedBox(width: 4),
                                  Text("Apple", style: TextStyle(fontSize: 13, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_hasBiometric) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          if (await _bio.authenticate(reason: 'الدخول بـ $_bioName')) {
                            _guest();
                          }
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(Icons.fingerprint, color: Colors.white, size: 26),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bioName,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],

                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _guest,
                      child: const Text(
                        'تصفح كضيف',
                        style: TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'Cairo'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMsg(String m, bool e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: e ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
