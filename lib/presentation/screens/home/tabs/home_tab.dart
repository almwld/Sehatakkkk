import 'package:sehatak/core/models/doctor_model.dart';
import '../../../bloc/doctor_bloc/doctor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
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
    path.quadraticBezierTo(size.width - 10, size.height, size.width - 30, size.height);
    path.lineTo(30, size.height);
    path.quadraticBezierTo(10, size.height, 0, size.height - 20);
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
// 🏠 HomeTab - الشاشة الرئيسية الكاملة
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
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _dataLoaded = false;
  String _userName = 'مستخدم';
  int _currentBanner = 0;
  double _appBarOpacity = 1.0;
  bool _showScrollTopButton = false;
  bool _isRefreshing = false;
  int _notificationCount = 0;
  String _selectedFilter = 'الكل';
  String _searchQuery = '';

  // ============================================================
  // 📦 البيانات الأساسية (العرض الافتراضي + Firebase)
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
  // 📦 البيانات الثابتة (الافتراضية)
  // ============================================================
  final List<String> _defaultBannerImages = [
    'assets/images/services/consultation.png',
    'assets/images/services/emergency.png',
    'assets/images/services/hospital.png',
    'assets/images/services/pharmacy.png',
    'assets/images/services/blood_donation.png',
  ];

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

  final List<Map<String, dynamic>> _defaultCommunityPosts = [
    {'id': '1', 'author': 'د. سارة العمري', 'avatar': 'س', 'image': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'views': 450, 'time': 'منذ ساعة', 'liked': false, 'saved': false, 'reported': false},
    {'id': '2', 'author': 'د. خالد النخلاني', 'avatar': 'خ', 'image': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 95, 'comments': 8, 'shares': 5, 'views': 320, 'time': 'منذ 3 ساعات', 'liked': false, 'saved': false, 'reported': false},
    {'id': '3', 'author': 'د. أحمد المؤيد', 'avatar': 'أ', 'image': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.', 'likes': 210, 'comments': 22, 'shares': 12, 'views': 680, 'time': 'منذ 5 ساعات', 'liked': true, 'saved': true, 'reported': false},
    {'id': '4', 'author': 'د. أسماء الهندي', 'avatar': 'ه', 'image': ImageKit.immuneBoost, 'title': 'قوة المناعة', 'content': 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.', 'likes': 78, 'comments': 5, 'shares': 3, 'views': 210, 'time': 'منذ يوم', 'liked': false, 'saved': false, 'reported': false},
    {'id': '5', 'author': 'د. محمد العلاي', 'avatar': 'م', 'image': ImageKit.sleepTips, 'title': 'نصائح النوم الصحي', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.', 'likes': 150, 'comments': 12, 'shares': 7, 'views': 540, 'time': 'منذ يومين', 'liked': false, 'saved': false, 'reported': false},
  ];

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
  // 🔄 دورة الحياة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadDefaultData();
    _loadUserData();
    _fetchDataFromFirebase();
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
      _showScrollTopButton = currentScroll > 200;
    });
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
  // 📦 جلب البيانات من Firebase في الخلفية
  // ============================================================
  Future<void> _fetchDataFromFirebase() async {
    try {
      print('🔄 جلب البيانات من Firebase...');

      // ✅ 1. جلب الأطباء الجدد
      final doctorsSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .limit(10)
          .get();

      if (doctorsSnapshot.docs.isNotEmpty && mounted) {
        final List<Map<String, dynamic>> firebaseDoctors = [];
        for (var doc in doctorsSnapshot.docs) {
          final data = doc.data();
          firebaseDoctors.add({
            'id': doc.id,
            'name': data['name'] ?? 'دكتور',
            'specialty': data['specialty'] ?? 'طبيب عام',
            'rating': data['rating'] ?? 4.0,
            'reviews': data['reviews'] ?? 0,
            'image': data['image'] ?? ImageKit.doctor1,
          });
        }

        setState(() {
          _topDoctors = [..._defaultTopDoctors, ...firebaseDoctors];
        });
        print('✅ تم جلب ${firebaseDoctors.length} طبيب جديد');
      }

      // ✅ 2. جلب المنتجات الجديدة
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(10)
          .get();

      if (productsSnapshot.docs.isNotEmpty && mounted) {
        final List<Map<String, dynamic>> firebaseProducts = [];
        for (var doc in productsSnapshot.docs) {
          final data = doc.data();
          firebaseProducts.add({
            'name': data['name'] ?? 'منتج',
            'price': data['price'] ?? 0,
            'image': data['image'] ?? ImageKit.medicine1,
            'category': data['category'] ?? 'عام',
            'discount': data['discount'] ?? 0,
            'rating': data['rating'] ?? 4.0,
          });
        }

        setState(() {
          _products = [..._defaultProducts, ...firebaseProducts];
        });
        print('✅ تم جلب ${firebaseProducts.length} منتج جديد');
      }

      // ✅ 3. جلب المستشفيات الجديدة
      final hospitalsSnapshot = await FirebaseFirestore.instance
          .collection('hospitals')
          .limit(6)
          .get();

      if (hospitalsSnapshot.docs.isNotEmpty && mounted) {
        final List<Map<String, dynamic>> firebaseHospitals = [];
        for (var doc in hospitalsSnapshot.docs) {
          final data = doc.data();
          firebaseHospitals.add({
            'id': doc.id,
            'name': data['name'] ?? 'مستشفى',
            'location': data['location'] ?? 'صنعاء',
            'image': data['image'] ?? ImageKit.hospital1,
            'rating': data['rating'] ?? 4.0,
            'open': data['open'] ?? true,
          });
        }

        setState(() {
          _featuredHospitals = [..._defaultFeaturedHospitals, ...firebaseHospitals];
        });
        print('✅ تم جلب ${firebaseHospitals.length} مستشفى جديد');
      }

      // ✅ 4. جلب المختبرات الجديدة
      final labsSnapshot = await FirebaseFirestore.instance
          .collection('labs')
          .limit(6)
          .get();

      if (labsSnapshot.docs.isNotEmpty && mounted) {
        final List<Map<String, dynamic>> firebaseLabs = [];
        for (var doc in labsSnapshot.docs) {
          final data = doc.data();
          firebaseLabs.add({
            'id': doc.id,
            'name': data['name'] ?? 'مختبر',
            'location': data['location'] ?? 'صنعاء',
            'image': data['image'] ?? ImageKit.lab1,
            'rating': data['rating'] ?? 4.0,
            'open': data['open'] ?? true,
          });
        }

        setState(() {
          _featuredLabs = [..._defaultFeaturedLabs, ...firebaseLabs];
        });
        print('✅ تم جلب ${firebaseLabs.length} مختبر جديد');
      }

      // ✅ 5. جلب الصيدليات الجديدة
      final pharmaciesSnapshot = await FirebaseFirestore.instance
          .collection('pharmacies')
          .limit(6)
          .get();

      if (pharmaciesSnapshot.docs.isNotEmpty && mounted) {
        final List<Map<String, dynamic>> firebasePharmacies = [];
        for (var doc in pharmaciesSnapshot.docs) {
          final data = doc.data();
          firebasePharmacies.add({
            'id': doc.id,
            'name': data['name'] ?? 'صيدلية',
            'location': data['location'] ?? 'صنعاء',
            'image': data['image'] ?? ImageKit.pharmacy1,
            'rating': data['rating'] ?? 4.0,
            'open': data['open'] ?? true,
          });
        }

        setState(() {
          _featuredPharmacies = [..._defaultFeaturedPharmacies, ...firebasePharmacies];
        });
        print('✅ تم جلب ${firebasePharmacies.length} صيدلية جديدة');
      }

      // ✅ 6. جلب المنشورات الجديدة
      final postsSnapshot = await FirebaseFirestore.instance
          .collection('community_posts')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      if (postsSnapshot.docs.isNotEmpty && mounted) {
        final List<Map<String, dynamic>> firebasePosts = [];
        for (var doc in postsSnapshot.docs) {
          final data = doc.data();
          firebasePosts.add({
            'id': doc.id,
            'author': data['author'] ?? 'مستخدم',
            'avatar': data['avatar'] ?? 'م',
            'image': data['image'] ?? ImageKit.skinCare,
            'title': data['title'] ?? 'منشور',
            'content': data['content'] ?? '',
            'likes': data['likes'] ?? 0,
            'comments': data['comments'] ?? 0,
            'shares': data['shares'] ?? 0,
            'views': data['views'] ?? 0,
            'time': _formatTime((data['timestamp'] as Timestamp?)?.toDate()),
            'liked': false,
            'saved': false,
            'reported': false,
          });
        }

        setState(() {
          _communityPosts = [..._defaultCommunityPosts, ...firebasePosts];
        });
        print('✅ تم جلب ${firebasePosts.length} منشور جديد');
      }

      print('✅ تم تحديث جميع البيانات من Firebase');

    } catch (e) {
      print('⚠️ Error fetching data from Firebase: $e');
    }
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
  // 🧭 دوال التنقل
  // ============================================================
  void _goTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ============================================================
  // ❤️ دوال التفاعل
  // ============================================================
  void _sharePost(int index) {
    final post = _communityPosts[index];
    Share.share(
      '📢 ${post['title']}\n\n${post['content']}\n\n👁️ ${post['views']} مشاهدة\n❤️ ${post['likes']} إعجاب\n💬 ${post['comments']} تعليق\n\n---\nمنشور من تطبيق صحتك - Sehatak',
      subject: post['title'],
    );
  }

  void _toggleLike(int index) {
    setState(() {
      final isLiked = _communityPosts[index]['liked'] ?? false;
      _communityPosts[index]['liked'] = !isLiked;
      if (isLiked) {
        _communityPosts[index]['likes']--;
      } else {
        _communityPosts[index]['likes']++;
      }
    });
  }

  void _savePost(int index) {
    setState(() {
      _communityPosts[index]['saved'] = !(_communityPosts[index]['saved'] ?? false);
    });
    ToastService.showSuccess(_communityPosts[index]['saved'] ? '✅ تم حفظ المنشور' : '❌ تم إلغاء الحفظ');
  }

  void _reportPost(int index) {
    setState(() {
      _communityPosts[index]['reported'] = true;
    });
    ToastService.showSuccess('✅ تم الإبلاغ عن المنشور');
  }

  void _showComments(Map<String, dynamic> post, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _buildCommentsSheet(post, index),
    );
  }

  Widget _buildCommentsSheet(Map<String, dynamic> post, int index) {
    final TextEditingController _commentController = TextEditingController();
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
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, i) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text('م', style: TextStyle(color: AppColors.primary)),
                  ),
                  title: Text('مستخدم ${i + 1}'),
                  subtitle: Text('تعليق تجريبي رقم ${i + 1}'),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'أضف تعليقاً...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () {
                    ToastService.showSuccess('✅ تم إضافة التعليق');
                    _commentController.clear();
                    _focusNode.unfocus();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
              Image.asset(tip['icon'] as String, width: 40, height: 40, errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.grey[600], size: 32)),
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

  // ============================================================
  // 🏗️ بناء الواجهة الرئيسية
  // ============================================================
  DoctorModel _doctorModelFromMap(Map<String, dynamic> data) {
    return DoctorModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      specialty: data['specialty']?.toString() ?? '',
      photoUrl: data['image']?.toString() ?? data['photoUrl']?.toString(),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: (data['reviews'] as num?)?.toInt() ??
          (data['reviewsCount'] as num?)?.toInt(),
      isAvailable: data['isAvailable'] as bool? ?? false,
      isOnline: data['isOnline'] as bool? ?? false,
      isVerified: data['isVerified'] as bool? ?? false,
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && !_dataLoaded) {
      return _buildShimmerLoader(isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _fetchDataFromFirebase,
        child: CustomScrollView(
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
                  if (_isLoggedIn) _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildSectionWithCustomization('خدمات سريعة', isDark, _buildQuickServicesRow(isDark)),
                  _buildSectionWithCustomization('أفضل الأطباء', isDark, _buildTopDoctorsGrid(isDark)),
                  _buildSectionWithCustomization('منتجات صيدلية', isDark, _buildProductsRow(isDark)),
                  _buildSectionWithCustomization('مستشفيات مميزة', isDark, _buildFeaturedHospitalsGrid(isDark)),
                  _buildSectionWithCustomization('مختبرات مميزة', isDark, _buildFeaturedLabsGrid(isDark)),
                  _buildSectionWithCustomization('صيدليات مميزة', isDark, _buildFeaturedPharmaciesGrid(isDark)),
                  _buildSectionWithCustomization('أحدث المقالات', isDark, _buildArticlesGrid(isDark)),
                  _buildSectionWithCustomization('نصائح يومية', isDark, _buildDailyTipsGrid(isDark)),
                  _buildSectionWithCustomization('مجتمع صحتك', isDark, _buildCommunityPosts(isDark)),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithCustomization(String title, bool isDark, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, isDark),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
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

  // ============================================================
  // 🧩 ويدجت Shimmer Loader
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

  // ============================================================
  // 🧩 ويدجت AppBar
  // ============================================================
  Widget _buildCurvedAppBar(bool isDark) {
    return Opacity(
      opacity: _appBarOpacity,
      child: ClipPath(
        clipper: SideCurvedClipper(),
        child: Container(
          height: 180,
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
                      GestureDetector(
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
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _goTo(context, const NotificationsScreen()),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.notifications, color: Colors.white, size: 26),
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
                          child: Icon(Icons.shopping_cart, color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
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
                          const Icon(Icons.search, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ابحث عن طبيب، دواء، أو خدمة...',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.mic, color: Colors.white70, size: 20),
                        ],
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
  // 🧩 ويدجت Banner Carousel
  // ============================================================
  Widget _buildBannerCarousel(bool isDark) {
    if (_bannerImages.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.grey[200], borderRadius: BorderRadius.circular(16)),
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
                  height: 160,
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

  // ============================================================
  // 🧩 ويدجت الإحصائيات
  // ============================================================
  Widget _buildStatsRow() {
    final statsData = [
      {'icon': Icons.local_fire_department, 'value': 0, 'label': 'سعرة', 'color': Colors.orange},
      {'icon': Icons.directions_walk, 'value': 0, 'label': 'خطوة', 'color': Colors.green},
      {'icon': Icons.bedtime, 'value': 0, 'label': 'نوم', 'color': Colors.purple},
      {'icon': Icons.favorite, 'value': 0, 'label': 'نبض', 'color': Colors.red},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: statsData.map((stat) {
        final color = stat['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  '0',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                ),
                Text(
                  stat['label'] as String,
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // 🧩 ويدجت الخدمات السريعة
  // ============================================================
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

  // ============================================================
  // 🧩 ويدجت الأطباء
  // ============================================================
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
          onTap: () => _goTo(context, DoctorDetailsScreen(doctorId: _doctorModelFromMap(doctor))),
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
                          onPressed: () => _goTo(context, DoctorDetailsScreen(doctorId: _doctorModelFromMap(doctor))),
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

  // ============================================================
  // 🧩 ويدجت المنتجات
  // ============================================================
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

  // ============================================================
  // 🧩 ويدجت المستشفيات
  // ============================================================
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
                      child: AppImage(imageUrl: hospital['image'] as String, height: 90, width: double.infinity, fit: BoxFit.cover),
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

  // ============================================================
  // 🧩 ويدجت المختبرات
  // ============================================================
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

  // ============================================================
  // 🧩 ويدجت الصيدليات
  // ============================================================
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

  // ============================================================
  // 🧩 ويدجت المقالات
  // ============================================================
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

  // ============================================================
  // 🧩 ويدجت النصائح اليومية
  // ============================================================
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
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 32),
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

  // ============================================================
  // 🧩 ويدجت المجتمع
  // ============================================================
  Widget _buildCommunityPosts(bool isDark) {
    return Column(
      children: _communityPosts.asMap().entries.map((entry) {
        final index = entry.key;
        final post = entry.value;
        return Container(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppImage(imageUrl: post['image'] as String, height: 200, width: double.infinity, fit: BoxFit.cover),
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
        );
      }).toList(),
    );
  }
}
