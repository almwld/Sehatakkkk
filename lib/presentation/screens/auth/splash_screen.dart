import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (hasSeenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ جعل التصميم نابضاً (Responsive)
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final logoSize = isTablet ? size.width * 0.15 : size.width * 0.25;
    final iconSize = isTablet ? logoSize * 0.5 : logoSize * 0.5;
    final titleSize = isTablet ? size.width * 0.04 : size.width * 0.08;
    final subtitleSize = isTablet ? size.width * 0.02 : size.width * 0.04;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00796B),
              Color(0xFF004D40),
              Color(0xFF00251A),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ شعار نابض
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (_, value, __) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(logoSize * 0.25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.health_and_safety,
                        size: iconSize,
                        color: const Color(0xFF00796B),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              // ✅ عنوان نابض
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 20.0, end: 0.0),
                duration: const Duration(milliseconds: 600),
                builder: (_, value, __) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Opacity(
                      opacity: 1 - (value / 20),
                      child: Text(
                        'صحتك',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'NotoSansArabicUI',
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // ✅ النص الفرعي نابض
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 30.0, end: 0.0),
                duration: const Duration(milliseconds: 800),
                builder: (_, value, __) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: Opacity(
                      opacity: 1 - (value / 30),
                      child: Text(
                        'منصة الرعاية الصحية الشاملة',
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'NotoSansArabicUI',
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              // ✅ مؤشر تحميل نابض
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder: (_, value, __) {
                  return Opacity(
                    opacity: value,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
