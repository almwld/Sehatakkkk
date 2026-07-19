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
  late Animation<double> _pulseAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _playSplashSound();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _mainCtrl.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _mainCtrl.forward();
        }
      });

    _mainCtrl.forward();

    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      _navigateToNext();
    });
  }

  Future<void> _playSplashSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('audio/splash_sound.mp3'),
        volume: 0.8,
      );
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الصوت: $e');
    }
  }

  Future<void> _navigateToNext() async {
    await _audioPlayer.stop();

    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

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
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final lottieWidth = screenWidth * 0.55;
    final lottieHeight = lottieWidth * (180 / 320);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF2D7E81), // ✅ الخلفية الخضراء المزرقة
        child: Stack(
          children: [
            // ===== دوائر خلفية نابضة =====
            ...List.generate(3, (index) {
              final sizes = [350, 250, 120];
              final positions = [
                {'top': -120, 'right': -80},
                {'bottom': -100, 'left': -60},
                {'top': 200, 'right': -30},
              ];
              final delays = [0, 1, 2];
              return Positioned(
                top: positions[index]['top']?.toDouble(),
                bottom: positions[index]['bottom']?.toDouble(),
                left: positions[index]['left']?.toDouble(),
                right: positions[index]['right']?.toDouble(),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 3),
                  delay: Duration(seconds: delays[index]),
                  builder: (_, value, __) => Transform.scale(
                    scale: value,
                    child: Container(
                      width: sizes[index].toDouble(),
                      height: sizes[index].toDouble(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04 + (index * 0.01)),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // ===== نقاط صاعدة =====
            Positioned(
              top: 150, left: 50,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 4),
                builder: (_, value, __) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -20 * value),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200, right: 60,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 3),
                builder: (_, value, __) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -15 * value),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ===== المحتوى الرئيسي =====
            Center(
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

                          // ✅ Lottie نابض
                          Transform.scale(
                            scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.5,
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

                          // ✅ اسم التطبيق
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

                          // ✅ الوصف
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

                          SizedBox(height: screenHeight * 0.08),

                          // ✅ مؤشر التحميل
                          const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Text(
                            'جاري التحميل...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.05),

                          // ===== النص السفلي =====
                          Column(
                            children: [
                              Text(
                                'صحـتـك أولاً',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.3),
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '© 2026 Sehatak Platform',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white.withOpacity(0.2),
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
          ],
        ),
      ),
    );
  }
}
