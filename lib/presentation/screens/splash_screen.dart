import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
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

  // ✅ دوائر متحركة (زيادة العدد إلى 15 دائرة)
  final List<CircleData> _circles = [
    // ✅ دوائر كبيرة
    CircleData(size: 150, duration: 25, dx: -120, dy: -180, color: Colors.white.withOpacity(0.02)),
    CircleData(size: 130, duration: 20, dx: 140, dy: -220, color: Colors.white.withOpacity(0.025)),
    CircleData(size: 110, duration: 18, dx: -180, dy: 120, color: Colors.white.withOpacity(0.03)),
    CircleData(size: 100, duration: 22, dx: 200, dy: 180, color: Colors.white.withOpacity(0.035)),
    
    // ✅ دوائر متوسطة
    CircleData(size: 80, duration: 16, dx: -100, dy: -250, color: Colors.white.withOpacity(0.04)),
    CircleData(size: 75, duration: 14, dx: 160, dy: -280, color: Colors.white.withOpacity(0.045)),
    CircleData(size: 70, duration: 12, dx: -220, dy: 80, color: Colors.white.withOpacity(0.05)),
    CircleData(size: 65, duration: 15, dx: 250, dy: 130, color: Colors.white.withOpacity(0.055)),
    CircleData(size: 60, duration: 11, dx: -150, dy: 280, color: Colors.white.withOpacity(0.06)),
    CircleData(size: 55, duration: 13, dx: 180, dy: -150, color: Colors.white.withOpacity(0.065)),
    
    // ✅ دوائر صغيرة
    CircleData(size: 45, duration: 9, dx: -80, dy: 300, color: Colors.white.withOpacity(0.07)),
    CircleData(size: 40, duration: 8, dx: 220, dy: 320, color: Colors.white.withOpacity(0.075)),
    CircleData(size: 35, duration: 7, dx: -250, dy: -80, color: Colors.white.withOpacity(0.08)),
    CircleData(size: 30, duration: 6, dx: 280, dy: -100, color: Colors.white.withOpacity(0.085)),
    CircleData(size: 25, duration: 5, dx: -300, dy: 50, color: Colors.white.withOpacity(0.09)),
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
    await Future.delayed(const Duration(seconds: 3));
    
    if (_isNavigating) return;
    _isNavigating = true;

    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('has_seen_splash', true);

    if (!mounted) return;

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
              // ✅ دوائر متحركة (15 دائرة)
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

                              SizedBox(height: screenHeight * 0.04),

                              // ✅ "صحتك أولاً" (رفعها فوق الشريط المتحرك)
                              const Text(
                                'صحتك أولاً',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 5,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 80,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 8),

                              // ✅ "Sehatak Platform ©" فوق الشريط المتحرك
                              Text(
                                '© 2026 Sehatak Platform',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.4),
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.03),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ✅ خط تحميل متحرك (أسفل الشاشة)
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
        final x = circle.dx + 180 * (angle / (2 * 3.14159) * 2 - 1);
        final y = circle.dy + 180 * (angle / (2 * 3.14159) * 2 - 1);
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
