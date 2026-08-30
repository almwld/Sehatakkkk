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
  final GlobalScrollManager? scrollManager;
  final ScrollController? scrollController;
  final ValueNotifier<bool>? isBottomBarVisible;

  const HomeTab({super.key, this.scrollController, this.isBottomBarVisible, this.scrollManager});

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
  double _caloriesAnim = 0;
  double _stepsAnim = 0;
  double _sleepAnim = 0;
  double _heartAnim = 0;
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
