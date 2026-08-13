// (full file content with inserted _buildSearchBar)

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/health_score_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/data/models/doctor_model.dart';
import 'package:sehatak/data/models/product_model.dart';
import 'package:sehatak/data/models/hospital_model.dart';
import 'package:sehatak/data/models/lab_model.dart';
import 'package:sehatak/data/models/pharmacy_model.dart';
import 'package:sehatak/data/models/article_model.dart';
import 'package:sehatak/data/models/community_post_model.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;
  final ValueNotifier<bool>? isBottomBarVisible;

  const HomeTab({super.key, this.scrollController, this.isBottomBarVisible});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userName = 'مستخدم';
  int _currentBanner = 0;
  bool _hasError = false;
  String _errorMessage = '';
  double _healthScore = 0.0;
  double _caloriesAnim = 0;
  double _stepsAnim = 0;
  double _sleepAnim = 0;
  double _heartAnim = 0;

  final List<String> _bannerImages = ImageKit.bannerList;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5},
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': 'assets/images/services/pharmacy.png', 'label': 'صيدلية', 'screen': const MedicinesScreen()},
    {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ', 'screen': const EmergencyNumbers()},
    {'icon': 'assets/images/services/medical_community.png', 'label': 'خدمات منزلية', 'screen': const ServicesScreen()},
    {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم', 'screen': const BloodDonationScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'أطباء', 'screen': const DoctorsListScreen()},
    {'icon': 'assets/images/services/laboratory.png', 'label': 'مختبرات', 'screen': const LabsListScreen()},
    {'icon': 'assets/images/services/health_tips.png', 'label': 'صحة', 'screen': const HealthDashboard()},
    {'icon': 'assets/images/services/wallet.png', 'label': 'محفظة', 'screen': const WalletScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'استشارة', 'screen': const ConsultationScreen()},
    {'icon': 'assets/images/services/map_location.png', 'label': 'بالقرب منك', 'screen': const InteractiveMapScreen()},
  ];

  final List<Map<String, dynamic>> _stats = [
    {'icon': Icons.local_fire_department, 'value': '2,450', 'label': 'سعرة حرارية', 'color': AppColors.primary, 'subtitle': 'اليوم'},
    {'icon': Icons.directions_walk, 'value': '8,542', 'label': 'خطوة', 'color': AppColors.primary, 'subtitle': 'اليوم'},
    {'icon': Icons.bedtime, 'value': '7.5', 'label': 'ساعات النوم', 'color': AppColors.primary, 'subtitle': 'الليلة الماضية'},
    {'icon': Icons.favorite, 'value': '72', 'label': 'نبضة/دقيقة', 'color': AppColors.primary, 'subtitle': 'الآن'},
  ];

  final List<Map<String, dynamic>> _dailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'content': 'شرب 8 أكواب من الماء يومياً يحسن صحة البشرة وي[...]'},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب وال[...]'},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدي[...]'},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'content': 'تناول 5 حصص من الفواكه والخضار يومياً يوفر الفيتامي[...]'},
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 20},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageKit.medicine2, 'category': 'فيتامينات', 'discount': 15},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageKit.medicine3, 'category': 'أجهزة طبية', 'discount': 10},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'image': ImageKit.medicine4, 'category': 'مضادات حيوية', 'discount': 0},
    {'name': 'ديكلوفيناك 50mg', 'price': 650, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 5},
    {'name': 'نابروكسين 250mg', 'price': 550, 'image': ImageKit.medicine2, 'category': 'مضادات التهابية', 'discount': 10},
    {'name': 'أسبرين 100mg', 'price': 300, 'image': ImageKit.medicine3, 'category': 'مسكنات', 'discount': 0},
    {'name': 'إيبوبروفين 400mg', 'price': 750, 'image': ImageKit.medicine4, 'category': 'مسكنات', 'discount': 5},
  ];

  final List<Map<String, dynamic>> _featuredHospitals = [
    {'id': '1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء', 'image': ImageKit.hospital1, 'rating': 4.9, 'open': true},
    {'id': '2', 'name': 'مستشفى آزال', 'location': 'صنعاء', 'image': ImageKit.hospital2, 'rating': 4.8, 'open': true},
    {'id': '3', 'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageKit.hospital3, 'rating': 4.7, 'open': true},
    {'id': '4', 'name': 'مستشفى الكويت', 'location': 'صنعاء', 'image': ImageKit.hospital4, 'rating': 4.8, 'open': true},
    {'id': '5', 'name': 'المستشفى الجمهوري', 'location': 'صنعاء', 'image': ImageKit.hospital5, 'rating': 4.6, 'open': true},
    {'id': '6', 'name': 'مستشفى الثورة العام', 'location': 'صنعاء', 'image': ImageKit.hospital6, 'rating': 4.5, 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredLabs = [
    {'id': '1', 'name': 'مختبرات الرازي', 'location': 'صنعاء', 'image': ImageKit.lab1, 'rating': 4.9, 'open': true},
    {'id': '2', 'name': 'مختبرات العولقي', 'location': 'صنعاء', 'image': ImageKit.lab2, 'rating': 4.8, 'open': true},
    {'id': '3', 'name': 'مختبرات المأمون', 'location': 'صنعاء', 'image': ImageKit.lab3, 'rating': 4.7, 'open': true},
    {'id': '4', 'name': 'مختبرات الذبحاني', 'location': 'صنعاء', 'image': ImageKit.lab1, 'rating': 4.6, 'open': true},
    {'id': '5', 'name': 'مختبرات النخبة', 'location': 'صنعاء', 'image': ImageKit.lab2, 'rating': 4.5, 'open': true},
    {'id': '6', 'name': 'مختبرات اليمن الحديثة', 'location': 'صنعاء', 'image': ImageKit.lab3, 'rating': 4.4, 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredPharmacies = [
    {'id': '1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء', 'image': ImageKit.pharmacy1, 'rating': 4.9, 'open': true},
    {'id': '2', 'name': 'صيدلية عالم الصيدلة', 'location': 'صنعاء', 'image': ImageKit.pharmacy2, 'rating': 4.8, 'open': true},
    {'id': '3', 'name': 'صيدلية النهضة', 'location': 'صنعاء', 'image': ImageKit.pharmacy3, 'rating': 4.7, 'open': true},
    {'id': '4', 'name': 'صيدلية اليمن الحديثة', 'location': 'صنعاء', 'image': ImageKit.pharmacy1, 'rating': 4.6, 'open': true},
    {'id': '5', 'name': 'صيدلية الشفاء', 'location': 'صنعاء', 'image': ImageKit.pharmacy2, 'rating': 4.5, 'open': false},
    {'id': '6', 'name': 'صيدلية الأمانة', 'location': 'صنعاء', 'image': ImageKit.pharmacy3, 'rating': 4.4, 'open': true},
  ];

  final List<Map<String, dynamic>> _healthArticles = [
    {'title': 'فوائد المشي اليومي', 'category': 'صحة عامة', 'time': 'منذ ساعة', 'image': ImageKit.morningWalk},
    {'title': 'نصائح لتقوية المناعة', 'category': 'تغذية', 'time': 'منذ 3 ساعات', 'image': ImageKit.immuneBoost},
    {'title': 'أهمية النوم الصحي', 'category': 'صحة نفسية', 'time': 'منذ 5 ساعات', 'image': ImageKit.sleepTips},
    {'title': 'العناية بالبشرة في الصيف', 'category': 'جلدية', 'time': 'منذ يوم', 'image': ImageKit.skinCare},
  ];

  final List<Map<String, dynamic>> _communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'avatar': 'س', 'image': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف,[...]'},
    {'id': 2, 'author': 'د. خالد النخلاني', 'avatar': 'خ', 'image': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يو[...]'},
    {'id': 3, 'author': 'د. أحمد المؤيد', 'avatar': 'أ', 'image': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس ال[...]'},
    {'id': 4, 'author': 'د. أسماء الهندي', 'avatar': 'ه', 'image': ImageKit.immuneBoost, 'title': 'قوة المناعة', 'content': 'الفيتامينات والمعادن تلع[...]'},
    {'id': 5, 'author': 'د. محمد العلاي', 'avatar': 'م', 'image': ImageKit.sleepTips, 'title': 'نصائح النوم الصحي', 'content': 'النوم 7-8 ساعات يومياً [...]'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _loadUserData();
      await _loadHealthScore();
      _startAnimation();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'حدث خطأ في تحميل البيانات';
        });
      }
    }
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        _isLoggedIn = user != null;
        if (user != null) {
          _userName = user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم';
        }
      });
    }
  }

  Future<void> _loadHealthScore() async {
    try {
      final score = await HealthScoreService.calculateHealthScore();
      if (mounted) {
        setState(() => _healthScore = score);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _healthScore = 0.0);
      }
    }
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _caloriesAnim = 2450;
          _stepsAnim = 8542;
          _sleepAnim = 7.5;
          _heartAnim = 72;
        });
      }
    });
  }

  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildServiceIcon(String iconPath, {double size = 32}) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: Colors.green, size: size);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildShimmerLoader();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 90,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'user_avatar',
                        child: GestureDetector(
                          onTap: () => _goTo(context, const PatientProfile()),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              _isLoggedIn ? _userName[0] : 'م',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                              _isLoggedIn ? 'مرحباً، $_userName 👋' : 'منصة صحتك',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'كيف تشعر اليوم؟',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _goTo(context, const NotificationsScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: _buildServiceIcon('assets/images/services/notifications.png', size: 24),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _goTo(context, const CartScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: _buildServiceIcon('assets/images/services/wallet.png', size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(isDark),
                  const SizedBox(height: 16),
                  _buildBannerCarousel(isDark),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('خدمات سريعة', isDark, 'عرض الكل', 
                    () => _goTo(context, const ServicesScreen())),
                  const SizedBox(height: 8),
                  _buildQuickServicesRow(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('أفضل الأطباء', isDark, 'عرض الكل', 
                    () => _goTo(context, const DoctorsListScreen())),
                  const SizedBox(height: 8),
                  _buildTopDoctorsGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('منتجات صيدلية', isDark, 'عرض الكل', 
                    () => _goTo(context, const MedicinesScreen())),
                  const SizedBox(height: 8),
                  _buildProductsRow(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('مستشفيات مميزة', isDark, 'عرض الكل', 
                    () => _goTo(context, const HospitalScreen())),
                  const SizedBox(height: 8),
                  _buildFeaturedHospitalsGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('مختبرات مميزة', isDark, 'عرض الكل', 
                    () => _goTo(context, const LabsListScreen())),
                  const SizedBox(height: 8),
                  _buildFeaturedLabsGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('صيدليات مميزة', isDark, 'عرض الكل', 
                    () => _goTo(context, const PharmacyScreen())),
                  const SizedBox(height: 8),
                  _buildFeaturedPharmaciesGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('أحدث المقالات', isDark),
                  const SizedBox(height: 8),
                  _buildArticlesGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('نصائح يومية', isDark),
                  const SizedBox(height: 8),
                  _buildDailyTipsGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('مجتمع صحتك', isDark),
                  const SizedBox(height: 8),
                  _buildCommunityPosts(),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دوال البناء الأساسية

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
              onChanged: (_) {},
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'ابحث هنا...',
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(bool isDark) {
    if (_bannerImages.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('لا توجد بانرات')),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.95,
            onPageChanged: (index, reason) => setState(() => _currentBanner = index),
          ),
          items: _bannerImages.map((url) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(
                  imageUrl: url,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 12,
          left: 16,
          child: Row(
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

  // ... rest of the file unchanged (kept as originally)
