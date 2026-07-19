import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/vaccination/vaccination_screen.dart';
import 'package:sehatak/presentation/screens/diet/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/exercise/exercise_plan_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/pregnancy/pregnancy_tracker_screen.dart';
import 'package:sehatak/presentation/screens/child_growth/child_growth_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/heart_rate/heart_rate_screen.dart';
import 'package:sehatak/presentation/screens/sleep_tracker/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/step_counter/step_counter_screen.dart';
import 'package:sehatak/presentation/screens/health_tools/bmi_calculator_screen.dart';
import 'package:sehatak/presentation/screens/health_tools/calorie_calculator_screen.dart';
import 'package:sehatak/presentation/screens/health_tools/stress_meter_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/drug_dictionary/drug_dictionary_screen.dart';
import 'package:sehatak/presentation/screens/drug_compare/drug_compare_screen.dart';
import 'package:sehatak/presentation/screens/pediatric_dose/pediatric_dose_screen.dart';
import 'package:sehatak/presentation/screens/vision_test/vision_test_screen.dart';
import 'package:sehatak/presentation/screens/dental_care/dental_care_screen.dart';
import 'package:sehatak/presentation/screens/eye_care/eye_care_screen.dart';
import 'package:sehatak/presentation/screens/health_challenges/health_challenges_screen.dart';
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/health_education/health_education_screen.dart';
import 'package:sehatak/presentation/screens/health_tips/health_tips_screen.dart';
import 'package:sehatak/presentation/screens/health_news/health_news_screen.dart';
import 'package:sehatak/presentation/screens/nearby_clinics/nearby_clinics_screen.dart';
import 'package:sehatak/presentation/screens/hospital_booking/hospital_booking_screen.dart';
import 'package:sehatak/presentation/screens/hospital_compare/hospital_compare_screen.dart';
import 'package:sehatak/presentation/screens/physiotherapy/physiotherapy_screen.dart';
import 'package:sehatak/presentation/screens/family_planning/family_planning_screen.dart';
import 'package:sehatak/presentation/screens/genetic_counseling/genetic_counseling_screen.dart';
import 'package:sehatak/presentation/screens/alternative_medicine/alternative_medicine_screen.dart';
import 'package:sehatak/presentation/screens/voice_search/voice_search_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/settings/about_screen.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';
import 'package:sehatak/presentation/screens/help_center/help_center_screen.dart';
import 'package:sehatak/presentation/screens/women_health/period_tracker_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_medical_history.dart';
import 'package:sehatak/presentation/screens/patient/patient_prescriptions.dart';
import 'package:sehatak/presentation/screens/contact_us/contact_us_screen.dart';
import 'package:sehatak/presentation/screens/settings/privacy_screen.dart';

// ============================================================
// 📱 HomeScreen - الشاشة الرئيسية
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final ValueNotifier<bool> _isBottomBarVisible = ValueNotifier<bool>(true);
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeTab(),
      const DoctorsListScreen(),
      const PharmacyScreen(),
      const ChatScreen(),
      const LabsListScreen(),
      const PatientDashboard(),
      const MoreScreen(),
    ];
  }

  @override
  void dispose() {
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _screens[_currentIndex],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isBottomBarVisible,
              builder: (context, isVisible, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isVisible ? 68 : 0,
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
                          _buildChatButton(),
                          _buildNavItem(4, Icons.science_rounded, 'مختبرات'),
                          _buildNavItem(5, Icons.folder_rounded, 'صحتي'),
                          _buildNavItem(6, Icons.grid_view_rounded, 'المزيد'),
                        ],
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

  Widget _buildChatButton() {
    final selected = _currentIndex == 3;
    return GestureDetector(
      onTap: () => _onTabTap(3),
      child: SizedBox(
        width: 56,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 30,
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
            const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🏠 HomeTab - المحتوى الرئيسي
// ============================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _currentBanner = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  _HomeScreenState? _homeState;

  // ============================================================
  // 📊 البيانات
  // ============================================================

  final List<String> _bannerImages = ImageService.bannerList;

  final List<Map<String, dynamic>> _topDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'rating': 4.9, 'reviews': 328, 'image': ImageService.doctor1, 'gender': 'male'},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'rating': 4.8, 'reviews': 256, 'image': ImageService.doctor2, 'gender': 'male'},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'rating': 4.7, 'reviews': 189, 'image': ImageService.doctor3, 'gender': 'female'},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.6, 'reviews': 89, 'image': ImageService.doctor4, 'gender': 'male'},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'rating': 4.8, 'reviews': 210, 'image': ImageService.doctor5, 'gender': 'female'},
  ];

  final List<Map<String, dynamic>> _quickServices = [
    {'icon': ImageService.fastPharmacy, 'label': 'صيدلية', 'color': AppColors.success, 'screen': const MedicinesScreen()},
    {'icon': ImageService.fastEmergency, 'label': 'طوارئ', 'color': AppColors.error, 'screen': const EmergencyNumbers()},
    {'icon': ImageService.fastHomeServices, 'label': 'خدمات منزلية', 'color': Colors.brown, 'screen': const ServicesScreen()},
    {'icon': ImageService.fastDonateBlood, 'label': 'تبرع بالدم', 'color': Colors.red, 'screen': const BloodDonationScreen()},
    {'icon': ImageService.serviceDoctors, 'label': 'أطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': ImageService.serviceLabs, 'label': 'مختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': ImageService.serviceHealth, 'label': 'صحة', 'color': AppColors.pink, 'screen': const HealthDashboard()},
    {'icon': ImageService.serviceWallet, 'label': 'محفظة', 'color': AppColors.amber, 'screen': const WalletScreen()},
    {'icon': ImageService.serviceConsultation, 'label': 'استشارة', 'color': AppColors.teal, 'screen': const ConsultationScreen()},
    {'icon': ImageService.serviceAppointments, 'label': 'مواعيد', 'color': AppColors.primaryDark, 'screen': const PatientAppointments()},
    {'icon': ImageService.serviceNearby, 'label': 'بالقرب منك', 'color': Colors.orange, 'screen': const InteractiveMapScreen()},
    {'icon': ImageService.serviceInsurance, 'label': 'تأمين', 'color': Colors.blue, 'screen': const InsuranceCompanies()},
  ];

  List<Map<String, dynamic>> _communityPosts = [
    {'id': 1, 'author': 'د. سارة العمري', 'avatar': 'assets/images/posts/avatar1.png', 'image': 'assets/images/posts/skin_care.png', 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك واستخدام واقي الشمس.', 'likes': 120, 'comments': 15, 'shares': 8, 'time': 'منذ ساعة', 'liked': false},
    {'id': 2, 'author': 'د. خالد النخلاني', 'avatar': 'assets/images/posts/avatar2.png', 'image': 'assets/images/posts/morning_walk.png', 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري.', 'likes': 95, 'comments': 8, 'shares': 5, 'time': 'منذ 3 ساعات', 'liked': false},
    {'id': 3, 'author': 'د. أحمد المولد', 'avatar': 'assets/images/posts/avatar3.png', 'image': 'assets/images/posts/nutrition_tips.png', 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية والجسم السليم.', 'likes': 210, 'comments': 22, 'shares': 12, 'time': 'منذ 5 ساعات', 'liked': true},
    {'id': 4, 'author': 'د. أسماء الهندي', 'avatar': 'assets/images/posts/avatar4.png', 'image': 'assets/images/posts/immune_boost.png', 'title': 'قوة المناعة', 'content': 'الفيتامينات والمعادن تلعب دوراً كبيراً في تقوية المناعة.', 'likes': 78, 'comments': 5, 'shares': 3, 'time': 'منذ يوم', 'liked': false},
    {'id': 5, 'author': 'د. محمد العلاي', 'avatar': 'assets/images/posts/avatar5.png', 'image': 'assets/images/posts/sleep_tips.png', 'title': 'نصائح النوم الصحي', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية والجسدية.', 'likes': 150, 'comments': 12, 'shares': 7, 'time': 'منذ يومين', 'liked': false},
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

  // ===== مستشفيات مميزة (6 مستشفيات) =====
  final List<Map<String, dynamic>> _featuredHospitals = [
    {'id': '1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء', 'image': ImageService.hospital1, 'rating': 4.9, 'phone': '01-234571', 'specialty': 'عام'},
    {'id': '2', 'name': 'مستشفى الجمهورية', 'location': 'صنعاء', 'image': ImageService.hospital2, 'rating': 4.8, 'phone': '01-234572', 'specialty': 'عام'},
    {'id': '3', 'name': 'مستشفى السبعين', 'location': 'صنعاء', 'image': ImageService.hospital3, 'rating': 4.7, 'phone': '01-234573', 'specialty': 'أطفال وولادة'},
    {'id': '4', 'name': 'مستشفى الكويت', 'location': 'صنعاء', 'image': ImageService.hospital4, 'rating': 4.8, 'phone': '01-234574', 'specialty': 'جراحة'},
    {'id': '5', 'name': 'مستشفى الثورة العام', 'location': 'صنعاء', 'image': ImageService.hospital5, 'rating': 4.6, 'phone': '01-234575', 'specialty': 'عام'},
    {'id': '6', 'name': 'مستشفى الأمل', 'location': 'صنعاء', 'image': ImageService.hospital6, 'rating': 4.5, 'phone': '01-234576', 'specialty': 'أمراض قلبية'},
  ];

  // ===== مختبرات مميزة (6 مختبرات) =====
  final List<Map<String, dynamic>> _featuredLabs = [
    {'id': '1', 'name': 'مختبرات الذبحاني', 'location': 'صنعاء - شارع الأصبحي', 'image': ImageService.lab1, 'rating': 4.9, 'phone': '01-234567', 'open': true},
    {'id': '2', 'name': 'مختبرات العولقي', 'location': 'صنعاء - شارع الستين', 'image': ImageService.lab2, 'rating': 4.8, 'phone': '01-234568', 'open': true},
    {'id': '3', 'name': 'مختبرات المأمون', 'location': 'صنعاء - حدة', 'image': ImageService.lab3, 'rating': 4.7, 'phone': '01-234569', 'open': true},
    {'id': '4', 'name': 'مختبر الرازي', 'location': 'صنعاء - باب اليمن', 'image': ImageService.lab1, 'rating': 4.6, 'phone': '01-234570', 'open': false},
    {'id': '5', 'name': 'مختبرات النخبة', 'location': 'صنعاء - التحرير', 'image': ImageService.lab2, 'rating': 4.5, 'phone': '01-234571', 'open': true},
    {'id': '6', 'name': 'مختبرات اليمن الحديثة', 'location': 'صنعاء - شارع الزبيري', 'image': ImageService.lab3, 'rating': 4.4, 'phone': '01-234572', 'open': true},
  ];

  // ===== صيدليات مميزة (6 صيدليات) =====
  final List<Map<String, dynamic>> _featuredPharmacies = [
    {'id': '1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء - شارع حدة', 'image': ImageService.pharmacyIbnHayyan, 'rating': 4.9, 'phone': '01-234580', 'open': true},
    {'id': '2', 'name': 'صيدلية عالم الصيدلة', 'location': 'صنعاء - شارع الستين', 'image': ImageService.pharmacyAlamAlSaidala, 'rating': 4.8, 'phone': '01-234581', 'open': true},
    {'id': '3', 'name': 'صيدلية النهضة', 'location': 'صنعاء - باب اليمن', 'image': ImageService.pharmacyAlShifa, 'rating': 4.7, 'phone': '01-234582', 'open': true},
    {'id': '4', 'name': 'صيدليات اليمن الحديثة', 'location': 'صنعاء - شارع الزبيري', 'image': ImageService.pharmacyIbnHayyan, 'rating': 4.6, 'phone': '01-234583', 'open': true},
    {'id': '5', 'name': 'صيدلية الشفاء', 'location': 'صنعاء - حدة', 'image': ImageService.pharmacyAlamAlSaidala, 'rating': 4.5, 'phone': '01-234584', 'open': false},
    {'id': '6', 'name': 'صيدلية الأمانة', 'location': 'صنعاء - التحرير', 'image': ImageService.pharmacyAlShifa, 'rating': 4.4, 'phone': '01-234585', 'open': true},
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

  // ✅ دالة موحدة لعرض أي صورة مع fallback
  Widget _buildImageAsset(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    Widget child = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      color: color,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(Icons.image_not_supported, color: Colors.grey[400], size: (width ?? 40) * 0.5),
        );
      },
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: child);
    }
    return child;
  }

  // ✅ دالة صورة الطبيب مع SVG placeholder حسب الجنس
  Widget _buildDoctorAvatar(String? imagePath, {double size = 55, String gender = 'male'}) {
    final fallbackSvg = gender == 'female'
        ? 'assets/images/doctors/doctor_female_placeholder.svg'
        : 'assets/images/doctors/doctor_placeholder.svg';

    if (imagePath == null || imagePath.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SvgPicture.asset(
          fallbackSvg,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: Icon(Icons.person, color: Colors.grey[400], size: size * 0.5),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SvgPicture.asset(
              fallbackSvg,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => Container(
                width: size,
                height: size,
                color: Colors.grey[200],
                child: Icon(Icons.person, color: Colors.grey[400], size: size * 0.5),
              ),
            ),
          );
        },
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _homeState = context.findAncestorStateOfType<_HomeScreenState>();
      }
    });

    _scrollController.addListener(() {
      if (_homeState == null) return;
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse) {
        if (_homeState!._isBottomBarVisible.value != false) {
          _homeState!._isBottomBarVisible.value = false;
        }
      } else if (direction == ScrollDirection.forward) {
        if (_homeState!._isBottomBarVisible.value != true) {
          _homeState!._isBottomBarVisible.value = true;
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

  @override
  bool get wantKeepAlive => true;

  // ============================================================
  // 🎨 بناء الواجهة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 90,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
              foregroundColor: primaryColor,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 20, backgroundColor: Colors.grey[300]),
                      const SizedBox(width: 12),
                      Expanded(child: Container(height: 16, color: Colors.grey[300])),
                      const SizedBox(width: 8),
                      Container(width: 40, height: 40, color: Colors.grey[300]),
                      const SizedBox(width: 8),
                      Container(width: 40, height: 40, color: Colors.grey[300]),
                    ],
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
                  _buildShimmerBox(height: 180),
                  const SizedBox(height: 20),
                  _buildShimmerBox(height: 80),
                  const SizedBox(height: 24),
                  _buildShimmerBox(height: 90),
                  const SizedBox(height: 24),
                  _buildShimmerBox(height: 110),
                  const SizedBox(height: 24),
                  _buildShimmerBox(height: 200),
                ]),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 90,
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
              foregroundColor: primaryColor,
              elevation: 0,
              automaticallyImplyLeading: false,
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
                        child: Hero(
                          tag: 'user_avatar',
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
                        icon: _buildImageAsset(
                          ImageService.notificationIcon,
                          width: 24,
                          height: 24,
                          color: primaryColor,
                        ),
                        onPressed: () => _goTo(context, const NotificationsScreen()),
                      ),
                      IconButton(
                        icon: _buildImageAsset(
                          ImageService.cartIcon,
                          width: 24,
                          height: 24,
                          color: primaryColor,
                        ),
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(isDark),
                  const SizedBox(height: 16),
                  _buildBannerCarousel(isDark, primaryColor),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildSectionTitleWithAction('خدمات سريعة', isDark, 'عرض الكل', () => _goTo(context, const ServicesScreen())),
                  const SizedBox(height: 10),
                  _buildQuickServicesRow(),
                  const SizedBox(height: 24),
                  _buildSectionTitleWithAction('أفضل الأطباء', isDark, 'عرض الكل', () => _goTo(context, const DoctorsListScreen())),
                  const SizedBox(height: 10),
                  _buildTopDoctorsRow(),
                  const SizedBox(height: 24),
                  _buildSectionTitleWithAction('منتجات صيدلية', isDark, 'عرض الكل', () => _goTo(context, const MedicinesScreen())),
                  const SizedBox(height: 10),
                  _buildProductsRow(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('نصائح يومية', isDark),
                  const SizedBox(height: 10),
                  _buildDailyTipsGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitleWithAction('مختبرات مميزة', isDark, 'عرض الكل', () => _goTo(context, const LabsListScreen())),
                  const SizedBox(height: 10),
                  _buildFeaturedLabsRow(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitleWithAction('مستشفيات مميزة', isDark, 'عرض الكل', () => _goTo(context, const HospitalScreen())),
                  const SizedBox(height: 10),
                  _buildFeaturedHospitalsRow(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitleWithAction('صيدليات مميزة', isDark, 'عرض الكل', () => _goTo(context, const PharmacyScreen())),
                  const SizedBox(height: 10),
                  _buildFeaturedPharmaciesRow(isDark),
                  const SizedBox(height: 24),
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
          _buildImageAsset(
            ImageService.searchIcon,
            width: 20,
            height: 20,
          ),
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

  Widget _buildBannerCarousel(bool isDark, Color primaryColor) {
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
          items: _bannerImages.map((imagePath) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImageAsset(imagePath, height: 160),
              ),
            );
          }).toList(),
        ),
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
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickServicesRow() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickServices.length,
        itemBuilder: (context, index) {
          final service = _quickServices[index];
          final color = service['color'] as Color;
          return GestureDetector(
            onTap: () => _goTo(context, service['screen'] as Widget),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildImageAsset(
                      service['icon'] as String,
                      width: 32,
                      height: 32,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service['label'] as String,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
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

  Widget _buildTopDoctorsRow() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topDoctors.length,
        itemBuilder: (context, index) {
          final doctor = _topDoctors[index];
          return GestureDetector(
            onTap: () => _goTo(context, DoctorDetailsScreen(doctorId: doctor['id'] as String)),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Hero(
                    tag: 'doctor_${doctor['id']}',
                    child: _buildDoctorAvatar(
                      doctor['image'],
                      size: 55,
                      gender: doctor['gender'] ?? 'male',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          doctor['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          doctor['specialty'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${doctor['rating']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${doctor['reviews']})',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
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
                    child: _buildImageAsset(
                      product['image'],
                      height: 70,
                      width: 70,
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

  // ===== مختبرات مميزة =====
  Widget _buildFeaturedLabsRow(bool isDark) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredLabs.length,
        itemBuilder: (context, index) {
          final lab = _featuredLabs[index];
          return GestureDetector(
            onTap: () => _showLabDetails(lab),
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
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImageAsset(
                      lab['image'] as String,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lab['name'] as String,
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
                                lab['location'] as String,
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
                        Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${lab['rating']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: (lab['open'] as bool) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (lab['open'] as bool) ? 'مفتوح' : 'مغلق',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: (lab['open'] as bool) ? Colors.green : Colors.red,
                                ),
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

  // ===== مستشفيات مميزة =====
  Widget _buildFeaturedHospitalsRow(bool isDark) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredHospitals.length,
        itemBuilder: (context, index) {
          final hospital = _featuredHospitals[index];
          return GestureDetector(
            onTap: () => _showHospitalDetails(hospital),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImageAsset(
                      hospital['image'] as String,
                      fit: BoxFit.cover,
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
                    Padding(
                      padding: const EdgeInsets.all(12),
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
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '${hospital['rating']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
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
            ),
          );
        },
      ),
    );
  }

  // ===== صيدليات مميزة =====
  Widget _buildFeaturedPharmaciesRow(bool isDark) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredPharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = _featuredPharmacies[index];
          return GestureDetector(
            onTap: () => _showPharmacyDetails(pharmacy),
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
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImageAsset(
                      pharmacy['image'] as String,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pharmacy['name'] as String,
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
                                pharmacy['location'] as String,
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
                        Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '${pharmacy['rating']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: (pharmacy['open'] as bool) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (pharmacy['open'] as bool) ? 'مفتوح' : 'مغلق',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: (pharmacy['open'] as bool) ? Colors.green : Colors.red,
                                ),
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

  // ===== عرض تفاصيل المختبر =====
  void _showLabDetails(Map<String, dynamic> lab) {
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
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageAsset(
                    lab['image'] as String,
                    width: 60,
                    height: 60,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lab['name'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            lab['location'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${lab['rating']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (lab['open'] as bool) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (lab['open'] as bool) ? 'مفتوح' : 'مغلق',
                              style: TextStyle(
                                fontSize: 12,
                                color: (lab['open'] as bool) ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  lab['phone'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LabsListScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('عرض جميع المختبرات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== عرض تفاصيل المستشفى =====
  void _showHospitalDetails(Map<String, dynamic> hospital) {
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
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageAsset(
                    hospital['image'] as String,
                    width: 60,
                    height: 60,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            hospital['location'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${hospital['rating']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              hospital['specialty'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  hospital['phone'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري حجز موعد...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('حجز موعد'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HospitalScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('عرض الكل'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== عرض تفاصيل الصيدلية =====
  void _showPharmacyDetails(Map<String, dynamic> pharmacy) {
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
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageAsset(
                    pharmacy['image'] as String,
                    width: 60,
                    height: 60,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy['name'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            pharmacy['location'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${pharmacy['rating']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (pharmacy['open'] as bool) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (pharmacy['open'] as bool) ? 'مفتوح' : 'مغلق',
                              style: TextStyle(
                                fontSize: 12,
                                color: (pharmacy['open'] as bool) ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  pharmacy['phone'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PharmacyScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('عرض جميع الصيدليات'),
              ),
            ),
          ],
        ),
      ),
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
                  radius: 18,
                  backgroundImage: AssetImage(post['avatar']),
                  onBackgroundImageError: (_, __) {},
                  child: const Icon(Icons.person, size: 18),
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
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Image.asset(
              post['image'],
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 220,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey, size: 40),
                );
              },
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
// 🔍 AppSearchDelegate - البحث المتقدم والشامل
// ============================================================
class AppSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'ابحث عن طبيب، دواء، خدمة، مستشفى، مختبر...';

  @override
  TextStyle get searchFieldStyle => const TextStyle(
        fontFamily: 'NotoSansArabicUI',
        fontSize: 16,
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return _buildRecentSearches(context);
    return _buildSearchResults(context);
  }

  Widget _buildRecentSearches(BuildContext context) {
    final recentSearches = [
      'طبيب باطنية',
      'باراسيتامول',
      'مختبر تحاليل',
      'صيدلية 24 ساعة',
      'استشارة قلبية',
      'تحليل دم شامل',
      'مستشفى 22 مايو',
      'د. أحمد المولد',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'عمليات البحث الأخيرة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(recentSearches[index]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                query = recentSearches[index];
                showResults(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final List<Map<String, dynamic>> allData = [
      {'id': 'd1', 'name': 'د. أحمد المولد', 'type': 'طبيب', 'subtitle': 'باطنية', 'icon': Icons.medical_services, 'color': Colors.teal},
      {'id': 'd2', 'name': 'د. خالد النخلاني', 'type': 'طبيب', 'subtitle': 'قلبية', 'icon': Icons.medical_services, 'color': Colors.teal},
      {'id': 'd3', 'name': 'د. أسماء الهندي', 'type': 'طبيب', 'subtitle': 'أطفال', 'icon': Icons.medical_services, 'color': Colors.teal},
      {'id': 'm1', 'name': 'باراسيتامول 500mg', 'type': 'دواء', 'subtitle': 'مسكن ألم', 'icon': Icons.medication, 'color': Colors.blue},
      {'id': 'm2', 'name': 'فيتامين د 1000IU', 'type': 'دواء', 'subtitle': 'مكمل غذائي', 'icon': Icons.medication, 'color': Colors.blue},
      {'id': 'h1', 'name': 'مستشفى 22 مايو', 'type': 'مستشفى', 'subtitle': 'صنعاء', 'icon': Icons.local_hospital, 'color': Colors.red},
      {'id': 'l1', 'name': 'مختبرات الزارزي', 'type': 'مختبر', 'subtitle': 'صنعاء - الزبيري', 'icon': Icons.science, 'color': Colors.purple},
      {'id': 'p1', 'name': 'صيدلية ابن حيان', 'type': 'صيدلية', 'subtitle': 'صنعاء - حدة', 'icon': Icons.local_pharmacy, 'color': Colors.green},
    ];

    final searchText = query.toLowerCase();
    final results = allData.where((item) {
      final name = item['name'] as String? ?? '';
      final subtitle = item['subtitle'] as String? ?? '';
      return name.toLowerCase().contains(searchText) ||
          subtitle.toLowerCase().contains(searchText);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نعثر على أي نتائج لـ "$query"',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final color = item['color'] as Color? ?? AppColors.primary;
        final icon = item['icon'] as IconData? ?? Icons.search;
        final name = item['name'] as String? ?? '';
        final subtitle = item['subtitle'] as String? ?? '';
        final type = item['type'] as String? ?? '';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
            ),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم اختيار: $name'),
                backgroundColor: AppColors.primary,
              ),
            );
            close(context, null);
          },
        );
      },
    );
  }
}
