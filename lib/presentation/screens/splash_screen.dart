import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ اللون الجديد: #2D7E81 (أزرق مخضر هادئ)
    // ✅ مدة الشاشة: 12 ثانية

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // ✅ الانتقال بعد 12 ثانية
    Future.delayed(const Duration(seconds: 12), () {
      if (!mounted) return;
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.then((p) => p.getBool('hasSeenOnboarding') ?? false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // التحقق من رؤية Onboarding
      hasSeenOnboarding.then((seen) {
        if (!mounted) return;
        if (seen) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        } else {
          // هنا يمكن إضافة OnboardingScreen إذا كنت تريد
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // ✅ اللون الجديد: #2D7E81
        color: const Color(0xFF2D7E81),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ شعار Lottie (بدون خلفية بيضاء)
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      child: Lottie.asset(
                        'assets/animations/sehatak_animation.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.health_and_safety,
                            size: 80,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Column(
                      children: [
                        Text(
                          'SEHATAK',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'صحتك',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'منصة الرعاية الصحية الشاملة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
