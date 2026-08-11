import 'package:sehatak/utils/image_utils.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/family_planning/family_planning_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';
import 'package:sehatak/presentation/screens/diet_plan/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/sleep_tracker/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';
import 'package:sehatak/presentation/screens/contact_us/contact_us_screen.dart';
import 'package:sehatak/presentation/screens/share_app/share_app_screen.dart';
import 'package:sehatak/presentation/screens/rate_app/rate_app_screen.dart';
import 'package:sehatak/presentation/screens/report_issue/report_issue_screen.dart';
import 'package:sehatak/presentation/screens/download_data/download_data_screen.dart';
import 'package:sehatak/presentation/screens/font_size/font_size_screen.dart';
import 'package:sehatak/presentation/screens/privacy/privacy_screen.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';
import 'package:sehatak/presentation/screens/help_center/help_center_screen.dart';
import 'package:sehatak/presentation/screens/platform/dashboard/platform_dashboard.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _selectedCategory = 'الكل';
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;
  
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  final List<String> _categories = [
    'الكل',
    'رعاية عائلية',
    'أدوات تشخيصية',
    'لوجستيات وتأمين',
    'إعدادات',
  ];

  final List<String> _adminEmails = [
    'admin@sehatak.com',
    'superadmin@sehatak.com',
    'almwld@gmail.com',
  ];

  // ✅ المؤشرات الحيوية - بحجم كبير مثل أفضل الأطباء
  final List<Map<String, dynamic>> _vitals = [
    {'title': 'عداد الخطوات', 'value': '5,230', 'unit': 'خطوة', 'icon': 'assets/images/tracking/fitness.png', 'color': Colors.orange, 'status': 'طبيعي', 'statusColor': Colors.green, 'screen': const SleepTrackerScreen()},
    {'title': 'ضغط الدم', 'value': '120/80', 'unit': 'ملم زئبق', 'icon': 'assets/images/tracking/blood_pressure.png', 'color': Colors.red, 'status': 'طبيعي', 'statusColor': Colors.green, 'screen': const BloodPressureScreen()},
    {'title': 'معدل القلب', 'value': '72', 'unit': 'نبضة/د', 'icon': 'assets/images/tracking/blood_pressure.png', 'color': Colors.pink, 'status': 'طبيعي', 'statusColor': Colors.green, 'screen': const HealthDashboard()},
    {'title': 'نسبة السكر', 'value': '95', 'unit': 'مغ/دسل', 'icon': 'assets/images/tracking/blood_sugar.png', 'color': Colors.blue, 'status': 'مرتفع', 'statusColor': Colors.red, 'screen': const GlucoseTrackerScreen()},
  ];

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ✅ دالة عرض أيقونة PNG بحجم كبير
  Widget _buildIcon(String iconPath, Color color, {double size = 32}) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: color, size: size);
      },
    );
  }

  List<Map<String, dynamic>> get _filteredServices {
    switch (_selectedCategory) {
      case 'رعاية عائلية':
        return [
          {'icon': 'assets/images/services/medical_community.png', 'title': 'صحة المرأة', 'subtitle': 'متابعة الدورة والحمل', 'screen': const FamilyPlanningScreen()},
          {'icon': 'assets/images/services/health_tips.png', 'title': 'نمو الطفل', 'subtitle': 'مراحل التطور', 'screen': const FamilyPlanningScreen()},
          {'icon': 'assets/images/services/consultation.png', 'title': 'طبيب العائلة', 'subtitle': 'رعاية منزلية متكاملة', 'screen': const DoctorsListScreen()},
          {'icon': 'assets/images/services/medical_community.png', 'title': 'متابعة الحمل', 'subtitle': 'أسابيع الحمل بدقة', 'screen': const FamilyPlanningScreen()},
          {'icon': 'assets/images/tracking/mental_health.png', 'title': 'الصحة النفسية', 'subtitle': 'دعم الصحة النفسية', 'screen': const MentalHealthScreen()},
          {'icon': 'assets/images/tracking/nutrition.png', 'title': 'نظام غذائي', 'subtitle': 'خطط غذائية صحية', 'screen': const DietPlanScreen()},
          {'icon': 'assets/images/tracking/blood_pressure.png', 'title': 'تتبع النوم', 'subtitle': 'مراقبة جودة النوم', 'screen': const SleepTrackerScreen()},
        ];
      case 'أدوات تشخيصية':
        return [
          {'icon': 'assets/images/tracking/blood_pressure.png', 'title': 'ضغط الدم', 'subtitle': 'متابعة ضغط الدم', 'screen': const BloodPressureScreen()},
          {'icon': 'assets/images/tracking/blood_sugar.png', 'title': 'تتبع السكر', 'subtitle': 'مراقبة مستوى السكر', 'screen': const GlucoseTrackerScreen()},
          {'icon': 'assets/images/tracking/weight_tracking.png', 'title': 'الوزن', 'subtitle': 'تتبع الوزن واللياقة', 'screen': const WeightTrackerScreen()},
          {'icon': 'assets/images/services/medications.png', 'title': 'تذكير الأدوية', 'subtitle': 'تذكير بمواعيد الأدوية', 'screen': const MedicationReminderScreen()},
          {'icon': 'assets/images/services/blood_donation.png', 'title': 'التبرع بالدم', 'subtitle': 'مراكز التبرع بالدم', 'screen': const BloodDonationScreen()},
          {'icon': 'assets/images/services/medical_records.png', 'title': 'المقالات الطبية', 'subtitle': 'أحدث المقالات الطبية', 'screen': const ArticlesScreen()},
          {'icon': 'assets/images/services/emergency.png', 'title': 'الإسعافات الأولية', 'subtitle': 'دليل الإسعافات الأولية', 'screen': const FirstAidScreen()},
        ];
      case 'لوجستيات وتأمين':
        return [
          {'icon': 'assets/images/services/pharmacy.png', 'title': 'صيدلية', 'subtitle': 'طلب الأدوية وتوصيلها', 'screen': const PharmacyScreen()},
          {'icon': 'assets/images/services/laboratory.png', 'title': 'مختبرات', 'subtitle': 'حجز التحاليل والفحوصات', 'screen': const LabsListScreen()},
          {'icon': 'assets/images/services/health_insurance.png', 'title': 'تأمين صحي', 'subtitle': 'خطط التأمين والاشتراك', 'screen': const InsuranceCompanies()},
          {'icon': 'assets/images/services/map_location.png', 'title': 'خرائط المرافق', 'subtitle': 'أقرب المستشفيات والصيدليات', 'screen': const InteractiveMapScreen()},
          {'icon': 'assets/images/services/medical_community.png', 'title': 'المستشفيات', 'subtitle': 'أقرب المستشفيات', 'screen': const InteractiveMapScreen()},
          {'icon': 'assets/images/services/wallet.png', 'title': 'المحفظة', 'subtitle': 'إدارة محفظتك', 'screen': const WalletScreen()},
        ];
      case 'إعدادات':
        return [
          {'icon': 'assets/images/services/consultation.png', 'title': 'الملف الشخصي', 'subtitle': 'إدارة ملفك الشخصي', 'screen': const PatientProfile()},
          {'icon': 'assets/images/services/health_tips.png', 'title': 'الإعدادات', 'subtitle': 'إعدادات التطبيق', 'screen': const SettingsScreen()},
          {'icon': 'assets/images/services/notifications.png', 'title': 'الإشعارات', 'subtitle': 'إدارة الإشعارات', 'screen': const NotificationsScreen()},
          {'icon': 'assets/images/services/health_insurance.png', 'title': 'الخصوصية', 'subtitle': 'إعدادات الخصوصية', 'screen': const PrivacyScreen()},
          {'icon': 'assets/images/services/medical_records.png', 'title': 'الشروط والأحكام', 'subtitle': 'عرض الشروط والأحكام', 'screen': const TermsScreen()},
          {'icon': 'assets/images/services/medical_community.png', 'title': 'عن التطبيق', 'subtitle': 'معلومات عن التطبيق', 'screen': const AboutScreen()},
          {'icon': 'assets/images/services/emergency.png', 'title': 'مركز المساعدة', 'subtitle': 'الأسئلة الشائعة والدعم', 'screen': const HelpCenterScreen()},
          {'icon': 'assets/images/services/consultation.png', 'title': 'اتصل بنا', 'subtitle': 'تواصل مع فريق الدعم', 'screen': const ContactUsScreen()},
          {'icon': 'assets/images/services/medical_community.png', 'title': 'مشاركة التطبيق', 'subtitle': 'شارك التطبيق مع أصدقائك', 'screen': const ShareAppScreen()},
          {'icon': 'assets/images/services/health_tips.png', 'title': 'تقييم التطبيق', 'subtitle': 'قيم التطبيق', 'screen': const RateAppScreen()},
          {'icon': 'assets/images/services/medical_records.png', 'title': 'الإبلاغ عن مشكلة', 'subtitle': 'أبلغ عن مشكلة', 'screen': const ReportIssueScreen()},
          {'icon': 'assets/images/services/wallet.png', 'title': 'تحميل البيانات', 'subtitle': 'تحميل بياناتك الصحية', 'screen': const DownloadDataScreen()},
          {'icon': 'assets/images/services/health_tips.png', 'title': 'حجم الخط', 'subtitle': 'تغيير حجم الخط', 'screen': const FontSizeScreen()},
          {'icon': 'assets/images/services/wallet.png', 'title': 'الباقات', 'subtitle': 'عرض الباقات المتاحة', 'screen': const SubscriptionsScreen()},
        ];
      default:
        return [
          {'icon': 'assets/images/services/consultation.png', 'title': 'الأطباء', 'subtitle': 'استشر أفضل الأطباء', 'screen': const DoctorsListScreen()},
          {'icon': 'assets/images/services/pharmacy.png', 'title': 'الصيدلية', 'subtitle': 'طلب الأدوية وتوصيلها', 'screen': const PharmacyScreen()},
          {'icon': 'assets/images/services/laboratory.png', 'title': 'المختبرات', 'subtitle': 'حجز التحاليل والفحوصات', 'screen': const LabsListScreen()},
          {'icon': 'assets/images/services/emergency.png', 'title': 'الطوارئ', 'subtitle': 'أرقام الطوارئ والمساعدة', 'screen': const EmergencyNumbers()},
          {'icon': 'assets/images/services/consultation.png', 'title': 'استشارة فورية', 'subtitle': 'تحدث مع طبيبك الآن', 'screen': const ConsultationScreen()},
          {'icon': 'assets/images/services/health_tips.png', 'title': 'صحتك', 'subtitle': 'متابعة حالتك الصحية', 'screen': const HealthDashboard()},
          {'icon': 'assets/images/services/wallet.png', 'title': 'المحفظة', 'subtitle': 'إدارة محفظتك', 'screen': const WalletScreen()},
          {'icon': 'assets/images/services/calendar_booking.png', 'title': 'المواعيد', 'subtitle': 'إدارة مواعيدك', 'screen': const HealthDashboard()},
          {'icon': 'assets/images/services/map_location.png', 'title': 'الخريطة', 'subtitle': 'المنشآت الصحية القريبة', 'screen': const InteractiveMapScreen()},
          {'icon': 'assets/images/services/health_insurance.png', 'title': 'التأمين الصحي', 'subtitle': 'خطط التأمين والاشتراكات', 'screen': const InsuranceCompanies()},
          {'icon': 'assets/images/services/blood_donation.png', 'title': 'التبرع بالدم', 'subtitle': 'مراكز التبرع بالدم', 'screen': const BloodDonationScreen()},
          {'icon': 'assets/images/services/consultation.png', 'title': 'الملف الشخصي', 'subtitle': 'إدارة ملفك الشخصي', 'screen': const PatientProfile()},
          {'icon': 'assets/images/services/health_tips.png', 'title': 'الإعدادات', 'subtitle': 'إعدادات التطبيق', 'screen': const SettingsScreen()},
          {'icon': 'assets/images/services/medical_community.png', 'title': 'جميع الخدمات', 'subtitle': 'استعراض جميع الخدمات', 'screen': const SizedBox.shrink()},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _appBarOpacity = 1.0 - (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    });
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    setState(() => _isCheckingAdmin = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _isCheckingAdmin = false;
      });
      return;
    }

    if (_adminEmails.contains(user.email)) {
      setState(() {
        _isAdmin = true;
        _isCheckingAdmin = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_roles')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final role = data?['role'] ?? 'user';
        if (role == 'admin' || role == 'superAdmin') {
          setState(() {
            _isAdmin = true;
            _isCheckingAdmin = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error checking admin status: $e');
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final role = data?['role'] ?? 'user';
        if (role == 'admin' || role == 'superAdmin') {
          setState(() {
            _isAdmin = true;
            _isCheckingAdmin = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
    }

    setState(() {
      _isAdmin = false;
      _isCheckingAdmin = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ زر لوحة التحكم للمشرفين
  Widget _buildAdminButton() {
    if (_isCheckingAdmin) {
      return const SizedBox(
        height: 20,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!_isAdmin) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            color: AppColors.primary,
          ),
        ),
        title: const Text(
          '🛡️ لوحة تحكم المنصة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'إدارة المقدمين والإعلانات والحجوزات',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlatformDashboard(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final user = FirebaseAuth.instance.currentUser;
    final logged = user != null;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';
    final fontScale = context.watch<FontSizeProvider>().fontScale;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 100 * fontScale,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF5F7FA),
            foregroundColor: primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Opacity(
                opacity: _appBarOpacity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (logged) _navigateTo(const PatientProfile());
                          else _navigateTo(BlocProvider(create: (_) => AuthBloc(), child: const AuthScreen()));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: user?.photoURL ?? '',
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _shimmerPlaceholder(45, 45, 14 * fontScale),
                            errorWidget: (_, __, ___) => Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.person, color: primaryColor, size: 24),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * fontScale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              logged ? name : 'زائر',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              logged ? 'رقم الملف: #${user?.uid.substring(0, 8) ?? '00000000'}' : 'تسجيل الدخول للمزيد',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: primaryColor),
                        onPressed: () => _navigateTo(const SettingsScreen()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 8 * fontScale),
                _buildAISmartSuite(primaryColor, fontScale),
                SizedBox(height: 20 * fontScale),
                _sectionTitle('المؤشرات الحيوية', isDark, fontScale),
                SizedBox(height: 10 * fontScale),
                _buildVitalsGrid(fontScale),
                SizedBox(height: 20 * fontScale),
                _buildFilterChips(primaryColor, fontScale),
                SizedBox(height: 16),
                ..._filteredServices.map((service) => _buildServiceCard(service, isDark, primaryColor, fontScale)),
                SizedBox(height: 16),
                _buildAdminButton(),
                SizedBox(height: 16),
                _buildPremiumFooter(isDark, primaryColor, fontScale),
                SizedBox(height: 30 * fontScale),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerPlaceholder(double width, double height, double radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300!,
      highlightColor: Colors.grey.shade100!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark, double fontScale) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildAISmartSuite(Color primaryColor, double fontScale) {
    return Container(
      padding: EdgeInsets.all(20 * fontScale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20 * fontScale),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15 * fontScale,
            offset: Offset(0, 8 * fontScale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * fontScale, vertical: 6 * fontScale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 18 * fontScale),
                    SizedBox(width: 6 * fontScale),
                    Text(
                      'عيادة الذكاء الاصطناعي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * fontScale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.blur_on, color: Colors.white54, size: 20 * fontScale),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'هل تشعر بأي أعراض صحية حالياً؟',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * fontScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6 * fontScale),
          Text(
            'ابدأ فحصاً فورياً مدعوماً بالذكاء الاصطناعي لتحليل حالتك وتوجيهك للطبيب المناسب.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13 * fontScale,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48 * fontScale,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIChatbotScreen(),
                  ),
                );
              },
              child: Text(
                'ابدأ الفحص الذكي الآن',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * fontScale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ المؤشرات الحيوية - بحجم كبير مثل أفضل الأطباء
  Widget _buildVitalsGrid(double fontScale) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12 * fontScale,
        crossAxisSpacing: 12 * fontScale,
        childAspectRatio: 1.2,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        final color = vital['color'] as Color;
        final statusColor = vital['statusColor'] as Color;
        final screen = vital['screen'] as Widget;
        final iconPath = vital['icon'] as String;
        return GestureDetector(
          onTap: () => _navigateTo(screen),
          child: Container(
            padding: EdgeInsets.all(14 * fontScale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10 * fontScale,
                  offset: Offset(0, 4 * fontScale),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _buildIcon(iconPath, color, size: 28),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vital['status'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  vital['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      vital['value'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D5257),
                      ),
                    ),
                    if (vital['unit'] != null && (vital['unit'] as String).isNotEmpty)
                      Text(
                        ' ${vital['unit']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
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

  Widget _buildFilterChips(Color primaryColor, double fontScale) {
    return SizedBox(
      height: 40 * fontScale,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(
              right: index == 0 ? 0 : 8 * fontScale,
              left: index == _categories.length - 1 ? 0 : 0,
            ),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : primaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13 * fontScale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : primaryColor.withOpacity(0.2),
                ),
              ),
              elevation: 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark, Color primaryColor, double fontScale) {
    final screen = service['screen'] as Widget;
    final iconPath = service['icon'] as String;
    return Container(
      margin: EdgeInsets.only(bottom: 8 * fontScale),
      padding: EdgeInsets.all(12 * fontScale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4 * fontScale,
            offset: Offset(0, 2 * fontScale),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: EdgeInsets.all(10 * fontScale),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildIcon(iconPath, primaryColor, size: 28),
        ),
        title: Text(
          service['title'] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14 * fontScale,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          service['subtitle'] as String,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14 * fontScale,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
        ),
        onTap: () => _navigateTo(screen),
      ),
    );
  }

  Widget _buildPremiumFooter(bool isDark, Color primaryColor, double fontScale) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _showLogoutDialog();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12 * fontScale),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * fontScale,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12 * fontScale),
        Text(
          'صحتك - v1.0.0 (Build 240)',
          style: TextStyle(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            fontSize: 11,
          ),
        ),
        SizedBox(height: 8 * fontScale),
        Text(
          '© 2026 Sehatak Platform. All rights reserved.',
          style: TextStyle(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            fontSize: 10 * fontScale,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: Text(
              'إلغاء',
              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(_);
              FirebaseAuth.instance.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
