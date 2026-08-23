import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/health_score_service.dart';
import 'package:sehatak/core/services/cache_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/app_search_delegate.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_details_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

// ============================================================
// 📐 CustomClipper للشريط العلوي المنحني
// ============================================================
class BottomCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

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

  // ============================================================
  // 📊 متغيرات الحالة
  // ============================================================
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
  bool _isOffline = false;
  double _appBarOpacity = 1.0;

  // ============================================================
  // 📦 البيانات
  // ============================================================
  final List<String> _bannerImages = ImageKit.bannerList;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': 'd1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1},
    {'id': 'd2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2},
    {'id': 'd3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3},
    {'id': 'd4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4},
    {'id': 'd5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5},
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': 'assets/images/services/pharmacy.png', 'label': 'صيدلية', 'screen': const PharmacyScreenTemp()},
    {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ', 'screen': const EmergencyNumbers()},
    {'icon': 'assets/images/services/medical_community.png', 'label': 'خدمات منزلية', 'screen': const ServicesScreen()},
    {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم', 'screen': const BloodDonationScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'أطباء', 'screen': const DoctorsListScreenTemp()},
    {'icon': 'assets/images/services/laboratory.png', 'label': 'مختبرات', 'screen': const LabsListScreenTemp()},
    {'icon': 'assets/images/services/health_tips.png', 'label': 'صحة', 'screen': const HealthDashboard()},
    {'icon': 'assets/images/services/wallet.png', 'label': 'محفظة', 'screen': const WalletScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'استشارة', 'screen': const ConsultationScreen()},
    {'icon': 'assets/images/services/map_location.png', 'label': 'بالقرب منك', 'screen': const InteractiveMapScreen()},
  ];

  final List<Map<String, dynamic>> _products = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 20, 'rating': 4.5},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageKit.medicine2, 'category': 'فيتامينات', 'discount': 15, 'rating': 4.8},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageKit.medicine3, 'category': 'أجهزة طبية', 'discount': 10, 'rating': 4.7},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'image': ImageKit.medicine4, 'category': 'مضادات حيوية', 'discount': 0, 'rating': 4.3},
    {'name': 'ديكلوفيناك 50mg', 'price': 650, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 5, 'rating': 4.2},
    {'name': 'نابروكسين 250mg', 'price': 550, 'image': ImageKit.medicine2, 'category': 'مضادات التهابية', 'discount': 10, 'rating': 4.4},
    {'name': 'أسبرين 100mg', 'price': 300, 'image': ImageKit.medicine3, 'category': 'مسكنات', 'discount': 0, 'rating': 4.1},
    {'name': 'إيبوبروفين 400mg', 'price': 750, 'image': ImageKit.medicine4, 'category': 'مسكنات', 'discount': 5, 'rating': 4.6},
  ];

  final List<Map<String, dynamic>> _featuredHospitals = [
    {'id': 'h1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء - حدة', 'image': ImageKit.hospital1, 'rating': 4.9, 'open': true},
    {'id': 'h2', 'name': 'مستشفى آزال', 'location': 'صنعاء', 'image': ImageKit.hospital2, 'rating': 4.8, 'open': true},
    {'id': 'h3', 'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageKit.hospital3, 'rating': 4.7, 'open': true},
    {'id': 'h4', 'name': 'مستشفى الكويت', 'location': 'صنعاء', 'image': ImageKit.hospital4, 'rating': 4.8, 'open': true},
    {'id': 'h5', 'name': 'المستشفى الجمهوري', 'location': 'صنعاء', 'image': ImageKit.hospital5, 'rating': 4.6, 'open': true},
    {'id': 'h6', 'name': 'مستشفى الثورة العام', 'location': 'صنعاء', 'image': ImageKit.hospital6, 'rating': 4.5, 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredLabs = [
    {'id': 'l1', 'name': 'مختبرات الرازي', 'location': 'صنعاء', 'image': ImageKit.lab1, 'rating': 4.9, 'open': true},
    {'id': 'l2', 'name': 'مختبرات العولقي', 'location': 'صنعاء', 'image': ImageKit.lab2, 'rating': 4.8, 'open': true},
    {'id': 'l3', 'name': 'مختبرات المأمون', 'location': 'صنعاء', 'image': ImageKit.lab3, 'rating': 4.7, 'open': true},
    {'id': 'l4', 'name': 'مختبرات الذبحاني', 'location': 'صنعاء', 'image': ImageKit.lab1, 'rating': 4.6, 'open': true},
    {'id': 'l5', 'name': 'مختبرات النخبة', 'location': 'صنعاء', 'image': ImageKit.lab2, 'rating': 4.5, 'open': true},
    {'id': 'l6', 'name': 'مختبرات اليمن الحديثة', 'location': 'صنعاء', 'image': ImageKit.lab3, 'rating': 4.4, 'open': true},
  ];

  final List<Map<String, dynamic>> _featuredPharmacies = [
    {'id': 'p1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء', 'image': ImageKit.pharmacy1, 'rating': 4.9, 'open': true},
    {'id': 'p2', 'name': 'صيدلية عالم الصيدلة', 'location': 'صنعاء', 'image': ImageKit.pharmacy2, 'rating': 4.8, 'open': true},
    {'id': 'p3', 'name': 'صيدلية النهضة', 'location': 'صنعاء', 'image': ImageKit.pharmacy3, 'rating': 4.7, 'open': true},
    {'id': 'p4', 'name': 'صيدلية اليمن الحديثة', 'location': 'صنعاء', 'image': ImageKit.pharmacy1, 'rating': 4.6, 'open': true},
    {'id': 'p5', 'name': 'صيدلية الشفاء', 'location': 'صنعاء', 'image': ImageKit.pharmacy2, 'rating': 4.5, 'open': false},
    {'id': 'p6', 'name': 'صيدلية الأمانة', 'location': 'صنعاء', 'image': ImageKit.pharmacy3, 'rating': 4.4, 'open': true},
  ];

  final List<Map<String, dynamic>> _healthArticles = [
    {'title': 'فوائد المشي اليومي', 'category': 'صحة عامة', 'time': 'منذ ساعة', 'image': ImageKit.morningWalk},
    {'title': 'نصائح لتقوية المناعة', 'category': 'تغذية', 'time': 'منذ 3 ساعات', 'image': ImageKit.immuneBoost},
    {'title': 'أهمية النوم الصحي', 'category': 'صحة نفسية', 'time': 'منذ 5 ساعات', 'image': ImageKit.sleepTips},
    {'title': 'العناية بالبشرة في الصيف', 'category': 'جلدية', 'time': 'منذ يوم', 'image': ImageKit.skinCare},
  ];

  final List<Map<String, dynamic>> _dailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'content': 'شرب 8 أكواب من الماء يومياً يحسن صحة البشرة ويساعد في التخلص من السموم.'},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.'},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.'},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'content': 'تناول 5 حصص من الفواكه والخضار يومياً يوفر الفيتامينات.'},
  ];

  final List<Map<String, dynamic>> _communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'avatar': 'س', 'image': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'time': 'منذ ساعة', 'liked': false, 'commentList': ['نصائح رائعة!', 'شكراً دكتورة', 'مفيد جداً']},
    {'id': 2, 'author': 'د. خالد النخلاني', 'avatar': 'خ', 'image': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 95, 'comments': 8, 'shares': 5, 'time': 'منذ 3 ساعات', 'liked': false, 'commentList': ['معلومة قيمة', 'سأطبقها']},
    {'id': 3, 'author': 'د. أحمد المؤيد', 'avatar': 'أ', 'image': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.', 'likes': 210, 'comments': 22, 'shares': 12, 'time': 'منذ 5 ساعات', 'liked': true, 'commentList': ['أحسنت', 'مفيد جداً', 'شكراً دكتور']},
    {'id': 4, 'author': 'د. أسماء الهندي', 'avatar': 'ه', 'image': ImageKit.immuneBoost, 'title': 'قوة المناعة', 'content': 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.', 'likes': 78, 'comments': 5, 'shares': 3, 'time': 'منذ يوم', 'liked': false, 'commentList': ['معلومات مفيدة', 'شكراً']},
    {'id': 5, 'author': 'د. محمد العلاي', 'avatar': 'م', 'image': ImageKit.sleepTips, 'title': 'نصائح النوم الصحي', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.', 'likes': 150, 'comments': 12, 'shares': 7, 'time': 'منذ يومين', 'liked': false, 'commentList': ['سأطبق هذه النصائح', 'مفيد']},
  ];

  // ============================================================
  // 🔄 دورة الحياة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _initializeData();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final maxScroll = widget.scrollController?.position.maxScrollExtent ?? 0;
    final currentScroll = widget.scrollController?.position.pixels ?? 0;
    setState(() {
      _appBarOpacity = 1.0 - (currentScroll / maxScroll).clamp(0.0, 0.5);
    });
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
          _isOffline = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'حدث خطأ في تحميل البيانات';
          _isOffline = true;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _initializeData();
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
        return Icon(Icons.circle, color: AppColors.primary, size: size);
      },
    );
  }

  // ============================================================
  // ✅ شريط البحث العائم
  // ============================================================
  Widget _buildFloatingSearchBar(bool isDark) {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: AppSearchDelegate(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icons/search/Search button.png',
              width: 22,
              height: 22,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 22);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ابحث عن طبيب، دواء، أو خدمة...',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
            Image.asset(
              'assets/images/chat/microphone.png',
              width: 22,
              height: 22,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.mic, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 22);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📱 الشريط العلوي المنحني
  // ============================================================
  Widget _buildCurvedAppBar(bool isDark) {
    return Opacity(
      opacity: _appBarOpacity,
      child: ClipPath(
        clipper: BottomCurvedClipper(),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // ✅ الصورة الرمزية
                  Hero(
                    tag: 'user_avatar',
                    child: GestureDetector(
                      onTap: () => _goTo(context, const PatientProfile()),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          _isLoggedIn ? _userName[0].toUpperCase() : 'م',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ✅ النصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLoggedIn ? 'مرحباً، $_userName 👋' : 'مرحباً بك في صحتك',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isLoggedIn ? 'كيف تشعر اليوم؟' : 'سجل دخولك للاستفادة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        if (_isOffline)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '📶 غير متصل',
                              style: TextStyle(fontSize: 9, color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ✅ أيقونات الإشعارات والسلة
                  GestureDetector(
                    onTap: () => _goTo(context, const NotificationsScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/icons/top_bar/notifications.png',
                        width: 26,
                        height: 26,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.notifications, color: Colors.white, size: 26);
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _goTo(context, const CartScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/icons/top_bar/Shopping cart.png',
                        width: 26,
                        height: 26,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.shopping_cart, color: Colors.white, size: 26);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🏠 بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildShimmerLoader(isDark);
    }

    if (_hasError) {
      return _buildErrorScreen(isDark);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            // ✅ الشريط العلوي المنحني
            SliverToBoxAdapter(
              child: _buildCurvedAppBar(isDark),
            ),
            // ✅ شريط البحث العائم (بـ margin سالب)
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: _buildFloatingSearchBar(isDark),
              ),
            ),
            // ✅ باقي المحتوى
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildBannerCarousel(isDark),
                  const SizedBox(height: 16),
                  if (_isLoggedIn) ...[
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionTitleWithAction('خدمات سريعة', isDark, 'عرض الكل',
                    () => _goTo(context, const ServicesScreen())),
                  const SizedBox(height: 8),
                  _buildQuickServicesRow(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('أفضل الأطباء', isDark, 'عرض الكل',
                    () => _goTo(context, const DoctorsListScreenTemp())),
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
                    () => _goTo(context, const LabsListScreenTemp())),
                  const SizedBox(height: 8),
                  _buildFeaturedLabsGrid(),
                  const SizedBox(height: 16),
                  _buildSectionTitleWithAction('صيدليات مميزة', isDark, 'عرض الكل',
                    () => _goTo(context, const PharmacyScreenTemp())),
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

  // ============================================================
  // 📊 دوال البناء (جميع الدوال كاملة)
  // ============================================================

  Widget _buildShimmerLoader(bool isDark) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Column(
          children: [
            Container(height: 120, margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 8),
            Container(height: 60, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 8),
            Container(height: 200, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 8),
            Container(height: 100, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_errorMessage, style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(bool isDark) {
    if (_bannerImages.isEmpty) {
      return Container(
        height: 200,
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
            height: 200,
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
                  height: 200,
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

  Widget _buildStatsRow() {
    final statsData = [
      {'icon': Icons.local_fire_department, 'value': _caloriesAnim, 'label': 'سعرة حرارية', 'color': AppColors.primary, 'format': 'int'},
      {'icon': Icons.directions_walk, 'value': _stepsAnim, 'label': 'خطوة', 'color': AppColors.primary, 'format': 'int'},
      {'icon': Icons.bedtime, 'value': _sleepAnim, 'label': 'ساعات النوم', 'color': AppColors.primary, 'format': 'double'},
      {'icon': Icons.favorite, 'value': _heartAnim, 'label': 'نبضة/دقيقة', 'color': AppColors.primary, 'format': 'int'},
    ];

    return Row(
      children: statsData.map((stat) {
        final color = stat['color'] as Color;
        final value = stat['value'] as double;
        final isInt = stat['format'] == 'int';

        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              final displayVal = isInt ? val.toInt().toString() : val.toStringAsFixed(1);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(stat['icon'] as IconData, color: color, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      displayVal,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    Text(
                      stat['label'] as String,
                      style: const TextStyle(fontSize: 14, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithAction(String title, bool isDark, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
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
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServicesRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          return GestureDetector(
            onTap: () => _goTo(context, service['screen'] as Widget),
            child: Container(
              width: 86,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: _buildServiceIcon(service['icon'] as String, size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopDoctorsGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: _topDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _topDoctors[index];
        return GestureDetector(
          onTap: () => _goTo(context, DoctorDetailsScreen(doctorId: doctor['id'] as String)),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: AppImage(
                        imageUrl: doctor['image'] as String,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              doctor['rating'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor['specialty'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goTo(context, DoctorDetailsScreen(doctorId: doctor['id'] as String)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text(
                            'حجز موعد',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final hasDiscount = (product['discount'] as int) > 0;
          final priceAfterDiscount = hasDiscount
              ? (product['price'] as int) * (1 - (product['discount'] as int) / 100)
              : product['price'] as int;

          return GestureDetector(
            onTap: () => _goTo(context, const MedicinesScreen()),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppImage(
                          imageUrl: product['image'] as String,
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (hasDiscount)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${product['discount']}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product['category'] as String,
                      style: const TextStyle(fontSize: 9, color: AppColors.primary),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          '${product['price']} ر.ي',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${priceAfterDiscount.toInt()} ر.ي',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary,
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

  Widget _buildFeaturedHospitalsGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _featuredHospitals.length,
      itemBuilder: (context, index) {
        final hospital = _featuredHospitals[index];
        return GestureDetector(
          onTap: () {
            _goTo(context, HospitalDetailsScreen(
              hospitalId: hospital['id'] as String,
              hospitalData: hospital,
            ));
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: AppImage(
                        imageUrl: hospital['image'] as String,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              hospital['rating'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: hospital['open'] == true
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hospital['open'] == true ? 'مفتوح' : 'مغلق',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        hospital['location'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _goTo(context, HospitalDetailsScreen(
                              hospitalId: hospital['id'] as String,
                              hospitalData: hospital,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text(
                            'تفاصيل',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedLabsGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _featuredLabs.length,
      itemBuilder: (context, index) {
        final lab = _featuredLabs[index];
        return GestureDetector(
          onTap: () => _goTo(context, const LabsListScreenTemp()),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AppImage(
                    imageUrl: lab['image'] as String,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lab['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lab['location'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goTo(context, const LabsListScreenTemp()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text(
                            'حجز',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedPharmaciesGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _featuredPharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = _featuredPharmacies[index];
        return GestureDetector(
          onTap: () => _goTo(context, const PharmacyScreenTemp()),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AppImage(
                    imageUrl: pharmacy['image'] as String,
                    height: 90,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pharmacy['location'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goTo(context, const PharmacyScreenTemp()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text(
                            'طلب',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticlesGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: _healthArticles.length,
      itemBuilder: (context, index) {
        final article = _healthArticles[index];
        return GestureDetector(
          onTap: () => _goTo(context, const ArticlesScreen()),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AppImage(
                    imageUrl: article['image'] as String,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article['category'] as String,
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        article['time'] as String,
                        style: TextStyle(
                          fontSize: 8,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyTipsGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        return GestureDetector(
          onTap: () => _showTipDetails(tip),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tip['icon'] as IconData,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  tip['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  tip['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'اقرأ المزيد',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityPosts() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: _communityPosts.map((post) {
        final index = _communityPosts.indexOf(post);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(14),
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      post['avatar'] as String,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
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
                          post['author'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          post['time'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.more_horiz, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                post['content'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              if (post['image'] != null)
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: AppImage(
                        imageUrl: post['image'] as String,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppImage(
                      imageUrl: post['image'] as String,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleLike(index),
                    child: Row(
                      children: [
                        Icon(
                          post['liked'] == true ? Icons.favorite : Icons.favorite_border,
                          color: post['liked'] == true ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post['likes']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => _showComments(post, index),
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${post['comments']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () => _sharePost(index),
                    child: Row(
                      children: [
                        Icon(Icons.share, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${post['shares']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // ❤️ دوال التفاعل
  // ============================================================
  void _toggleLike(int index) {
    setState(() {
      _communityPosts[index]['liked'] = !_communityPosts[index]['liked'];
      _communityPosts[index]['likes'] += _communityPosts[index]['liked'] ? 1 : -1;
    });
  }

  void _sharePost(int index) {
    final post = _communityPosts[index];
    ToastService.showSuccess('✅ تم مشاركة: ${post['title']}');
  }

  void _showTipDetails(Map<String, dynamic> tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Icon(tip['icon'] as IconData, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(tip['title'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 8),
            Text(tip['subtitle'] as String, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const Divider(height: 24),
            Text(tip['content'] as String, style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(Map<String, dynamic> post, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('التعليقات (${post['comments']})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: (post['commentList'] as List).length,
                itemBuilder: (context, i) {
                  final comment = (post['commentList'] as List)[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text('م', style: TextStyle(color: AppColors.primary))),
                    title: Text(comment),
                    subtitle: Text('منذ دقيقة', style: TextStyle(color: Colors.grey[500])),
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
