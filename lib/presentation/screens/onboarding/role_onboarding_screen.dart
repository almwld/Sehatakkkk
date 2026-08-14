import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/roles.dart';

class RoleOnboardingScreen extends StatefulWidget {
  final UserRole role;
  final String? specialty;
  final VoidCallback onComplete;
  
  const RoleOnboardingScreen({
    super.key,
    required this.role,
    this.specialty,
    required this.onComplete,
  });

  @override
  State<RoleOnboardingScreen> createState() => _RoleOnboardingScreenState();
}

class _RoleOnboardingScreenState extends State<RoleOnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  List<OnboardingPage> get _pages {
    switch (widget.role) {
      case UserRole.doctor:
        return _getDoctorPages();
      case UserRole.pharmacist:
        return _getPharmacistPages();
      case UserRole.lab:
        return _getLabPages();
      case UserRole.veterinarian:
        return _getVeterinarianPages();
      default:
        return _getUserPages();
    }
  }

  List<OnboardingPage> _getUserPages() => [
    OnboardingPage(
      title: 'مرحباً بك في صحتك',
      description: 'منصة الرعاية الصحية الشاملة الأولى في اليمن',
      icon: Icons.health_and_safety,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'احصل على رعاية صحية متكاملة',
      description: 'ابحث عن أفضل الأطباء والصيدليات والمختبرات في منطقتك',
      icon: Icons.search,
      color: Colors.teal,
    ),
    OnboardingPage(
      title: 'حجز المواعيد بكل سهولة',
      description: 'احجز موعدك مع أفضل الأطباء في دقائق',
      icon: Icons.calendar_today,
      color: Colors.purple,
    ),
  ];

  List<OnboardingPage> _getDoctorPages() {
    final specialty = widget.specialty ?? 'طبيب';
    return [
      OnboardingPage(
        title: 'مرحباً دكتور $specialty',
        description: 'أهلاً بك في منصة صحتك الطبية',
        icon: Icons.local_hospital,
        color: Colors.blue,
      ),
      OnboardingPage(
        title: 'إدارة مواعيدك بسهولة',
        description: 'استقبل المرضى وقم بإدارة جدول مواعيدك اليومي',
        icon: Icons.calendar_month,
        color: Colors.teal,
      ),
      OnboardingPage(
        title: 'تواصل مع مرضاك',
        description: 'استقبل استشارات المرضى عبر المحادثة الفورية',
        icon: Icons.chat,
        color: Colors.green,
      ),
      OnboardingPage(
        title: 'حساب موثق',
        description: 'قم بتوثيق حسابك لزيادة الثقة مع المرضى',
        icon: Icons.verified,
        color: Colors.orange,
      ),
    ];
  }

  List<OnboardingPage> _getPharmacistPages() => [
    OnboardingPage(
      title: 'مرحباً صيدلي',
      description: 'أهلاً بك في منصة صحتك للصيدليات',
      icon: Icons.local_pharmacy,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'عرض منتجاتك',
      description: 'أضف منتجاتك الصيدلانية وعرضها للعملاء',
      icon: Icons.inventory,
      color: Colors.teal,
    ),
    OnboardingPage(
      title: 'استقبال الطلبات',
      description: 'استقبل طلبات العملاء وقم بتوصيلها بسهولة',
      icon: Icons.shopping_cart,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'حساب موثق',
      description: 'وثق حسابك لبناء ثقة العملاء في صيدليتك',
      icon: Icons.verified,
      color: Colors.blue,
    ),
  ];

  List<OnboardingPage> _getLabPages() => [
    OnboardingPage(
      title: 'مرحباً مختبر',
      description: 'أهلاً بك في منصة صحتك للمختبرات',
      icon: Icons.science,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: 'عرض خدماتك',
      description: 'أضف خدماتك المخبرية وعرضها للعملاء',
      icon: Icons.list_alt,
      color: Colors.teal,
    ),
    OnboardingPage(
      title: 'استقبال الفحوصات',
      description: 'استقبل طلبات الفحوصات من المرضى',
      icon: Icons.bloodtype,
      color: Colors.red,
    ),
    OnboardingPage(
      title: 'حساب موثق',
      description: 'وثق حسابك لزيادة ثقة المرضى في مختبرك',
      icon: Icons.verified,
      color: Colors.orange,
    ),
  ];

  List<OnboardingPage> _getVeterinarianPages() => [
    OnboardingPage(
      title: 'مرحباً بيطري',
      description: 'أهلاً بك في منصة صحتك للطب البيطري',
      icon: Icons.pets,
      color: Colors.brown,
    ),
    OnboardingPage(
      title: 'رعاية الحيوانات',
      description: 'قدم خدماتك البيطرية لأصحاب الحيوانات',
      icon: Icons.favorite,
      color: Colors.teal,
    ),
    OnboardingPage(
      title: 'مواعيد العيادة',
      description: 'إدارة مواعيد العيادة البيطرية بسهولة',
      icon: Icons.calendar_month,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'حساب موثق',
      description: 'وثق حسابك لبناء ثقة عملائك',
      icon: Icons.verified,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onComplete,
                child: const Text('تخطي →'),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return _buildPage(page, isDark);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    widget.onComplete();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage < _pages.length - 1 ? 'التالي' : 'ابدأ الآن',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
