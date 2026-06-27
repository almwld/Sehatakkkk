import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/presentation/widgets/shimmer/glass_shimmer.dart';

// ============================================================
// 🏠 الصفحة الرئيسية - HomeScreen
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    DoctorsListScreen(),
    PharmacyScreen(),
    ChatScreen(receiverId: '1', receiverName: 'الطبيب'),
    PatientAppointments(),
    PatientDashboard(),
    MoreScreen(),
  ];

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  void _navigateWithAuth(VoidCallback action) {
    if (_isLoggedIn) {
      action();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
            _buildNavItem(1, Icons.search_rounded, 'الأطباء'),
            _buildNavItem(2, Icons.local_pharmacy_rounded, 'الصيدلية'),
            _buildChatButton(),
            _buildNavItem(4, Icons.calendar_month_rounded, 'المواعيد'),
            _buildNavItem(5, Icons.folder_rounded, 'صحتي'),
            _buildNavItem(6, Icons.grid_view_rounded, 'المزيد'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (index == 3 || index == 4 || index == 5) {
          _navigateWithAuth(() => setState(() => _currentIndex = index));
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? AppColors.primary : (isDark ? Colors.grey[500] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _navigateWithAuth(() => setState(() => _currentIndex = 3)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'الدردشة',
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 📱 التبويب الرئيسي - HomeTab
// ============================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // ============================================================
  // 🎬 المتغيرات
  // ============================================================
  final PageController _sliderController = PageController();
  int _currentSlide = 0;
  Timer? _sliderTimer;
  bool _isLoading = true;

  // بيانات السلايدر
  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'صحتك تهمنا',
      'subtitle': 'رعاية صحية متكاملة في مكان واحد',
      'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80',
      'color': AppColors.primary,
    },
    {
      'title': 'استشارات طبية',
      'subtitle': 'تواصل مع أفضل الأطباء عن بُعد',
      'image': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800&q=80',
      'color': AppColors.purple,
    },
    {
      'title': 'صيدلية رقمية',
      'subtitle': 'اطلب أدويتك أونلاين ووصلها لبابك',
      'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800&q=80',
      'color': AppColors.success,
    },
    {
      'title': 'تحاليل منزلية',
      'subtitle': 'خدمة تحاليل طبية في منزلك',
      'image': 'https://images.unsplash.com/photo-1581595220892-b0739db3ba8c?w=800&q=80',
      'color': AppColors.warning,
    },
    {
      'title': 'تأمين صحي',
      'subtitle': 'خطط تأمين تناسب احتياجاتك',
      'image': 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=800&q=80',
      'color': AppColors.info,
    },
  ];

  // قائمة الأطباء
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'د. علي المولد',
      'specialty': 'استشاري باطنية',
      'rating': 4.9,
      'reviews': 128,
      'available': true,
    },
    {
      'id': '2',
      'name': 'د. فاطمة صديقي',
      'specialty': 'طبيبة أطفال',
      'rating': 4.8,
      'reviews': 95,
      'available': true,
    },
    {
      'id': '3',
      'name': 'د. محمد العتيبي',
      'specialty': 'استشاري قلبية',
      'rating': 4.9,
      'reviews': 156,
      'available': false,
    },
    {
      'id': '4',
      'name': 'د. نوره السيف',
      'specialty': 'طبيبة نساء وولادة',
      'rating': 4.7,
      'reviews': 82,
      'available': true,
    },
  ];

  // الخدمات السريعة
  final List<Map<String, dynamic>> _quickServices = [
    {'label': 'صيدلية', 'icon': Icons.local_pharmacy, 'color': AppColors.success, 'route': PharmacyScreen()},
    {'label': 'طوارئ', 'icon': Icons.emergency, 'color': AppColors.error, 'route': EmergencyNumbers()},
    {'label': 'تحاليل', 'icon': Icons.science, 'color': AppColors.purple, 'route': LabsListScreen()},
    {'label': 'تأمين', 'icon': Icons.shield_moon, 'color': AppColors.indigo, 'route': InsuranceCompanies()},
    {'label': 'صحة', 'icon': Icons.favorite, 'color': AppColors.pink, 'route': HealthDashboard()},
    {'label': 'محفظة', 'icon': Icons.account_balance_wallet, 'color': AppColors.amber, 'route': WalletScreen()},
    {'label': 'سلة', 'icon': Icons.shopping_cart, 'color': AppColors.orange, 'route': CartScreen()},
    {'label': 'استشارة', 'icon': Icons.chat, 'color': AppColors.primary, 'route': null},
  ];

  // المنتجات
  final List<Map<String, dynamic>> _products = [
    {'name': 'بانادول', 'price': '12.5 ر.س', 'color': AppColors.primary},
    {'name': 'فيتامين C', 'price': '8.0 ر.س', 'color': AppColors.success},
    {'name': 'ماسك وجه', 'price': '15.0 ر.س', 'color': AppColors.purple},
    {'name': 'كريم ترطيب', 'price': '22.0 ر.س', 'color': AppColors.pink},
  ];

  // النصائح اليومية
  final List<Map<String, dynamic>> _tips = [
    {'title': 'شرب الماء', 'desc': '8 أكواب يومياً للحفاظ على صحة الجسم', 'icon': Icons.water_drop, 'color': AppColors.info},
    {'title': 'المشي اليومي', 'desc': '30 دقيقة تقلل من أمراض القلب', 'icon': Icons.directions_walk, 'color': AppColors.success},
    {'title': 'النوم الكافي', 'desc': '7-8 ساعات لتعزيز المناعة', 'icon': Icons.bedtime, 'color': AppColors.purple},
  ];

  // ============================================================
  // 🔄 دورة الحياة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _sliderController.dispose();
    super.dispose();
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _startSliderAutoPlay();
      }
    });
  }

  void _startSliderAutoPlay() {
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_sliderController.hasClients) {
        final nextPage = (_currentSlide + 1) % _slides.length;
        _sliderController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() => _currentSlide = nextPage);
      }
    });
  }

  // ============================================================
  // 🧭 التنقل
  // ============================================================
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _navigateToDoctor(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailsScreen(doctorId: id),
      ),
    );
  }

  // ============================================================
  // 🏗️ بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'مستخدم';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: _buildAppBar(isDark, isLoggedIn, userName, user),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(isDark),
              const SizedBox(height: 16),

              // 🎠 السلايدر
              _isLoading
                  ? const SliderShimmer()
                  : _buildSlider(),
              const SizedBox(height: 12),

              // 🎯 الخدمات السريعة
              _buildSectionTitle('خدمات سريعة', isDark),
              const SizedBox(height: 10),
              _buildQuickServices(isDark),
              const SizedBox(height: 22),

              // 👨‍⚕️ أفضل الأطباء
              _buildSectionTitle('👨‍⚕️ أفضل الأطباء', isDark),
              const SizedBox(height: 10),
              _isLoading
                  ? const ListShimmer(itemCount: 2)
                  : _buildDoctorsList(isDark),
              const SizedBox(height: 22),

              // 💊 منتجات صيدلية
              _buildSectionTitle('💊 منتجات صيدلية', isDark),
              const SizedBox(height: 10),
              _isLoading
                  ? const SliderShimmer(height: 120)
                  : _buildProductsRow(isDark),
              const SizedBox(height: 22),

              // 💡 نصائح يومية
              _buildSectionTitle('💡 نصائح يومية', isDark),
              const SizedBox(height: 10),
              _isLoading
                  ? const ListShimmer(itemCount: 2)
                  : _buildTipsList(isDark),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔧 أجزاء الواجهة
  // ============================================================

  // 📌 AppBar
  PreferredSizeWidget _buildAppBar(bool isDark, bool isLoggedIn, String userName, User? user) {
    return AppBar(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      elevation: 0,
      leading: _buildAvatar(isLoggedIn, userName, user),
      title: Text(
        isLoggedIn ? 'مرحباً، $userName 👋' : 'منصة صحتك',
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        _buildActionButton(
          Icons.auto_awesome,
          AppColors.purple,
          'المساعد الذكي',
          () => isLoggedIn
              ? _navigateTo(const ConsultationScreen())
              : _navigateTo(const LoginScreen()),
        ),
        _buildActionButton(
          Icons.account_balance_wallet,
          AppColors.success,
          'المحفظة',
          () => isLoggedIn
              ? _navigateTo(const WalletScreen())
              : _navigateTo(const LoginScreen()),
        ),
        _buildActionButton(
          Icons.notifications_outlined,
          AppColors.warning,
          'الإشعارات',
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔔 سيتم فتح الإشعارات قريباً'),
                backgroundColor: AppColors.info,
              ),
            );
          },
          hasBadge: true,
        ),
        _buildActionButton(
          Icons.shopping_cart_outlined,
          AppColors.primary,
          'السلة',
          () => _navigateTo(const CartScreen()),
        ),
        if (!isLoggedIn)
          TextButton(
            onPressed: () => _navigateTo(const LoginScreen()),
            child: const Text(
              'تسجيل',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  // 📷 الصورة الشخصية
  Widget _buildAvatar(bool isLoggedIn, String userName, User? user) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          if (isLoggedIn) {
            _navigateTo(const PatientProfile());
          } else {
            _navigateTo(const LoginScreen());
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: user?.photoURL ??
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=00796B&color=fff&size=80',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 40,
              height: 40,
              color: Colors.grey[300],
            ),
            errorWidget: (_, __, ___) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person, color: AppColors.primary, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  // 🔘 أزرار الإجراءات
  Widget _buildActionButton(IconData icon, Color color, String tooltip, VoidCallback onTap, {bool hasBadge = false}) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Icon(icon, color: color, size: 20),
            if (hasBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
      onPressed: onTap,
      tooltip: tooltip,
    );
  }

  // 🔍 شريط البحث
  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '🔍 بحث عن أطباء، أدوية، خدمات...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  fontSize: 13,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.tune, color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }

  // 🎠 السلايدر
  Widget _buildSlider() {
    return Stack(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _sliderController,
            onPageChanged: (index) {
              setState(() => _currentSlide = index);
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return _buildSlideItem(slide);
            },
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: _buildDotIndicator(),
        ),
      ],
    );
  }

  Widget _buildSlideItem(Map<String, dynamic> slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: slide['image'],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey[850],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                color: slide['color'].withOpacity(0.3),
                child: Center(
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.white54),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slide['subtitle'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔵 مؤشرات السلايدر
  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentSlide == index ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: _currentSlide == index ? Colors.white : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // 📝 عنوان القسم
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  // 🎯 الخدمات السريعة
  Widget _buildQuickServices(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _quickServices.length,
      itemBuilder: (context, index) {
        final service = _quickServices[index];
        return _buildQuickServiceItem(
          service['label'],
          service['icon'],
          service['color'],
          service['route'],
          isDark,
        );
      },
    );
  }

  Widget _buildQuickServiceItem(
    String label,
    IconData icon,
    Color color,
    Widget? route,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          _navigateTo(route);
        } else {
          ChatNavigation.openChat(
            context,
            doctorName: 'الطبيب',
            doctorId: '1',
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white70 : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 👨‍⚕️ قائمة الأطباء
  Widget _buildDoctorsList(bool isDark) {
    return Column(
      children: _doctors.map((doctor) => _buildDoctorCard(doctor, isDark)).toList(),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // الصورة
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),

          // المعلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  doctor['specialty'],
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.amber, size: 14),
                    Text(
                      ' ${doctor['rating']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${doctor['reviews']})',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: doctor['available']
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        doctor['available'] ? 'متاح' : 'غير متاح',
                        style: TextStyle(
                          color: doctor['available'] ? AppColors.success : AppColors.error,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // زر الحجز
          GestureDetector(
            onTap: () => _navigateToDoctor(doctor['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Text(
                'حجز',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💊 منتجات الصيدلية
  Widget _buildProductsRow(bool isDark) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product, isDark);
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateTo(const PharmacyScreen()),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: product['color'].withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.medication, color: product['color'], size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              product['name'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product['price'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 النصائح اليومية
  Widget _buildTipsList(bool isDark) {
    return Column(
      children: _tips.map((tip) => _buildTipCard(tip, isDark)).toList(),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tip['color'].withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tip['color'].withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tip['color'].withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(tip['icon'], color: tip['color'], size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  tip['desc'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            size: 14,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔄 تحديث (Pull to Refresh)
  // ============================================================
  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      _startSliderAutoPlay();
    }
  }
}
