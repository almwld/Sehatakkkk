import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _loadingCtrl;
  late Animation<double> _loadingAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ✅ دوائر متحركة
  final List<CircleData> _circles = [
    CircleData(size: 120, duration: 20, dx: -100, dy: -150, color: Colors.white.withOpacity(0.03)),
    CircleData(size: 80, duration: 15, dx: 120, dy: -200, color: Colors.white.withOpacity(0.04)),
    CircleData(size: 60, duration: 12, dx: -150, dy: 100, color: Colors.white.withOpacity(0.05)),
    CircleData(size: 40, duration: 8, dx: 180, dy: 150, color: Colors.white.withOpacity(0.06)),
    CircleData(size: 100, duration: 18, dx: -80, dy: 250, color: Colors.white.withOpacity(0.03)),
    CircleData(size: 50, duration: 10, dx: 200, dy: -100, color: Colors.white.withOpacity(0.04)),
    CircleData(size: 70, duration: 14, dx: -200, dy: -50, color: Colors.white.withOpacity(0.05)),
    CircleData(size: 30, duration: 6, dx: 100, dy: 280, color: Colors.white.withOpacity(0.06)),
  ];

  @override
  void initState() {
    super.initState();
    _playSplashSound();

    // ✅ التحكم الرئيسي
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.elasticOut),
    );

    // ✅ التحكم لخط التحميل
    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeInOut),
    );

    _mainCtrl.forward();
    _loadingCtrl.repeat();

    // ✅ مدة العرض: 4 ثواني (محسنة)
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _navigateToNext();
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _loadingCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSplashSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('audio/splash_sound.mp3'),
      );
    } catch (e) {
      // تجاهل الأخطاء في حالة عدم وجود الملف الصوتي
      print('⚠️ Splash sound not found');
    }
  }

  Future<void> _navigateToNext() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = user != null;
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // ✅ حفظ أول مرة
    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const HomeScreen() : const AuthScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D5257),
      body: Stack(
        children: [
          // ✅ خلفية مع دوائر متحركة
          ..._circles.map((circle) => _buildAnimatedCircle(circle)),
          
          // ✅ المحتوى الرئيسي
          Center(
            child: AnimatedBuilder(
              animation: _mainCtrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ الأيقونة أو الشعار
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'صحتك',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'منصة صحتك الشاملة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // ✅ شريط التحميل
                        Container(
                          width: 200,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: AnimatedBuilder(
                            animation: _loadingAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: _loadingAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle(CircleData circle) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(seconds: circle.duration),
      builder: (context, value, child) {
        final dx = circle.dx * value;
        final dy = circle.dy * value;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Container(
            width: circle.size,
            height: circle.size,
            decoration: BoxDecoration(
              color: circle.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// ✅ نموذج بيانات الدائرة
class CircleData {
  final double size;
  final int duration;
  final double dx;
  final double dy;
  final Color color;

  const CircleData({
    required this.size,
    required this.duration,
    required this.dx,
    required this.dy,
    required this.color,
  });
}
