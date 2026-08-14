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
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

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
  bool _isOffline = false;
  bool _hasCachedData = false;

  // ✅ بيانات الكاش
  Map<String, dynamic> _cachedData = {};

  final List<String> _bannerImages = ImageKit.bannerList;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5},
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': 'assets/images/services/pharmacy.png', 'label': 'صيدلية', 'screen': const PharmacyScreen()},
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
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': Icons.water_drop, 'content': 'شرب 8 أكواب من الماء يومياً يحسن صحة البشرة ويساعد في التخلص من السموم ويحسن وظائف الكلى.'},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': Icons.directions_walk, 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري ويعزز الصحة النفسية ويحسن جودة النوم.'},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': Icons.nights_stay, 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية ويساعد في تقوية الذاكرة والمناعة.'},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': Icons.apple, 'content': 'تناول 5 حصص من الفواكه والخضار يومياً يوفر الفيتامينات والمعادن الضرورية للجسم ويعزز المناعة.'},
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
    {'id': '1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء - حدة', 'image': ImageKit.hospital1, 'rating': 4.9, 'open': true},
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
    {'id': 1, 'author': 'د. سارة العمري', 'avatar': 'س', 'image': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'time': 'منذ ساعة', 'liked': false, 'commentList': ['نصائح رائعة!', 'شكراً دكتورة', 'مفيد جداً']},
    {'id': 2, 'author': 'د. خالد النخلاني', 'avatar': 'خ', 'image': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 95, 'comments': 8, 'shares': 5, 'time': 'منذ 3 ساعات', 'liked': false, 'commentList': ['معلومة قيمة', 'سأطبقها']},
    {'id': 3, 'author': 'د. أحمد المؤيد', 'avatar': 'أ', 'image': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.', 'likes': 210, 'comments': 22, 'shares': 12, 'time': 'منذ 5 ساعات', 'liked': true, 'commentList': ['أحسنت', 'مفيد جداً', 'شكراً دكتور']},
    {'id': 4, 'author': 'د. أسماء الهندي', 'avatar': 'ه', 'image': ImageKit.immuneBoost, 'title': 'قوة المناعة', 'content': 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.', 'likes': 78, 'comments': 5, 'shares': 3, 'time': 'منذ يوم', 'liked': false, 'commentList': ['معلومات مفيدة', 'شكراً']},
    {'id': 5, 'author': 'د. محمد العلاي', 'avatar': 'م', 'image': ImageKit.sleepTips, 'title': 'نصائح النوم الصحي', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.', 'likes': 150, 'comments': 12, 'shares': 7, 'time': 'منذ يومين', 'liked': false, 'commentList': ['سأطبق هذه النصائح', 'مفيد']},
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // ✅ حفظ البيانات في الكاش
  Future<void> _saveDataToCache() async {
    try {
      await CacheService.saveData('home_data', {
        'topDoctors': _topDoctors,
        'quickServices': _quickServices,
        'products': _products,
        'featuredHospitals': _featuredHospitals,
        'featuredLabs': _featuredLabs,
        'featuredPharmacies': _featuredPharmacies,
        'healthArticles': _healthArticles,
        'dailyTips': _dailyTips,
        'communityPosts': _communityPosts,
      });
    } catch (e) {
      print('❌ خطأ في حفظ الكاش: $e');
    }
  }

  // ✅ تحميل البيانات من الكاش
  void _loadDataFromCache() {
    try {
      final cached = CacheService.getData('home_data');
      if (cached != null) {
        _cachedData = cached;
        _hasCachedData = true;
      }
    } catch (e) {
      print('❌ خطأ في تحميل الكاش: $e');
    }
  }

  // ✅ التحقق من وجود بيانات في الكاش
  bool _hasValidCache() {
    return _hasCachedData && _cachedData.isNotEmpty;
  }

  Future<void> _initializeData() async {
    // ✅ أولاً: تحميل البيانات من الكاش
    _loadDataFromCache();

    // ✅ ثانياً: محاولة تحميل البيانات من الإنترنت
    try {
      _loadUserData();
      await _loadHealthScore();
      _startAnimation();

      // ✅ حفظ البيانات في الكاش بعد التحميل
      await _saveDataToCache();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      // ✅ إذا فشل التحميل من الإنترنت ولكن يوجد كاش
      if (_hasValidCache()) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false;
            _isOffline = true; // ✅ وضع Offline ولكن مع عرض البيانات المخزنة
          });
        }
      } else {
        // ✅ لا يوجد إنترنت ولا كاش
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'لا يوجد اتصال بالإنترنت ولا بيانات مخزنة';
            _isOffline = true;
          });
        }
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
        return Icon(Icons.circle, color: AppColors.primary, size: size);
      },
    );
  }

  // ============================================================
  // 🔍 شريط البحث
  // ============================================================
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: AppSearchDelegate(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icons/search/Search button.png',
              width: 22,
              height: 22,
              color: AppColors.primary,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.search, color: AppColors.primary, size: 22);
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
              color: AppColors.primary,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.mic, color: AppColors.primary, size: 22);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🏠 بناء الواجهة الرئيسية
  // ============================================================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ حالة التحميل
    if (_isLoading) {
      return _buildShimmerLoader(isDark);
    }

    // ✅ حالة الخطأ (لا يوجد إنترنت ولا كاش)
    if (_hasError) {
      return _buildErrorScreen(isDark);
    }

    // ✅ عرض البيانات المخزنة (حتى في وضع Offline)
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
                              _isLoggedIn ? _userName[0].toUpperCase() : 'م',
                              style: TextStyle(
                                color: AppColors.primary,
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
                              _isLoggedIn ? 'كيف تشعر اليوم؟' : 'سجل دخولك للاستفادة',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            // ✅ عرض حالة الاتصال (Offline)
                            if (_isOffline)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '📶 غير متصل - عرض البيانات المخزنة',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // ✅ أيقونة الإشعارات
                      GestureDetector(
                        onTap: () => _goTo(context, const NotificationsScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/icons/top_bar/notifications.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black87, size: 28);
                            },
                          ),
                        ),
                      ),
                      // ✅ أيقونة السلة
                      GestureDetector(
                        onTap: () => _goTo(context, const CartScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/icons/top_bar/Shopping cart.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.shopping_cart, color: isDark ? Colors.white : Colors.black87, size: 28);
                            },
                          ),
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
                  _buildSearchBar(context, isDark),
                  const SizedBox(height: 16),
                  _buildBannerCarousel(isDark),
                  const SizedBox(height: 16),
                  // ✅ الإحصائيات - تظهر فقط للمستخدمين المسجلين
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

  // ============================================================
  // 📱 شاشة Shimmer
  // ============================================================
  Widget _buildShimmerLoader(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 90,
            floating: true,
            snap: true,
            backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Row(
                    children: [
                      CircleAvatar(radius: 20, backgroundColor: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 16, color: Colors.white)),
                      Container(width: 28, height: 28, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(width: 28, height: 28, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildShimmerBox(height: 50, radius: 25),
                const SizedBox(height: 16),
                _buildShimmerBox(height: 160, radius: 16),
                const SizedBox(height: 20),
                _buildShimmerBox(height: 80, radius: 10),
                const SizedBox(height: 24),
                _buildShimmerBox(height: 90, radius: 14),
                const SizedBox(height: 24),
                _buildShimmerBox(height: 200, radius: 14),
                const SizedBox(height: 24),
                _buildShimmerBox(height: 120, radius: 14),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({double width = double.infinity, double height = 200, double radius = 16}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  // ============================================================
  // 📱 شاشة الخطأ
  // ============================================================
  Widget _buildErrorScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📊 دوال البناء (مختصرة)
  // ============================================================
  // ... (باقي الدوال كما هي: _buildBannerCarousel, _buildStatsRow, _buildQuickServicesRow,
  // _buildTopDoctorsGrid, _buildProductsRow, _buildFeaturedHospitalsGrid,
  // _buildFeaturedLabsGrid, _buildFeaturedPharmaciesGrid, _buildArticlesGrid,
  // _buildDailyTipsGrid, _buildCommunityPosts, _toggleLike, _sharePost,
  // _showComments, _showTipDetails, _refreshData)

  // ... (جميع الدوال الموجودة سابقاً تبقى كما هي)

  // ============================================================
  // 🔄 تحديث البيانات
  // ============================================================
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      _loadUserData();
      await Future.delayed(const Duration(seconds: 1));
      await _loadHealthScore();
      
      // ✅ حفظ البيانات في الكاش بعد التحديث
      await _saveDataToCache();
      
      if (mounted) {
        setState(() {
          _hasError = false;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      // ✅ إذا فشل التحديث ولكن يوجد كاش
      if (_hasValidCache()) {
        if (mounted) {
          setState(() {
            _hasError = false;
            _isLoading = false;
            _isOffline = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'حدث خطأ في تحديث البيانات';
            _isLoading = false;
            _isOffline = true;
          });
        }
      }
    }
  }
}
