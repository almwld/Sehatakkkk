import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 3500);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _navigated = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _check();
  }

  Future<void> _check() async {
    // Show the splash on every launch for exactly 3.5 seconds.
    try {
      await _audioPlayer.setAsset('assets/audio/splash_sound.mp3');
      unawaited(_audioPlayer.play());
    } catch (_) {}

    await Future<void>.delayed(_duration);
    await _goNext();
  }

  Future<void> _skip() async {
    await _goNext();
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;
    _navigated = true;
    await _audioPlayer.stop();
    context.go('/auth');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A8F83),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: const Color(0xFF0A8F83),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * .52,
                      height: width * .30,
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
                    const SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: Colors.white24,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                bottom: 28,
                start: 24,
                end: 24,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: OutlinedButton(
                    onPressed: _skip,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white70),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('تخطي'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
