import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/screens/auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'مرحباً بك في صحتك',
      'subtitle': 'منصتك الصحية الشاملة للرعاية الطبية المتكاملة',
      'icon': '🏥',
      'color': AppColors.primary,
      'description': 'احصل على أفضل الخدمات الصحية في مكان واحد',
    },
    {
      'title': 'استشارات طبية',
      'subtitle': 'تواصل مع أفضل الأطباء عن بُعد',
      'icon': '👨‍⚕️',
      'color': AppColors.info,
      'description': 'استشارات فورية عبر الفيديو والصوت والنص',
    },
    {
      'title': 'صيدلية رقمية',
      'subtitle': 'اطلب أدويتك أونلاين ووصلها لبابك',
      'icon': '💊',
      'color': AppColors.success,
      'description': 'أكثر من 100 دواء ومستلزمات صحية',
    },
    {
      'title': 'ملف صحي متكامل',
      'subtitle': 'تتبع صحتك وسجلها في مكان آمن',
      'icon': '📋',
      'color': AppColors.purple,
      'description': 'سجلك الطبي، التحاليل، التطعيمات، والأدوية',
    },
    {
      'title': 'جاهز للانطلاق!',
      'subtitle': 'انضم إلى مجتمع صحتك الآن',
      'icon': '🚀',
      'color': AppColors.amber,
      'description': 'ابدأ رحلتك الصحية معنا اليوم',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (seen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ الخلفية
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (_onboardingData[_currentPage]['color'] as Color).withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),
          // ✅ محتوى Onboarding
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                      _isLastPage = index == _onboardingData.length - 1;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return _buildOnboardingPage(data, index);
                  },
                ),
              ),
              // ✅ أزرار التنقل
              _buildBottomNavigation(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data, int index) {
    final color = data['color'] as Color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ أيقونة كبيرة
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                data['icon'],
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // ✅ العنوان
          Text(
            data['title'],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // ✅ النص الفرعي
          Text(
            data['subtitle'],
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // ✅ الوصف
          Text(
            data['description'],
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ نقاط التقدم
          Row(
            children: List.generate(
              _onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // ✅ أزرار التنقل
          Row(
            children: [
              if (!_isLastPage)
                TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLastPage
                    ? _completeOnboarding
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLastPage ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  _isLastPage ? 'ابدأ' : 'التالي',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
