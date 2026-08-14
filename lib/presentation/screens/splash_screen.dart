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
  bool _isNavigating = false;

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
    _initAnimations();
    _checkAuthAndNavigate();
  }

  void _initAnimations() {
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

    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _loadingAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeInOut),
    );

    _mainCtrl.forward();
    _loadingCtrl.repeat();
  }

  Future<void> _playSplashSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('audio/splash_sound.mp3'),
        volume: 0.5,
      );
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الصوت: $e');
    }
  }

  void _checkAuthAndNavigate() async {
    // ✅ انتظر 3 ثواني لعرض الشاشة
    await Future.delayed(const Duration(seconds: 3));
    
    if (_isNavigating) return;
    _isNavigating = true;

    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    
    // ✅ حفظ أن المستخدم شاهد الشاشة
    await prefs.setBool('has_seen_splash', true);

    if (!mounted) return;

    // ✅ التنقل إلى الشاشة المناسبة
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _loadingCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final lottieWidth = screenWidth * 0.50;
    final lottieHeight = lottieWidth * (180 / 320);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF2D7E81),
        child: SafeArea(
          child: Stack(
            children: [
              // ✅ دوائر متحركة
              ..._circles.map((circle) => _buildAnimatedCircle(circle)),

              // ✅ المحتوى الرئيسي
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: AnimatedBuilder(
                    animation: _mainCtrl,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: screenHeight * 0.05),

                              // ✅ Lottie
                              Transform.scale(
                                scale: _scaleAnimation.value,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: lottieWidth,
                                    maxHeight: lottieHeight,
                                    minWidth: 120,
                                    minHeight: 67,
                                  ),
                                  child: Lottie.asset(
                                    'assets/animations/sehatak_animation.json',
                                    fit: BoxFit.contain,
                                    repeat: true,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.health_and_safety,
                                        size: screenWidth * 0.15,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.04),

                              Transform.scale(
                                scale: _scaleAnimation.value,
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

                              SizedBox(height: screenHeight * 0.02),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
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

                              SizedBox(height: screenHeight * 0.05),

                              // ✅ "صحتك أولاً"
                              Column(
                                children: [
                                  const Text(
                                    'صحتك أولاً',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 4,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 60,
                                    height: 1,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '© 2026 Sehatak Platform',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white.withOpacity(0.3),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ✅ خط تحميل متحرك
              Positioned(
                bottom: screenHeight * 0.05,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _loadingCtrl,
                  builder: (context, child) {
                    return Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: _loadingAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCircle(CircleData circle) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 2 * 3.14159),
      duration: Duration(seconds: circle.duration),
      curve: Curves.linear,
      builder: (context, angle, child) {
        final x = circle.dx + 150 * (angle / (2 * 3.14159) * 2 - 1);
        final y = circle.dy + 150 * (angle / (2 * 3.14159) * 2 - 1);
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + x - circle.size / 2,
          top: MediaQuery.of(context).size.height / 2 + y - circle.size / 2,
          child: Container(
            width: circle.size,
            height: circle.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circle.color,
              border: Border.all(
                color: circle.color,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircleData {
  final double size;
  final int duration;
  final double dx;
  final double dy;
  final Color color;

  CircleData({
    required this.size,
    required this.duration,
    required this.dx,
    required this.dy,
    required this.color,
  });
}
