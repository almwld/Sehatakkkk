import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _navigated = false;
  String _status = 'جاري التحميل...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      final remember = prefs.getBool('remember_me') ?? false;
      final savedUid = prefs.getString('user_uid') ?? '';
      final savedLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final loggedIn = user != null &&
          remember &&
          savedLoggedIn &&
          savedUid == user.uid;

      if (mounted) setState(() => _status = 'جاري التحقق من المستخدم...');

      if (user != null && remember) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_uid', user.uid);
      } else if (user != null && !remember) {
        await FirebaseAuth.instance.signOut();
        await prefs.setBool('is_logged_in', false);
        await prefs.remove('user_uid');
      }

      if (mounted) setState(() => _status = 'جاهز!');
      await Future<void>.delayed(Duration(milliseconds: loggedIn ? 250 : 900));
      if (mounted) _navigate(loggedIn);
    } catch (e) {
      debugPrint('Splash login check error: $e');
      if (mounted) setState(() => _status = 'جاهز!');
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) _navigate(false);
    }
  }

  void _navigate(bool loggedIn) {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(loggedIn ? '/' : '/auth');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A8F83),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -70,
                child: _circle(220, Colors.white.withOpacity(.06)),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _circle(260, Colors.white.withOpacity(.05)),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: size.width * .52,
                        height: size.width * .30,
                        child: Lottie.asset(
                          'assets/animations/sehatak_animation.json',
                          fit: BoxFit.contain,
                          repeat: false,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 82,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'SEHATAK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'صحتك',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'منصة الرعاية الصحية اليمنية المتكاملة',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: Colors.white24,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _status,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,
                child: Text(
                  '© 2026 Sehatak Platform',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.45),
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
