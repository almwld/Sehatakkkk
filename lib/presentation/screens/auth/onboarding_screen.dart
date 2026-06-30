import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.health_and_safety,
      'title': 'صحتك أولاً',
      'desc': 'منصة الرعاية الصحية الشاملة\nاستشر الأطباء واحجز مواعيدك بسهولة\nمن أي مكان وفي أي وقت',
      'gradient': AppColors.primaryGradient,
      'iconBg': AppColors.primary,
    },
    {
      'icon': Icons.local_pharmacy,
      'title': 'صيدلية متكاملة',
      'desc': 'اطلب أدويتك واستلمها لمنزلك\nمع توصيل سريع وآمن\nخصومات وعروض يومية',
      'gradient': AppColors.secondaryGradient,
      'iconBg': AppColors.secondary,
    },
    {
      'icon': Icons.medical_services,
      'title': 'رعاية متواصلة',
      'desc': 'متابعة صحية شاملة وتحاليل مخبرية\nوخدمات طوارئ على مدار الساعة\nملف طبي متكامل لتاريخك الصحي',
      'gradient': AppColors.medicalGradient,
      'iconBg': AppColors.primaryDark,
    },
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ الانتقال إلى شاشة تسجيل الدخول الأصلية
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _skip() {
    // ✅ الانتقال إلى شاشة تسجيل الدخول الأصلية
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _pages[_page]['gradient'] as List<Color>;
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // شريط التقدم + تخطي
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(
                          _pages.length,
                          (i) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _page == i
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_page + 1}/${_pages.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Text(
                          'تخطي',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // المحتوى
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    final iconBg = p['iconBg'] as Color;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة دائرية
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (_, v, __) {
                            return Transform.scale(
                              scale: v,
                              child: Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            iconBg,
                                            iconBg.withOpacity(0.7),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: iconBg.withOpacity(0.4),
                                            blurRadius: 15,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        p['icon'] as IconData,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 60),
                        // العنوان
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 20.0, end: 0.0),
                          duration: const Duration(milliseconds: 600),
                          builder: (_, v, __) {
                            return Transform.translate(
                              offset: Offset(0, v),
                              child: Opacity(
                                opacity: 1 - (v / 20),
                                child: Text(
                                  p['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // الوصف
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 30.0, end: 0.0),
                          duration: const Duration(milliseconds: 800),
                          builder: (_, v, __) {
                            return Transform.translate(
                              offset: Offset(0, v),
                              child: Opacity(
                                opacity: 1 - (v / 30),
                                child: Text(
                                  p['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.8,
                                    fontFamily: 'Cairo',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              // زر التالي/ابدأ
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colors[0],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _page == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            if (_page < _pages.length - 1) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: colors[0],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
