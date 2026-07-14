import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';


// ============================================================
// 📱 HomeScreen - الشاشة الرئيسية مع شريط سفلي متحرك
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ValueNotifier<bool> _isBottomBarVisible = ValueNotifier<bool>(true);
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(bottomBarVisibility: _isBottomBarVisible),
      const DoctorsListScreen(),
      const MedicinesScreen(),
      const ChatScreen(),
      const LabsListScreen(),
      const PatientDashboard(),
      const MoreScreen(),
    ];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _isBottomBarVisible.dispose();
    super.dispose();
  }

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  void _navigateWithAuth(VoidCallback action) {
    if (_isLoggedIn) {
      action();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  void _onTabTap(int index) {
    if (index == 3 || index == 4 || index == 5) {
      _navigateWithAuth(() => setState(() => _currentIndex = index));
    } else {
      setState(() => _currentIndex = index);
    }
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          // ✅ المحتوى الرئيسي
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _screens[_currentIndex],
          ),
          // ✅ الشريط السفلي العائم - يختفي/يظهر عند التمرير
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isBottomBarVisible,
              builder: (context, isVisible, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  height: isVisible ? 68 : 0,
                  child: FadeTransition(
                    opacity: isVisible
                        ? const AlwaysStoppedAnimation(1.0)
                        : const AlwaysStoppedAnimation(0.0),
                    child: SlideTransition(
                      position: isVisible
                          ? _slideAnimation
                          : const AlwaysStoppedAnimation(Offset(0, 1)),
                      child: ScaleTransition(
                        scale: isVisible
                            ? _scaleAnimation
                            : const AlwaysStoppedAnimation(0.8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
                                _buildNavItem(1, Icons.person_search_rounded, 'الأطباء'),
                                _buildNavItem(2, Icons.local_pharmacy_rounded, 'الصيدلية'),
                                _buildChatButton(), // ✅ مرتفعة للأعلى بدون قص
                                _buildNavItem(4, Icons.science_rounded, 'مختبرات'),
                                _buildNavItem(5, Icons.folder_rounded, 'صحتي'),
                                _buildNavItem(6, Icons.grid_view_rounded, 'المزيد'),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  // ✅ الخط الأخضر تحت الأيقونة (معدل)
  Widget _buildNavItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    final color = selected ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: SizedBox(
        width: 48,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
            // ✅ الخط الأخضر تحت النص مباشرة
            if (selected)
              Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  // ✅ أيقونة الدردشة مرتفعة للأعلى بدون قص
  Widget _buildChatButton() {
    final selected = _currentIndex == 3;
    return GestureDetector(
      onTap: () => _onTabTap(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'الدردشة',
            style: TextStyle(
              fontSize: 9,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🏠 HomeTab - المحتوى الرئيسي للصفحة
// ============================================================
class HomeTab extends StatefulWidget {
  final ValueNotifier<bool> bottomBarVisibility;
  const HomeTab({super.key, required this.bottomBarVisibility});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  int _currentBanner = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ============================================================
  // 📊 البيانات
  // ============================================================

  final List<String> _bannerImages = [
    'assets/images/banners/banner_1.png',
    'assets/images/banners/banner_2.png',
    'assets/images/banners/banner_3.png',
    'assets/images/banners/banner_4.png',
  ];

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageService.doctor1},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageService.doctor2},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageService.doctor3},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageService.doctor4},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageService.doctor5},
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': Icons.medical_services, 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': Icons.local_pharmacy, 'label': 'صيدلية', 'color': AppColors.success, 'screen': const MedicinesScreen()},
    {'icon': Icons.science, 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': Icons.emergency, 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
    {'icon': Icons.favorite, 'label': 'صحة', 'color': AppColors.pink, 'screen': const HealthDashboard()},
    {'icon': Icons.wallet, 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
    {'icon': Icons.chat, 'label': 'استشارة', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
    {'icon': Icons.calendar_month, 'label': 'مواعيد', 'color': AppColors.primaryDark, 'screen': const PatientAppointments()},
    {'icon': Icons.map, 'label': 'بالقرب منك', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
    {'icon': Icons.shield, 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
    {'icon': Icons.bloodtype, 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const BloodDonationScreen()},
    {'icon': Icons.home_work, 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
  ];

  List<Map<String, dynamic>> _communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'image': "assets/images/posts/skin_care.png", 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'time': 'منذ ساعة', 'liked': false},
    {'id': 2, 'author': 'د. خالد النخلاني', 'image': "assets/images/posts/morning_walk.png", 'title': 'أهمية الفيتامينات', 'content': 'الفيتامينات عناصر أساسية لصحة الجسم، تأكد من تناولها.', 'likes': 95, 'comments': 8, 'shares': 5, 'time': 'منذ 3 ساعات', 'liked': false},
    {'id': 3, 'author': 'د. أحمد المولد', 'image': "assets/images/posts/nutrition_tips.png", 'title': 'صحة القلب', 'content': 'القلب محرك الحياة، احرص على الرياضة والأكل الصحي.', 'likes': 210, 'comments': 22, 'shares': 12, 'time': 'منذ 5 ساعات', 'liked': true},
    {'id': 4, 'author': 'د. أسماء الهندي', 'image': "assets/images/posts/immune_boost.png", 'title': 'فوائد المشي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 78, 'comments': 5, 'shares': 3, 'time': 'منذ يوم', 'liked': false},
    {'id': 5, 'author': 'د. محمد العلاي', 'image': "assets/images/posts/sleep_tips.png", 'title': 'تقوية المناعة', 'content': 'الطعام الصحي هو أساس المناعة القوية.', 'likes': 150, 'comments': 12, 'shares': 7, 'time': 'منذ يومين', 'liked': false},
  ];

  final List<Map<String, dynamic>> _dailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'color': AppColors.info},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'color': AppColors.success},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'color': AppColors.purple},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'color': AppColors.warning},
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageService.medicine1, 'category': 'مسكنات'},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageService.medicine2, 'category': 'فيتامينات'},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageService.medicine3, 'category': 'أجهزة طبية'},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'image': ImageService.medicine4, 'category': 'مضادات حيوية'},
    {'name': 'ديكلوفيناك 50mg', 'price': 650, 'image': ImageService.medicine1, 'category': 'مسكنات'},
    {'name': 'نابروكسين 250mg', 'price': 550, 'image': ImageService.medicine2, 'category': 'مضادات التهابية'},
    {'name': 'أسبرين 100mg', 'price': 300, 'image': ImageService.medicine3, 'category': 'مسكنات'},
    {'name': 'إيبوبروفين 400mg', 'price': 750, 'image': ImageService.medicine4, 'category': 'مسكنات'},
  ];

  // ✅ المختبرات المميزة
  final List<Map<String, dynamic>> _featuredLabs = [
    {'name': 'مختبرات الزارزي', 'location': 'صنعاء - شارع الزبيري', 'image': ImageService.lab1},
    {'name': 'مختبرات العولقي', 'location': 'صنعاء - شارع الستين', 'image': ImageService.lab2},
    {'name': 'مختبرات المأمون', 'location': 'صنعاء - حدة', 'image': ImageService.lab3},
  ];

  // ✅ المستشفيات المميزة
  final List<Map<String, dynamic>> _featuredHospitals = [
    {'name': 'مستشفى 22 مايو', 'location': 'صنعاء', 'image': ImageService.hospital1},
    {'name': 'مستشفى الجمهورية', 'location': 'صنعاء', 'image': ImageService.hospital2},
    {'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageService.hospital3},
  ];

  // ============================================================
  // 🔧 دوال المساعدة
  // ============================================================

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _toggleLike(int index) {
    setState(() {
      _communityPosts[index]['liked'] = !_communityPosts[index]['liked'];
      _communityPosts[index]['likes'] += _communityPosts[index]['liked'] ? 1 : -1;
    });
  }

  void _sharePost(int index) {
    final post = _communityPosts[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم مشاركة: ${post['title']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showComments(int index) {
    final post = _communityPosts[index];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التعليقات (${post['comments']})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, i) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text('${i + 1}', style: const TextStyle(color: AppColors.primary)),
                  ),
                  title: Text('تعليق ${i + 1}'),
                  subtitle: const Text('منذ دقيقة'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقاً...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Widget _buildShimmerEffect({double width = double.infinity, double height = 200}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ============================================================
  // 🏗️ دورة الحياة
  // ============================================================

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // ✅ منطق إخفاء/إظهار الشريط السفلي مثل Twitter
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (widget.bottomBarVisibility.value != false) {
          widget.bottomBarVisibility.value = false;
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (widget.bottomBarVisibility.value != true) {
          widget.bottomBarVisibility.value = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ============================================================
  // 🎨 بناء الواجهة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ✅ AppBar - يختفي/يظهر تلقائياً عند التمرير (مثل Twitter)
              SliverAppBar(
                expandedHeight: 90,
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
                foregroundColor: primaryColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (logged) _goTo(context, const PatientProfile());
                            else _goTo(context, const AuthScreen());
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Text(
                              name.isNotEmpty ? name[0] : 'م',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            logged ? 'مرحباً، $name' : 'منصة صحتك',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications_outlined, color: primaryColor),
                          onPressed: () => _goTo(context, const NotificationsScreen()),
                        ),
                        IconButton(
                          icon: Icon(Icons.shopping_cart_outlined, color: primaryColor),
                          onPressed: () => _goTo(context, const CartScreen()),
                        ),
                        if (!logged)
                          TextButton(
                            onPressed: () => _goTo(context, const AuthScreen()),
                            child: Text(
                              'تسجيل',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // ✅ المحتوى
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1️⃣ شريط البحث
                    _buildSearchBar(isDark),
                    const SizedBox(height: 16),

                    // 2️⃣ البانر المتحرك مع النقاط داخله في اليمين
                    _buildBannerCarousel(isDark, primaryColor),
                    const SizedBox(height: 20),

                    // 3️⃣ الإحصائيات
                    _buildStatsRow(),
                    const SizedBox(height: 20),

                    // 4️⃣ الخدمات السريعة
                    _buildSectionTitleWithAction('خدمات سريعة', isDark, 'عرض الكل', () => _goTo(context, const ServicesScreen())),
                    const SizedBox(height: 10),
                    _buildQuickServicesRow(),
                    const SizedBox(height: 24),

                    // 5️⃣ أفضل الأطباء
                    _buildSectionTitleWithAction('أفضل الأطباء', isDark, 'عرض الكل', () => _goTo(context, const DoctorsListScreen())),
                    const SizedBox(height: 10),
                    _buildTopDoctorsRow(),
                    const SizedBox(height: 24),

                    // 6️⃣ منتجات صيدلية
                    _buildSectionTitleWithAction('منتجات صيدلية', isDark, 'عرض الكل', () => _goTo(context, const MedicinesScreen())),
                    const SizedBox(height: 10),
                    _buildProductsRow(),
                    const SizedBox(height: 24),

                    // 7️⃣ المختبرات المميزة
                    _buildSectionTitleWithAction('مختبرات مميزة', isDark, 'عرض الكل', () => _goTo(context, const LabsListScreen())),
                    const SizedBox(height: 10),
                    _buildFeaturedLabsRow(isDark),
                    const SizedBox(height: 24),

                    // 8️⃣ المستشفيات المميزة
                    _buildSectionTitleWithAction('مستشفيات مميزة', isDark, 'عرض الكل', () => _goTo(context, const EmergencyNumbers())),
                    const SizedBox(height: 10),
                    _buildFeaturedHospitalsRow(),
                    const SizedBox(height: 24),

                    // 9️⃣ نصائح يومية
                    _buildSectionTitle('نصائح يومية', isDark),
                    const SizedBox(height: 10),
                    _buildDailyTipsGrid(),
                    const SizedBox(height: 24),

                    // 🔟 مجتمع صحتك
                    _buildSectionTitle('مجتمع صحتك', isDark),
                    const SizedBox(height: 10),
                    ..._communityPosts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final post = entry.value;
                      return _buildCommunityPostCard(post, index, isDark);
                    }),
                    const SizedBox(height: 50),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🔧 أجزاء الواجهة
  // ============================================================

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'ابحث عن طبيب، دواء، أو خدمة...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              onTap: () => showSearch(context: context, delegate: AppSearchDelegate()),
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ البانر مع النقاط داخله في الجزء الأيسر
  Widget _buildBannerCarousel(bool isDark, Color primaryColor) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.95,
            onPageChanged: (index, reason) => setState(() => _currentBanner = index),
          ),
          items: _bannerImages.map((imagePath) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
        // ✅ النقاط داخل البانر في الجزء الأيسر
        Positioned(
          bottom: 12,
          left: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _bannerImages.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = _currentBanner == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'icon': Icons.medical_services, 'value': '150+', 'label': 'أطباء', 'color': AppColors.primary},
      {'icon': Icons.people, 'value': '10K+', 'label': 'مرضى', 'color': AppColors.success},
      {'icon': Icons.chat, 'value': '5K+', 'label': 'استشارات', 'color': AppColors.info},
      {'icon': Icons.star, 'value': '4.8', 'label': 'تقييم', 'color': Colors.amber},
    ];

    return Row(
      children: stats.map((stat) {
        final color = stat['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ✅ عنوان القسم مع زر "عرض الكل"
  Widget _buildSectionTitleWithAction(String title, bool isDark, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildQuickServicesRow() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          final color = service['color'] as Color;
          return GestureDetector(
            onTap: () => _goTo(context, service['screen'] as Widget),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(service['icon'] as IconData, color: color, size: 26),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['label'] as String,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  Widget _buildProductsRow() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return GestureDetector(
            onTap: () => _goTo(context, const MedicinesScreen()),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: product['image'],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildShimmerEffect(width: 80, height: 80),
                      errorWidget: (context, url, error) => Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.medication, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product['category'],
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${product['price']} ر.ي',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0D5257),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ دالة عرض المختبرات المميزة
  Widget _buildFeaturedLabsRow(bool isDark) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredLabs.length,
        itemBuilder: (context, index) {
          final lab = _featuredLabs[index];
          return GestureDetector(
            onTap: () => _goTo(context, const LabsListScreen()),
            child: Container(
              width: 250,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: lab['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildShimmerEffect(width: 50, height: 50),
                      errorWidget: (context, url, error) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: const Icon(Icons.science, color: Colors.grey, size: 25),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lab['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lab['location'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ دالة عرض المستشفيات المميزة
  Widget _buildFeaturedHospitalsRow() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredHospitals.length,
        itemBuilder: (context, index) {
          final hospital = _featuredHospitals[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(hospital['image'] as String),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        hospital['location'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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
    );
  }

  Widget _buildDailyTipsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: _dailyTips.length,
      itemBuilder: (context, index) {
        final tip = _dailyTips[index];
        final color = tip['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tip['icon'] as IconData, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                tip['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                tip['subtitle'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityPostCard(Map<String, dynamic> post, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    post['author'][0],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        post['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          ClipRRect(
            child: CachedNetworkImage(
              imageUrl: post['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildShimmerEffect(height: 200),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(index),
                  child: Icon(
                    post['liked'] ? Icons.favorite : Icons.favorite_border,
                    color: post['liked'] ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post['likes']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _showComments(index),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post['comments']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _sharePost(index),
                  child: Icon(
                    Icons.repeat,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post['shares']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.bookmark_border,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  post['content'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GestureDetector(
              onTap: () => _showComments(index),
              child: Text(
                'عرض جميع التعليقات (${post['comments']})',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🔍 AppSearchDelegate - البحث المتقدم
// ============================================================
class AppSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'ابحث عن طبيب، دواء، خدمة...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return _buildRecentSearches();
    return _buildSearchResults();
  }

  Widget _buildRecentSearches() {
    final recentSearches = [
      'طبيب باطنية', 'باراسيتامول', 'مختبر تحاليل',
      'صيدلية 24 ساعة', 'استشارة قلبية', 'تحليل دم شامل'
    ];
    return ListView.builder(
      itemCount: recentSearches.length,
      itemBuilder: (context, index) => ListTile(
        leading: const Icon(Icons.history, color: Colors.grey),
        title: Text(recentSearches[index]),
        onTap: () {
          query = recentSearches[index];
          showResults(context);
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('جاري البحث عن "$query"...', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('بحث متقدم'),
          ),
        ],
      ),
    );
  }
}
