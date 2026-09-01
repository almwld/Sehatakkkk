import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sehatak/core/services/advanced_notification_service.dart';
import 'package:sehatak/core/services/image_cache_service.dart';
import 'package:sehatak/core/services/weather_service.dart';
import 'package:sehatak/core/services/medication_service.dart';
import 'package:sehatak/core/services/appointment_service.dart';
import 'package:sehatak/core/services/ai_recommendation_service.dart';
import 'package:sehatak/core/services/symptom_service.dart';
import 'package:sehatak/core/services/customization_service.dart';
import 'dart:convert';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/health_score_service.dart';
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
import 'package:sehatak/presentation/screens/favorites/favorites_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_screen.dart';
import 'package:sehatak/presentation/screens/video_consultation/video_consultation_screen.dart';
import 'package:sehatak/presentation/screens/packages/packages_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/appointments/appointments_screen.dart';
import 'package:sehatak/presentation/screens/symptom_checker/symptom_checker_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_recommendations_screen.dart';
import 'package:sehatak/presentation/screens/weather_health/weather_health_screen.dart';
import 'package:sehatak/presentation/screens/nearby/nearby_screen.dart';
import 'package:sehatak/core/services/toast_service.dart';

// ============================================================
// 📐 CustomClipper للشريط العلوي المنحني
// ============================================================
class SideCurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
      size.width - 10, size.height,
      size.width - 30, size.height,
    );
    path.lineTo(30, size.height);
    path.quadraticBezierTo(
      10, size.height,
      0, size.height - 20,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ============================================================
// 🎨 CustomPainter للدائرة المتدرجة
// ============================================================
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -90 * (3.14159 / 180);
    final sweepAngle = 360 * (3.14159 / 180) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================
// 🏠 HomeTab - الشاشة الرئيسية المتكاملة بالكامل
// ============================================================
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
  bool _isLoading = false;
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
  bool _dataLoaded = true;
  bool _showScrollTopButton = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, dynamic>> _favorites = [];
  bool _isRetrying = false;
  int _retryCount = 0;

  // 🔔 متغيرات الإشعارات
  int _notificationCount = 0;
  final AdvancedNotificationService _notificationService = AdvancedNotificationService();

  // 📦 بيانات حية باستخدام Stream
  Stream<QuerySnapshot>? _postsStream;
  Stream<QuerySnapshot>? _doctorsStream;
  Stream<QuerySnapshot>? _hospitalsStream;

  // 🔍 الفلاتر المتقدمة
  String _selectedFilter = 'الكل';
  String _searchQuery = '';
  DateTime? _filterDate;
  double _minRating = 0;
  String _locationFilter = '';
  List<String> _recentSearches = [];
  bool _showFilterDialog = false;

  // 💊 تذكير الأدوية
  List<Map<String, dynamic>> _upcomingMedications = [];
  final MedicationService _medicationService = MedicationService();

  // 📅 المواعيد القادمة
  List<Map<String, dynamic>> _upcomingAppointments = [];
  final AppointmentService _appointmentService = AppointmentService();

  // 🤖 توصيات الذكاء الاصطناعي
  Map<String, dynamic>? _aiRecommendation;
  final AIRecommendationService _aiService = AIRecommendationService();

  // 🌤️ الطقس
  Map<String, dynamic>? _weatherData;
  final WeatherService _weatherService = WeatherService();

  // 📍 الموقع والخدمات القريبة

  // 🎨 تخصيص الأقسام
  List<String> _visibleSections = [];
  final CustomizationService _customizationService = CustomizationService();

  // 🩺 الأعراض
  final SymptomService _symptomService = SymptomService();
  List<Map<String, dynamic>> _recentSymptoms = [];

  // 📦 الاشتراكات
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  StreamSubscription<QuerySnapshot>? _postsSubscription;
  StreamSubscription<QuerySnapshot>? _doctorsSubscription;
  StreamSubscription<QuerySnapshot>? _hospitalsSubscription;

  // ============================================================
  // 📦 البيانات الأساسية
  // ============================================================
  List<String> _bannerImages = [];
  List<Map<String, dynamic>> _topDoctors = [];
  List<Map<String, dynamic>> _quickServices = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _featuredHospitals = [];
  List<Map<String, dynamic>> _featuredLabs = [];
  List<Map<String, dynamic>> _featuredPharmacies = [];
  List<Map<String, dynamic>> _healthArticles = [];
  List<Map<String, dynamic>> _dailyTips = [];
  List<Map<String, dynamic>> _communityPosts = [];

  // ============================================================
  // 📦 البيانات الثابتة
  // ============================================================
  final List<String> _defaultBannerImages = ImageKit.bannerList;

  final List<Map<String, dynamic>> _defaultTopDoctors = [
    {'id': 'd1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageKit.doctor1},
    {'id': 'd2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageKit.doctor2},
    {'id': 'd3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageKit.doctor3},
    {'id': 'd4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageKit.doctor4},
    {'id': 'd5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageKit.doctor5},
  ];

  final List<Map<String, dynamic>> _defaultQuickServices = [
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

  final List<Map<String, dynamic>> _defaultProducts = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 20, 'rating': 4.5},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'image': ImageKit.medicine2, 'category': 'فيتامينات', 'discount': 15, 'rating': 4.8},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'image': ImageKit.medicine3, 'category': 'أجهزة طبية', 'discount': 10, 'rating': 4.7},
    {'name': 'أموكسيسيلين 500mg', 'price': 1500, 'image': ImageKit.medicine4, 'category': 'مضادات حيوية', 'discount': 0, 'rating': 4.3},
    {'name': 'ديكلوفيناك 50mg', 'price': 650, 'image': ImageKit.medicine1, 'category': 'مسكنات', 'discount': 5, 'rating': 4.2},
    {'name': 'نابروكسين 250mg', 'price': 550, 'image': ImageKit.medicine2, 'category': 'مضادات التهابية', 'discount': 10, 'rating': 4.4},
    {'name': 'أسبرين 100mg', 'price': 300, 'image': ImageKit.medicine3, 'category': 'مسكنات', 'discount': 0, 'rating': 4.1},
    {'name': 'إيبوبروفين 400mg', 'price': 750, 'image': ImageKit.medicine4, 'category': 'مسكنات', 'discount': 5, 'rating': 4.6},
  ];

  final List<Map<String, dynamic>> _defaultFeaturedHospitals = [
    {'id': 'h1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء - حدة', 'image': ImageKit.hospital1, 'rating': 4.9, 'open': true},
    {'id': 'h2', 'name': 'مستشفى آزال', 'location': 'صنعاء', 'image': ImageKit.hospital2, 'rating': 4.8, 'open': true},
    {'id': 'h3', 'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageKit.hospital3, 'rating': 4.7, 'open': true},
    {'id': 'h4', 'name': 'مستشفى الكويت', 'location': 'صنعاء', 'image': ImageKit.hospital4, 'rating': 4.8, 'open': true},
    {'id': 'h5', 'name': 'المستشفى الجمهوري', 'location': 'صنعاء', 'image': ImageKit.hospital5, 'rating': 4.6, 'open': true},
    {'id': 'h6', 'name': 'مستشفى الثورة العام', 'location': 'صنعاء', 'image': ImageKit.hospital6, 'rating': 4.5, 'open': true},
  ];

  final List<Map<String, dynamic>> _defaultFeaturedLabs = [
    {'id': 'l1', 'name': 'مختبرات الرازي', 'location': 'صنعاء', 'image': ImageKit.lab1, 'rating': 4.9, 'open': true},
    {'id': 'l2', 'name': 'مختبرات العولقي', 'location': 'صنعاء', 'image': ImageKit.lab2, 'rating': 4.8, 'open': true},
    {'id': 'l3', 'name': 'مختبرات المأمون', 'location': 'صنعاء', 'image': ImageKit.lab3, 'rating': 4.7, 'open': true},
    {'id': 'l4', 'name': 'مختبرات الذبحاني', 'location': 'صنعاء', 'image': ImageKit.lab1, 'rating': 4.6, 'open': true},
    {'id': 'l5', 'name': 'مختبرات النخبة', 'location': 'صنعاء', 'image': ImageKit.lab2, 'rating': 4.5, 'open': true},
    {'id': 'l6', 'name': 'مختبرات اليمن الحديثة', 'location': 'صنعاء', 'image': ImageKit.lab3, 'rating': 4.4, 'open': true},
  ];

  final List<Map<String, dynamic>> _defaultFeaturedPharmacies = [
    {'id': 'p1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء', 'image': ImageKit.pharmacy1, 'rating': 4.9, 'open': true},
    {'id': 'p2', 'name': 'صيدلية عالم الصيدلة', 'location': 'صنعاء', 'image': ImageKit.pharmacy2, 'rating': 4.8, 'open': true},
    {'id': 'p3', 'name': 'صيدلية النهضة', 'location': 'صنعاء', 'image': ImageKit.pharmacy3, 'rating': 4.7, 'open': true},
    {'id': 'p4', 'name': 'صيدلية اليمن الحديثة', 'location': 'صنعاء', 'image': ImageKit.pharmacy1, 'rating': 4.6, 'open': true},
    {'id': 'p5', 'name': 'صيدلية الشفاء', 'location': 'صنعاء', 'image': ImageKit.pharmacy2, 'rating': 4.5, 'open': false},
    {'id': 'p6', 'name': 'صيدلية الأمانة', 'location': 'صنعاء', 'image': ImageKit.pharmacy3, 'rating': 4.4, 'open': true},
  ];

  final List<Map<String, dynamic>> _defaultHealthArticles = [
    {'title': 'فوائد المشي اليومي', 'category': 'صحة عامة', 'time': 'منذ ساعة', 'image': ImageKit.morningWalk},
    {'title': 'نصائح لتقوية المناعة', 'category': 'تغذية', 'time': 'منذ 3 ساعات', 'image': ImageKit.immuneBoost},
    {'title': 'أهمية النوم الصحي', 'category': 'صحة نفسية', 'time': 'منذ 5 ساعات', 'image': ImageKit.sleepTips},
    {'title': 'العناية بالبشرة في الصيف', 'category': 'جلدية', 'time': 'منذ يوم', 'image': ImageKit.skinCare},
  ];

  final List<Map<String, dynamic>> _defaultDailyTips = [
    {'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': 'assets/images/tracking/water_drinking.png', 'content': 'شرب 8 أكواب من الماء يومياً يحسن صحة البشرة ويساعد في التخلص من السموم.'},
    {'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': 'assets/images/tracking/walking.png', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.'},
    {'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': 'assets/images/tracking/sleep_tracking.png', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.'},
    {'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': 'assets/images/tracking/fruits.png', 'content': 'تناول 5 حصص من الفواكه والخضار يومياً يوفر الفيتامينات.'},
  ];

  List<Map<String, dynamic>> _defaultCommunityPosts = [
    {'id': '1', 'author': 'د. سارة العمري', 'avatar': 'س', 'image': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'views': 450, 'time': 'منذ ساعة', 'liked': false, 'saved': false, 'reported': false, 'commentList': []},
    {'id': '2', 'author': 'د. خالد النخلاني', 'avatar': 'خ', 'image': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 95, 'comments': 8, 'shares': 5, 'views': 320, 'time': 'منذ 3 ساعات', 'liked': false, 'saved': false, 'reported': false, 'commentList': []},
    {'id': '3', 'author': 'د. أحمد المؤيد', 'avatar': 'أ', 'image': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.', 'likes': 210, 'comments': 22, 'shares': 12, 'views': 680, 'time': 'منذ 5 ساعات', 'liked': true, 'saved': true, 'reported': false, 'commentList': []},
    {'id': '4', 'author': 'د. أسماء الهندي', 'avatar': 'ه', 'image': ImageKit.immuneBoost, 'title': 'قوة المناعة', 'content': 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.', 'likes': 78, 'comments': 5, 'shares': 3, 'views': 210, 'time': 'منذ يوم', 'liked': false, 'saved': false, 'reported': false, 'commentList': []},
    {'id': '5', 'author': 'د. محمد العلاي', 'avatar': 'م', 'image': ImageKit.sleepTips, 'title': 'نصائح النوم الصحي', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.', 'likes': 150, 'comments': 12, 'shares': 7, 'views': 540, 'time': 'منذ يومين', 'liked': false, 'saved': false, 'reported': false, 'commentList': []},
  ];

  // ✅ تخزين الاشتراكات للتخلص منها لاحقاً

  // ============================================================
  // 🎯 رسالة ترحيب ديناميكية
  // ============================================================
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 17) return 'مساء الخير 🌤️';
    return 'مساء الخير 🌙';
  }

  // ============================================================
  // 🔄 دورة الحياة - تهيئة جميع الخدمات
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadDefaultData();
    _initializeServices();
    _loadUserPreferences();
    _setupStreams();
    _loadNotificationCount();
    _loadUpcomingMedications();
    _loadUpcomingAppointments();
    _loadAIRecommendation();
    _loadWeather();
    _loadRecentSearches();
    _loadRecentSymptoms();
    _loadDataInBackground();
    
    // ✅ التحقق من mounted قبل إضافة المستمع
    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_onScroll);
    }

    // ✅ تخزين الاشتراك
    _fcmSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;
      setState(() {
        _notificationCount++;
      });
      ToastService.showSuccess('📩 ${message.notification?.title ?? 'إشعار جديد'}');
    });
  }

  @override
  void dispose() {
    // ✅ إزالة جميع الاشتراكات
    _fcmSubscription?.cancel();
    _postsSubscription?.cancel();
    _doctorsSubscription?.cancel();
    _hospitalsSubscription?.cancel();
    
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_onScroll);
    }
    
    // ✅ التخلص من جميع الخدمات
    
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final maxScroll = widget.scrollController?.position.maxScrollExtent ?? 0;
    final currentScroll = widget.scrollController?.position.pixels ?? 0;
    setState(() {
      _appBarOpacity = 1.0 - (currentScroll / maxScroll).clamp(0.0, 0.5);
      _showScrollTopButton = currentScroll > 200;
    });
  }

  // ============================================================
  // 🔧 تهيئة الخدمات
  // ============================================================
  Future<void> _initializeServices() async {
    try {
      await _notificationService.initialize();
      await _weatherService.init();
      await _medicationService.init();
      await _appointmentService.init();
      await _aiService.init();
      await _customizationService.init();
      await _symptomService.init();
    } catch (e) {
      print('⚠️ فشل تهيئة الخدمات: $e');
    }
  }

  // ============================================================
  // 📦 تحميل البيانات الافتراضية فوراً
  // ============================================================
  void _loadDefaultData() {
    setState(() {
      _bannerImages = _defaultBannerImages;
      _topDoctors = List.from(_defaultTopDoctors);
      _quickServices = List.from(_defaultQuickServices);
      _products = List.from(_defaultProducts);
      _featuredHospitals = List.from(_defaultFeaturedHospitals);
      _featuredLabs = List.from(_defaultFeaturedLabs);
      _featuredPharmacies = List.from(_defaultFeaturedPharmacies);
      _healthArticles = List.from(_defaultHealthArticles);
      _dailyTips = List.from(_defaultDailyTips);
      _communityPosts = List.from(_defaultCommunityPosts);
      _dataLoaded = true;
      _isLoading = false;
    });
  }

  // ============================================================
  // 🔥 تحميل Firebase في الخلفية
  // ============================================================
  Future<void> _loadDataInBackground() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            _userName = data?['name'] ?? user.displayName ?? 'مستخدم';
            _isLoggedIn = true;
          });
        }
      }
    } catch (e) {
      print('⚠️ فشل تحميل Firebase (خلفي): $e');
    }
  }

  // ============================================================
  // 💾 حفظ وإعجابات المستخدم من Firestore
  // ============================================================
  Future<void> _loadUserSavedPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final savedDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_posts')
          .get();
      final savedIds = savedDocs.docs.map((doc) => doc.id).toSet();
      if (!mounted) return;
      setState(() {
        for (var post in _communityPosts) {
          post['saved'] = savedIds.contains(post['id'].toString());
        }
      });
    } catch (e) { print('⚠️ فشل تحميل المنشورات المحفوظة: $e'); }
  }

  Future<void> _loadUserLikedPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final likedDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('liked_posts')
          .get();
      final likedIds = likedDocs.docs.map((doc) => doc.id).toSet();
      if (!mounted) return;
      setState(() {
        for (var post in _communityPosts) {
          post['liked'] = likedIds.contains(post['id'].toString());
        }
      });
    } catch (e) { print('⚠️ فشل تحميل الإعجابات: $e'); }
  }

  // ============================================================
  // ⭐ المفضلة
  // ============================================================
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    if (!mounted) return;
    setState(() {
      _favorites = favoritesJson.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  // ============================================================
  // 🔔 الإشعارات
  // ============================================================
  Future<void> _loadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (!mounted) return;
      setState(() => _notificationCount = count);
    } catch (e) { print('⚠️ فشل تحميل عدد الإشعارات: $e'); }
  }

  // ============================================================
  // 💊 الأدوية
  // ============================================================
  Future<void> _loadUpcomingMedications() async {
    try {
      final meds = await _medicationService.getUpcomingMedications();
      if (!mounted) return;
      setState(() => _upcomingMedications = meds);
    } catch (e) { print('⚠️ فشل تحميل تذكير الأدوية: $e'); }
  }

  // ============================================================
  // 📅 المواعيد
  // ============================================================
  Future<void> _loadUpcomingAppointments() async {
    try {
      final apps = await _appointmentService.getUpcomingAppointments();
      if (!mounted) return;
      setState(() => _upcomingAppointments = apps);
    } catch (e) { print('⚠️ فشل تحميل المواعيد: $e'); }
  }

  // ============================================================
  // 🤖 توصيات الذكاء الاصطناعي
  // ============================================================
  Future<void> _loadAIRecommendation() async {
    try {
      final rec = await _aiService.getRecommendation();
      if (!mounted) return;
      setState(() => _aiRecommendation = rec);
    } catch (e) { print('⚠️ فشل تحميل التوصيات: $e'); }
  }

  // ============================================================
  // 🌤️ الطقس
  // ============================================================
  Future<void> _loadWeather() async {
    try {
      final weather = await _weatherService.getCurrentWeather();
      if (!mounted) return;
      setState(() => _weatherData = weather);
    } catch (e) { print('⚠️ فشل تحميل الطقس: $e'); }
  }

  // ============================================================
  // 📍 الخدمات القريبة
  // ============================================================

  // ============================================================
  // 🎨 تفضيلات المستخدم
  // ============================================================
  Future<void> _loadUserPreferences() async {
    try {
      final sections = await _customizationService.getVisibleSections();
      if (!mounted) return;
      setState(() => _visibleSections = sections);
    } catch (e) { print('⚠️ فشل تحميل التخصيص: $e'); }
  }

  // ============================================================
  // 🔍 عمليات البحث الأخيرة
  // ============================================================
  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_searches') ?? [];
      if (!mounted) return;
      setState(() => _recentSearches = searches);
    } catch (e) { print('⚠️ فشل تحميل عمليات البحث: $e'); }
  }

  Future<void> _saveRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = _recentSearches;
      searches.remove(query);
      searches.insert(0, query);
      if (searches.length > 10) searches.removeLast();
      await prefs.setStringList('recent_searches', searches);
      if (!mounted) return;
      setState(() => _recentSearches = searches);
    } catch (e) { print('⚠️ فشل حفظ البحث: $e'); }
  }

  // ============================================================
  // 🩺 الأعراض الأخيرة
  // ============================================================
  Future<void> _loadRecentSymptoms() async {
    try {
      final symptoms = await _symptomService.getRecentSymptoms();
      if (!mounted) return;
      setState(() => _recentSymptoms = symptoms);
    } catch (e) { print('⚠️ فشل تحميل الأعراض: $e'); }
  }

  // ============================================================
  // 📡 Streams للبيانات الحية
  // ============================================================
  void _setupStreams() {
    _postsSubscription = FirebaseFirestore.instance
        .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
        });
    
    _doctorsSubscription = FirebaseFirestore.instance
        .collection('doctors')
        .limit(10)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
        });
    
    _hospitalsSubscription = FirebaseFirestore.instance
        .collection('hospitals')
        .limit(6)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
        });
  }

  // ============================================================
  // 👤 بيانات المستخدم
  // ============================================================
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

  // ============================================================
  // 🏥 Health Score
  // ============================================================
  Future<void> _loadHealthScore() async {
    try {
      final score = await HealthScoreService.calculateHealthScore();
      if (mounted) { setState(() => _healthScore = score); }
    } catch (e) {
      if (mounted) { setState(() => _healthScore = 0.0); }
    }
  }

  // ============================================================
  // 🔄 تحديث البيانات وإعادة المحاولة
  // ============================================================
  Future<void> _refreshData() async {
    setState(() => _isRetrying = true);
    try {
      _loadDefaultData();
      await _loadNotificationCount();
      await _loadUpcomingMedications();
      await _loadUpcomingAppointments();
      await _loadAIRecommendation();
      await _loadWeather();
      await _loadRecentSearches();
      await _loadRecentSymptoms();
      if (!mounted) return;
      setState(() { _hasError = false; _retryCount = 0; });
      ToastService.showSuccess('✅ تم تحديث البيانات بنجاح');
    } catch (e) {
      if (!mounted) return;
      setState(() { 
        _hasError = true; 
        _errorMessage = 'حدث خطأ في تحميل البيانات';
        _retryCount++;
      });
      ToastService.showError('❌ فشل تحديث البيانات');
    } finally {
      if (!mounted) return;
      setState(() => _isRetrying = false);
    }
  }

  void _onRetry() {
    if (_isRetrying) return;
    setState(() => _isLoading = true);
    _refreshData().whenComplete(() {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  // ============================================================
  // 🧭 دوال التنقل
  // ============================================================
  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _goToWithHero(BuildContext context, Widget screen, Object tag) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  // ============================================================
  // ❤️ دوال التفاعل الكاملة
  // ============================================================
  
  void _sharePost(int index) {
    final post = _communityPosts[index];
    Share.share(
      '📢 ${post['title']}\n\n${post['content']}\n\n📸 ${post['image']}\n\n👁️ ${post['views']} مشاهدة\n❤️ ${post['likes']} إعجاب\n💬 ${post['comments']} تعليق\n\n---\nمنشور من تطبيق صحتك - Sehatak',
      subject: post['title'],
    );
    _updateSharesCount(post['id'].toString());
  }

  Future<void> _updateSharesCount(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .update({ 'shares': FieldValue.increment(1) });
    } catch (e) { print('⚠️ فشل تحديث عدد المشاركات: $e'); }
  }

  Future<void> _toggleLike(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
      return;
    }
    final postId = _communityPosts[index]['id'].toString();
    final isLiked = _communityPosts[index]['liked'] ?? false;
    try {
      if (isLiked) {
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(postId)
            .update({ 'likes': FieldValue.increment(-1) });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('liked_posts')
            .doc(postId)
            .delete();
        if (!mounted) return;
        setState(() {
          _communityPosts[index]['liked'] = false;
          _communityPosts[index]['likes']--;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(postId)
            .update({ 'likes': FieldValue.increment(1) });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('liked_posts')
            .doc(postId)
            .set({
          'postId': postId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        setState(() {
          _communityPosts[index]['liked'] = true;
          _communityPosts[index]['likes']++;
        });
      }
    } catch (e) { ToastService.showError('❌ فشل تحديث الإعجاب'); }
  }

  Future<void> _savePost(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
      return;
    }
    final postId = _communityPosts[index]['id'].toString();
    final isSaved = _communityPosts[index]['saved'] ?? false;
    try {
      if (isSaved) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_posts')
            .doc(postId)
            .delete();
        if (!mounted) return;
        setState(() { _communityPosts[index]['saved'] = false; });
        ToastService.showSuccess('❌ تم إلغاء حفظ المنشور');
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_posts')
            .doc(postId)
            .set({
          'postId': postId,
          'title': _communityPosts[index]['title'],
          'image': _communityPosts[index]['image'],
          'savedAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        setState(() { _communityPosts[index]['saved'] = true; });
        ToastService.showSuccess('✅ تم حفظ المنشور');
      }
    } catch (e) { ToastService.showError('❌ فشل حفظ المنشور'); }
  }

  Future<void> _reportPost(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
      return;
    }
    final postId = _communityPosts[index]['id'].toString();
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .add({
        'postId': postId,
        'reportedBy': user.uid,
        'reason': 'محتوى غير مناسب',
        'reportedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() { _communityPosts[index]['reported'] = true; });
      ToastService.showSuccess('✅ تم الإبلاغ عن المنشور');
    } catch (e) { ToastService.showError('❌ فشل الإبلاغ'); }
  }

  void _showComments(Map<String, dynamic> post, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCommentsSheet(post, index),
    );
  }

  Widget _buildCommentsSheet(Map<String, dynamic> post, int index) {
    final TextEditingController _commentController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    final FocusNode _focusNode = FocusNode();

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'التعليقات (${post['comments']})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community_posts')
                  .doc(post['id'].toString())
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data?.docs ?? [];
                if (comments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('لا توجد تعليقات، كن أول من يعلق!'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, i) {
                    final data = comments[i].data() as Map<String, dynamic>;
                    return _buildCommentTile(data, post['id'].toString(), index);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (user != null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقاً... (استخدم @ لمنشن و # للوسم)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tag, size: 18, color: Colors.grey),
                        onPressed: () {
                          ToastService.showSuccess('اكتب # لبدء الوسم');
                        },
                      ),
                    ),
                    textDirection: TextDirection.rtl,
                    onChanged: (value) {
                      if (value.endsWith('@')) {
                        ToastService.showSuccess('اقتراحات المستخدمين...');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      final comment = _commentController.text.trim();
                      if (comment.isNotEmpty) {
                        _addComment(index, comment);
                        _commentController.clear();
                        _focusNode.unfocus();
                      }
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> data, String postId, int postIndex) {
    final bool hasReplies = data['replies'] != null && (data['replies'] as List).isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              (data['userName'] ?? 'م')[0],
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              ToastService.showSuccess('@${data['userName']}');
            },
            child: Text(data['userName'] ?? 'مستخدم'),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['comment'] ?? ''),
              if (data['comment'] != null && data['comment'].contains('#'))
                Wrap(
                  children: (data['comment'] as String)
                      .split(' ')
                      .where((word) => word.startsWith('#'))
                      .map((tag) => GestureDetector(
                            onTap: () {
                              ToastService.showSuccess('البحث عن الوسم: $tag');
                            },
                            child: Text(
                              tag,
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.reply, size: 16),
                onPressed: () {
                  ToastService.showSuccess('رد على التعليق قيد التطوير');
                },
              ),
              IconButton(
                icon: const Icon(Icons.flag, size: 16, color: Colors.grey),
                onPressed: () {
                  ToastService.showSuccess('تم الإبلاغ عن التعليق');
                },
              ),
              Text(
                _formatTime((data['timestamp'] as Timestamp?)?.toDate()),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        if (hasReplies)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              children: (data['replies'] as List).map((reply) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      (reply['userName'] ?? 'م')[0],
                      style: TextStyle(color: AppColors.primary, fontSize: 10),
                    ),
                  ),
                  title: Text(reply['userName'] ?? 'مستخدم', style: const TextStyle(fontSize: 12)),
                  subtitle: Text(reply['comment'] ?? '', style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _addComment(int index, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
      return;
    }
    final postId = _communityPosts[index]['id'].toString();
    try {
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'userId': user.uid,
        'userName': user.displayName ?? 'مستخدم',
        'userAvatar': user.photoURL ?? '',
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'replies': [],
        'mentions': _extractMentions(comment),
        'hashtags': _extractHashtags(comment),
      });
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .update({ 'comments': FieldValue.increment(1) });
      if (!mounted) return;
      setState(() { _communityPosts[index]['comments']++; });
      ToastService.showSuccess('✅ تم إضافة التعليق');
      
      final mentions = _extractMentions(comment);
      for (var mentionedUser in mentions) {
        await _notificationService.sendMentionNotification(mentionedUser, user.displayName ?? 'مستخدم');
      }
    } catch (e) { ToastService.showError('❌ فشل إضافة التعليق'); }
  }

  List<String> _extractMentions(String text) {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(1)!).toList();
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'الآن';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
  }

  // ============================================================
  // 🏗️ بناء الواجهة الرئيسية
  // ============================================================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && !_dataLoaded) {
      return _buildShimmerLoader(isDark);
    }

    if (_hasError && !_dataLoaded) {
      return _buildErrorScreen(isDark);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshData,
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
            body: CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildCurvedAppBar(isDark)),
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
                      _buildNotificationWidget(),
                      const SizedBox(height: 16),
                      if (_upcomingMedications.isNotEmpty)
                        _buildMedicationReminder(),
                      if (_upcomingAppointments.isNotEmpty)
                        _buildAppointmentsSummary(),
                      if (_weatherData != null)
                        _buildWeatherWidget(),
                      if (_aiRecommendation != null)
                        _buildAIRecommendation(),
                      if (_recentSymptoms.isNotEmpty)
                        _buildRecentSymptoms(),
                      if (_recentSearches.isNotEmpty)
                        _buildRecentSearchesWidget(),
                      _buildSectionWithCustomization(
                        title: 'خدمات سريعة',
                        isDark: isDark,
                        sectionKey: 'quick_services',
                        child: _buildQuickServicesRow(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'أفضل الأطباء',
                        isDark: isDark,
                        sectionKey: 'top_doctors',
                        child: _buildTopDoctorsGrid(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'المفضلة ⭐',
                        isDark: isDark,
                        sectionKey: 'favorites',
                        child: _buildFavoritesRow(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'منتجات صيدلية',
                        isDark: isDark,
                        sectionKey: 'products',
                        child: _buildProductsRow(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'مستشفيات مميزة',
                        isDark: isDark,
                        sectionKey: 'hospitals',
                        child: _buildFeaturedHospitalsGrid(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'مختبرات مميزة',
                        isDark: isDark,
                        sectionKey: 'labs',
                        child: _buildFeaturedLabsGrid(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'صيدليات مميزة',
                        isDark: isDark,
                        sectionKey: 'pharmacies',
                        child: _buildFeaturedPharmaciesGrid(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'أحدث المقالات',
                        isDark: isDark,
                        sectionKey: 'articles',
                        child: _buildArticlesGrid(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'نصائح يومية',
                        isDark: isDark,
                        sectionKey: 'daily_tips',
                        child: _buildDailyTipsGrid(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'اكتشف المزيد',
                        isDark: isDark,
                        sectionKey: 'discover',
                        child: _buildDiscoverGrid(isDark),
                      ),
                      _buildSectionWithCustomization(
                        title: 'مجتمع صحتك',
                        isDark: isDark,
                        sectionKey: 'community',
                        child: _buildCommunityPosts(isDark),
                      ),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showScrollTopButton)
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                widget.scrollController?.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        if (_isLoggedIn)
          Positioned(
            bottom: 140,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () => _goTo(context, const SymptomCheckerScreen()),
              backgroundColor: Colors.purple,
              child: const Icon(Icons.health_and_safety, color: Colors.white),
            ),
          ),
        if (_hasError && _dataLoaded)
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: _onRetry,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isRetrying)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(Icons.refresh, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          _isRetrying ? 'جاري إعادة المحاولة...' : 'إعادة المحاولة',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // 🧩 ويدجت شاشة الخطأ
  // ============================================================
  Widget _buildErrorScreen(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🧩 ويدجت التخصيص
  // ============================================================
  Widget _buildSectionWithCustomization({
    required String title,
    required bool isDark,
    required String sectionKey,
    required Widget child,
  }) {
    if (!_visibleSections.contains(sectionKey) && _visibleSections.isNotEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitleWithAction(title, isDark, 'عرض الكل', () {
          ToastService.showSuccess('انتقال إلى $title');
        }),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // 🧩 ويدجت الإشعارات
  // ============================================================
  Widget _buildNotificationWidget() {
    if (_notificationCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _goTo(context, const NotificationsScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إشعارات جديدة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'لديك $_notificationCount إشعاراً جديداً',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_notificationCount',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 💊 تذكير الأدوية
  // ============================================================
  Widget _buildMedicationReminder() {
    return GestureDetector(
      onTap: () => _goTo(context, const MedicationReminderScreen()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💊 تذكير الأدوية',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'لديك ${_upcomingMedications.length} دواء قادم',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📅 المواعيد القادمة
  // ============================================================
  Widget _buildAppointmentsSummary() {
    return GestureDetector(
      onTap: () => _goTo(context, const AppointmentsScreen()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📅 مواعيدك القادمة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_upcomingAppointments.length} موعد قادم',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🌤️ الطقس
  // ============================================================
  Widget _buildWeatherWidget() {
    return GestureDetector(
      onTap: () => _goTo(context, const WeatherHealthScreen()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan.withOpacity(0.1), Colors.cyan.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyan.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _weatherData?['icon'] == 'sunny' ? Icons.wb_sunny : Icons.cloud,
                color: Colors.cyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌤️ ${_weatherData?['temp'] ?? '--'}°C',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _weatherData?['condition'] ?? 'غير معروف',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (_weatherData?['healthTip'] != null)
                    Text(
                      '💡 ${_weatherData?['healthTip']}',
                      style: const TextStyle(fontSize: 10, color: Colors.cyan),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.cyan),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📍 الخدمات القريبة
  // ============================================================

  // ============================================================
  // 🤖 توصيات الذكاء الاصطناعي
  // ============================================================
  Widget _buildAIRecommendation() {
    return GestureDetector(
      onTap: () => _goTo(context, const AIRecommendationsScreen()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🤖 توصيات مخصصة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _aiRecommendation?['title'] ?? 'اكتشف توصيات صحية لك',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🩺 الأعراض الأخيرة
  // ============================================================
  Widget _buildRecentSymptoms() {
    return GestureDetector(
      onTap: () => _goTo(context, const SymptomCheckerScreen()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.withOpacity(0.1), Colors.pink.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.pink.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.healing, color: Colors.pink, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🩺 الأعراض الأخيرة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'سجلت ${_recentSymptoms.length} عرضاً',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.pink),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📊 عمليات البحث الأخيرة
  // ============================================================
  Widget _buildRecentSearchesWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔍 عمليات البحث الأخيرة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return GestureDetector(
                onTap: () {
                  _saveRecentSearch(search);
                  ToastService.showSuccess('البحث عن: $search');
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        search,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // 📊 دوال البناء الأساسية
  // ============================================================

  Widget _buildShimmerLoader(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: [
          Container(height: 160, margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 8),
          Container(height: 50, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30))),
          const SizedBox(height: 16),
          Container(height: 140, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          const SizedBox(height: 16),
          SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 6, itemBuilder: (_, __) => Container(width: 70, margin: const EdgeInsets.symmetric(horizontal: 4), child: Column(children: [Container(width: 40, height: 40, color: Colors.white), const SizedBox(height: 6), Container(width: 40, height: 10, color: Colors.white)])))),
          const SizedBox(height: 16),
          SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 4, itemBuilder: (_, __) => Container(width: 150, margin: const EdgeInsets.only(right: 10), color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildCurvedAppBar(bool isDark) {
    return Opacity(
      opacity: _appBarOpacity,
      child: ClipPath(
        clipper: SideCurvedClipper(),
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'user_avatar',
                        child: GestureDetector(
                          onTap: () => _goTo(context, const PatientProfile()),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              _isLoggedIn ? _userName[0].toUpperCase() : 'م',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                              _isLoggedIn ? '${_getGreeting()}، $_userName 👋🏻' : 'مرحباً بك في صحتك',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _isLoggedIn ? 'كيف تشعر اليوم؟' : 'سجل دخولك للاستفادة',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                            ),
                            if (_isOffline)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                                child: const Text('📶 غير متصل', style: TextStyle(fontSize: 9, color: Colors.orange)),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _goTo(context, const NotificationsScreen()),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                'assets/images/icons/top_bar/notifications.png',
                                width: 26,
                                height: 26,
                                color: Colors.white,
                                errorBuilder: (_, __, ___) => Icon(Icons.notifications, color: Colors.white, size: 26),
                              ),
                            ),
                            if (_notificationCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    '$_notificationCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
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
                            errorBuilder: (_, __, ___) => Icon(Icons.shopping_cart, color: Colors.white, size: 26),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => showSearch(context: context, delegate: AppSearchDelegate()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/icons/search/Search_button.png',
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => Icon(Icons.search, color: Colors.white.withOpacity(0.7), size: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ابحث عن طبيب، دواء، أو خدمة...',
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                              ),
                            ),
                            Image.asset(
                              'assets/images/chat/microphone.png',
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => Icon(Icons.mic, color: Colors.white.withOpacity(0.7), size: 20),
                            ),
                          ],
                        ),
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

  Widget _buildBannerCarousel(bool isDark) {
    if (_bannerImages.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.grey[200], borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('لا توجد بانرات')),
      );
    }

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
            viewportFraction: 0.92,
            onPageChanged: (index, reason) => setState(() => _currentBanner = index),
          ),
          items: _bannerImages.map((url) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(
                  imageUrl: url,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 8,
          left: 16,
          child: Row(
            children: _bannerImages.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = _currentBanner == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 20 : 8,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
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
      {'icon': Icons.local_fire_department, 'value': _caloriesAnim, 'label': 'سعرة', 'color': Colors.orange, 'maxValue': 3000, 'format': 'int'},
      {'icon': Icons.directions_walk, 'value': _stepsAnim, 'label': 'خطوة', 'color': Colors.green, 'maxValue': 10000, 'format': 'int'},
      {'icon': Icons.bedtime, 'value': _sleepAnim, 'label': 'نوم', 'color': Colors.purple, 'maxValue': 8, 'format': 'double'},
      {'icon': Icons.favorite, 'value': _heartAnim, 'label': 'نبض', 'color': Colors.red, 'maxValue': 100, 'format': 'int'},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: statsData.map((stat) {
        final color = stat['color'] as Color;
        final value = stat['value'] as double;
        final maxValue = stat['maxValue'] as double;
        final isInt = stat['format'] == 'int';
        final percentage = (value / maxValue).clamp(0.0, 1.0);

        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: percentage),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            painter: CircularProgressPainter(
                              progress: progress,
                              backgroundColor: color.withOpacity(0.15),
                              progressColor: color,
                              strokeWidth: 5,
                            ),
                            child: const SizedBox(width: 60, height: 60),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(stat['icon'] as IconData, color: color, size: 18),
                              const SizedBox(height: 2),
                              Text(
                                isInt ? (value * progress).toInt().toString() : (value * progress).toStringAsFixed(1),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label'] as String,
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildSectionTitleWithAction(String title, bool isDark, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          TextButton(
            onPressed: onTap,
            child: Text(action, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServicesRow(bool isDark) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          return GestureDetector(
            onTap: () => _goTo(context, service['screen'] as Widget),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    service['icon'] as String,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => Icon(Icons.image, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 40),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service['label'] as String,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[400] : Colors.grey[800]),
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

  Widget _buildTopDoctorsGrid(bool isDark) {
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Hero(
                        tag: 'doctor_image_${doctor['id']}',
                        child: AppImage(
                          imageUrl: doctor['image'] as String,
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(doctor['rating'].toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                      Text(doctor['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(doctor['specialty'] as String, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                          child: const Text('حجز موعد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildFavoritesRow(bool isDark) {
    if (_favorites.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('لا توجد مفضلات حالياً', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final item = _favorites[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage(imageUrl: item['image'] ?? '', height: 70, width: 100, fit: BoxFit.cover),
                ),
                Text(
                  item['name'] ?? '',
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsRow(bool isDark) {
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppImage(imageUrl: product['image'] as String, height: 80, width: 80, fit: BoxFit.contain),
                      ),
                      if (hasDiscount)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                            child: Text('-${product['discount']}%', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(product['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(product['category'] as String, style: const TextStyle(fontSize: 9, color: AppColors.primary)),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasDiscount) ...[
                        Text('${product['price']} ر.ي', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[400], decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 4),
                      ],
                      Text('${priceAfterDiscount.toInt()} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
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

  Widget _buildFeaturedHospitalsGrid(bool isDark) {
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
          onTap: () => _goTo(context, HospitalDetailsScreen(hospitalId: hospital['id'] as String, hospitalData: hospital)),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: Hero(
                        tag: 'hospital_${hospital['id']}',
                        child: AppImage(imageUrl: hospital['image'] as String, height: 90, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(hospital['rating'].toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                          color: hospital['open'] == true ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(hospital['open'] == true ? 'مفتوح' : 'مغلق', style: const TextStyle(color: Colors.white, fontSize: 8)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospital['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(hospital['location'] as String, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goTo(context, HospitalDetailsScreen(hospitalId: hospital['id'] as String, hospitalData: hospital)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text('تفاصيل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildFeaturedLabsGrid(bool isDark) {
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
          onTap: () => _goTo(context, const LabsListScreen()),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AppImage(imageUrl: lab['image'] as String, height: 90, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lab['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(lab['location'] as String, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goTo(context, const LabsListScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text('حجز', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildFeaturedPharmaciesGrid(bool isDark) {
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
          onTap: () => _goTo(context, const PharmacyScreen()),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AppImage(imageUrl: pharmacy['image'] as String, height: 90, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pharmacy['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(pharmacy['location'] as String, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _goTo(context, const PharmacyScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            minimumSize: const Size(0, 28),
                          ),
                          child: const Text('طلب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildArticlesGrid(bool isDark) {
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AppImage(imageUrl: article['image'] as String, height: 80, width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(article['category'] as String, style: TextStyle(fontSize: 8, color: AppColors.primary)),
                      ),
                      const SizedBox(height: 4),
                      Text(article['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isDark ? Colors.white : Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(article['time'] as String, style: TextStyle(fontSize: 8, color: isDark ? Colors.grey[400] : Colors.grey[600])),
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

  Widget _buildDailyTipsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
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
                Image.asset(
                  tip['icon'] as String,
                  width: 48,
                  height: 48,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 40),
                ),
                const SizedBox(height: 8),
                Text(tip['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary), textAlign: TextAlign.center),
                Text(tip['subtitle'] as String, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('اقرأ المزيد', style: TextStyle(fontSize: 9, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscoverGrid(bool isDark) {
    final items = [
      {'icon': 'assets/images/services/medical_articles.png', 'label': 'مقالات طبية', 'screen': const ArticlesScreen()},
      {'icon': 'assets/images/services/health_insurance.png', 'label': 'تأمين صحي', 'screen': const InsuranceScreen()},
      {'icon': 'assets/images/services/video_consultation.png', 'label': 'استشارة فيديو', 'screen': const VideoConsultationScreen()},
      {'icon': 'assets/images/services/packages.png', 'label': 'باقات صحية', 'screen': const PackagesScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _goTo(context, item['screen'] as Widget),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(item['icon'] as String, width: 32, height: 32),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white : Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityPosts(bool isDark) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _communityPosts.length,
      itemBuilder: (context, index, animation) {
        final post = _communityPosts[index];
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(post['avatar'] as String, style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post['author'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                          Row(
                            children: [
                              Text(post['time'] as String, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                child: Text('👁️ ${post['views']}', style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_horiz, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(post['saved'] == true ? Icons.bookmark : Icons.bookmark_border, color: AppColors.primary, size: 16),
                              const SizedBox(width: 8),
                              Text(post['saved'] == true ? 'إلغاء الحفظ' : 'حفظ'),
                            ],
                          ),
                          onTap: () => _savePost(index),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.flag, color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Text(post['reported'] == true ? 'تم الإبلاغ' : 'إبلاغ'),
                            ],
                          ),
                          onTap: () => _reportPost(index),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(post['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 4),
                Text(post['content'] as String, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700])),
                const SizedBox(height: 8),
                if (post['image'] != null)
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: AppImage(imageUrl: post['image'] as String, width: double.infinity, height: 300, fit: BoxFit.contain),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AppImage(imageUrl: post['image'] as String, height: 200, width: double.infinity, fit: BoxFit.contain),
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
                          Text('${post['likes']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
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
                          Text('${post['comments']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
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
                          Text('${post['shares']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _savePost(index),
                      child: Icon(
                        post['saved'] == true ? Icons.bookmark : Icons.bookmark_border,
                        color: post['saved'] == true ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
              Image.asset(tip['icon'] as String, width: 48, height: 48, errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.grey[600], size: 40)),
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
}
