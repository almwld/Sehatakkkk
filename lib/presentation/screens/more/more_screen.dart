import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/about/about_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/appointments/appointments_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/sleep_tracker/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';
import 'package:sehatak/presentation/screens/diet_plan/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/family_planning/family_planning_screen.dart';
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/help_center/help_center_screen.dart';
import 'package:sehatak/presentation/screens/contact_us/contact_us_screen.dart';
import 'package:sehatak/presentation/screens/share_app/share_app_screen.dart';
import 'package:sehatak/presentation/screens/rate_app/rate_app_screen.dart';
import 'package:sehatak/presentation/screens/download_data/download_data_screen.dart';
import 'package:sehatak/presentation/screens/font_size/font_size_screen.dart';
import 'package:sehatak/presentation/screens/privacy/privacy_screen.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  late ScrollController _scrollController;
  bool _isScrolled = false;
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'رعاية عائلية',
    'أدوات تشخيصية',
    'لوجستيات وتأمين',
    'إعدادات',
  ];

  final List<Map<String, dynamic>> _vitals = [
    {
      'icon': 'assets/images/tracking/blood_pressure.png',
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.blue,
      'screen': const BloodPressureScreen()
    },
    {
      'icon': 'assets/images/tracking/blood_sugar.png',
      'label': 'سكر الدم',
      'value': '98',
      'unit': 'مجم/دل',
      'color': Colors.orange,
      'screen': const GlucoseTrackerScreen()
    },
    {
      'icon': 'assets/images/tracking/walking.png',
      'label': 'اللياقة',
      'value': '85',
      'unit': '%',
      'color': Colors.green,
      'screen': const SleepTrackerScreen()
    },
    {
      'icon': 'assets/images/tracking/weight.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.purple,
      'screen': const WeightTrackerScreen()
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    switch (_selectedCategory) {
      case 'رعاية عائلية':
        return [
          {'icon': 'assets/images/services/womens_health.png', 'title': 'صحة المرأة', 'subtitle': 'متابعة الدورة والحمل', 'screen': const FamilyPlanningScreen()},
          {'icon': 'assets/images/services/medical_articles.png', 'title': 'نمو الطفل', 'subtitle': 'مراحل التطور', 'screen': const FamilyPlanningScreen()},
          {'icon': 'assets/images/services/hospital.png', 'title': 'طبيب العائلة', 'subtitle': 'رعاية منزلية متكاملة', 'screen': const DoctorsListScreen()},
          {'icon': 'assets/images/services/womens_health.png', 'title': 'متابعة الحمل', 'subtitle': 'أسابيع الحمل بدقة', 'screen': const FamilyPlanningScreen()},
          {'icon': 'assets/images/tracking/age.png', 'title': 'الصحة النفسية', 'subtitle': 'دعم الصحة النفسية', 'screen': const MentalHealthScreen()},
          {'icon': 'assets/images/tracking/fruits.png', 'title': 'نظام غذائي', 'subtitle': 'خطط غذائية صحية', 'screen': const DietPlanScreen()},
          {'icon': 'assets/images/tracking/sleep_tracking.png', 'title': 'تتبع النوم', 'subtitle': 'مراقبة جودة النوم', 'screen': const SleepTrackerScreen()},
        ];
      case 'أدوات تشخيصية':
        return [
          {'icon': 'assets/images/tracking/blood_pressure.png', 'title': 'ضغط الدم', 'subtitle': 'متابعة ضغط الدم', 'screen': const BloodPressureScreen()},
          {'icon': 'assets/images/tracking/blood_sugar.png', 'title': 'تتبع السكر', 'subtitle': 'مراقبة مستوى السكر', 'screen': const GlucoseTrackerScreen()},
          {'icon': 'assets/images/tracking/weight.png', 'title': 'الوزن', 'subtitle': 'تتبع الوزن واللياقة', 'screen': const WeightTrackerScreen()},
          {'icon': 'assets/images/services/first_aid.png', 'title': 'تذكير الأدوية', 'subtitle': 'تذكير بمواعيد الأدوية', 'screen': const MedicationReminderScreen()},
          {'icon': 'assets/images/services/blood_donation.png', 'title': 'التبرع بالدم', 'subtitle': 'مراكز التبرع بالدم', 'screen': const BloodDonationScreen()},
          {'icon': 'assets/images/services/medical_articles.png', 'title': 'المقالات الطبية', 'subtitle': 'أحدث المقالات الطبية', 'screen': const ArticlesScreen()},
          {'icon': 'assets/images/services/first_aid.png', 'title': 'الإسعافات الأولية', 'subtitle': 'دليل الإسعافات الأولية', 'screen': const FirstAidScreen()},
        ];
      case 'لوجستيات وتأمين':
        return [
          {'icon': 'assets/images/services/pharmacy.png', 'title': 'صيدلية', 'subtitle': 'طلب الأدوية وتوصيلها', 'screen': const PharmacyScreen()},
          {'icon': 'assets/images/services/laboratory.png', 'title': 'مختبرات', 'subtitle': 'حجز التحاليل والفحوصات', 'screen': const LabsListScreen()},
          {'icon': 'assets/images/services/packages.png', 'title': 'تأمين صحي', 'subtitle': 'خطط التأمين والاشتراك', 'screen': const InsuranceCompanies()},
          {'icon': 'assets/images/services/hospital.png', 'title': 'خرائط المرافق', 'subtitle': 'أقرب المستشفيات والصيدليات', 'screen': const InteractiveMapScreen()},
          {'icon': 'assets/images/services/hospital.png', 'title': 'المستشفيات', 'subtitle': 'أقرب المستشفيات', 'screen': const InteractiveMapScreen()},
          {'icon': 'assets/images/services/packages.png', 'title': 'المحفظة', 'subtitle': 'إدارة محفظتك', 'screen': const WalletScreen()},
          {'icon': 'assets/images/services/packages.png', 'title': 'الباقات', 'subtitle': 'عرض الباقات المتاحة', 'screen': const SubscriptionsScreen()},
        ];
      case 'إعدادات':
        return [
          {'icon': 'assets/images/ui/user_profile.png', 'title': 'الملف الشخصي', 'subtitle': 'إدارة ملفك الشخصي', 'screen': const PatientProfile()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'الإعدادات', 'subtitle': 'إعدادات التطبيق', 'screen': const SettingsScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'الإشعارات', 'subtitle': 'إدارة الإشعارات', 'screen': const NotificationsScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'الخصوصية', 'subtitle': 'إعدادات الخصوصية', 'screen': const PrivacyScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'الشروط والأحكام', 'subtitle': 'عرض الشروط والأحكام', 'screen': const TermsScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'عن التطبيق', 'subtitle': 'معلومات عن التطبيق', 'screen': const AboutScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'مركز المساعدة', 'subtitle': 'الأسئلة الشائعة والدعم', 'screen': const HelpCenterScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'اتصل بنا', 'subtitle': 'تواصل مع فريق الدعم', 'screen': const ContactUsScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'مشاركة التطبيق', 'subtitle': 'شارك التطبيق مع أصدقائك', 'screen': const ShareAppScreen()},
          {'icon': 'assets/images/ui/like_button.png', 'title': 'تقييم التطبيق', 'subtitle': 'قيم التطبيق', 'screen': const RateAppScreen()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'الإبلاغ عن مشكلة', 'subtitle': 'أبلغ عن مشكلة', 'screen': const Placeholder()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'تحميل البيانات', 'subtitle': 'تحميل بياناتك الصحية', 'screen': const DownloadDataScreen()},
          {'icon': 'assets/images/ui/edit_button.png', 'title': 'حجم الخط', 'subtitle': 'تغيير حجم الخط', 'screen': const FontSizeScreen()},
        ];
      default:
        return [
          {'icon': 'assets/images/services/hospital.png', 'title': 'الأطباء', 'subtitle': 'استشر أفضل الأطباء', 'screen': const DoctorsListScreen()},
          {'icon': 'assets/images/services/pharmacy.png', 'title': 'الصيدلية', 'subtitle': 'طلب الأدوية وتوصيلها', 'screen': const PharmacyScreen()},
          {'icon': 'assets/images/services/laboratory.png', 'title': 'المختبرات', 'subtitle': 'حجز التحاليل والفحوصات', 'screen': const LabsListScreen()},
          {'icon': 'assets/images/services/first_aid.png', 'title': 'الطوارئ', 'subtitle': 'أرقام الطوارئ والمساعدة', 'screen': const EmergencyNumbers()},
          {'icon': 'assets/images/services/womens_health.png', 'title': 'استشارة فورية', 'subtitle': 'تحدث مع طبيبك الآن', 'screen': const ConsultationScreen()},
          {'icon': 'assets/images/services/medical_articles.png', 'title': 'صحتك', 'subtitle': 'متابعة حالتك الصحية', 'screen': const HealthDashboard()},
          {'icon': 'assets/images/services/packages.png', 'title': 'المحفظة', 'subtitle': 'إدارة محفظتك', 'screen': const WalletScreen()},
          {'icon': 'assets/images/services/medical_articles.png', 'title': 'المواعيد', 'subtitle': 'إدارة مواعيدك', 'screen': const AppointmentsScreen()},
          {'icon': 'assets/images/services/hospital.png', 'title': 'الخريطة', 'subtitle': 'المنشآت الصحية القريبة', 'screen': const InteractiveMapScreen()},
          {'icon': 'assets/images/services/packages.png', 'title': 'التأمين الصحي', 'subtitle': 'خطط التأمين والاشتراكات', 'screen': const InsuranceCompanies()},
          {'icon': 'assets/images/services/blood_donation.png', 'title': 'التبرع بالدم', 'subtitle': 'مراكز التبرع بالدم', 'screen': const BloodDonationScreen()},
          {'icon': 'assets/images/ui/user_profile.png', 'title': 'الملف الشخصي', 'subtitle': 'إدارة ملفك الشخصي', 'screen': const PatientProfile()},
          {'icon': 'assets/images/ui/settings_gear.png', 'title': 'الإعدادات', 'subtitle': 'إعدادات التطبيق', 'screen': const SettingsScreen()},
          {'icon': 'assets/images/services/medical_articles.png', 'title': 'جميع الخدمات', 'subtitle': 'استعراض جميع الخدمات', 'screen': const ServicesScreen()},
          {'icon': 'assets/images/services/medical_articles.png', 'title': 'المساعد الذكي', 'subtitle': 'اسأل المساعد الطبي', 'screen': const AiChatbotScreen()},
          {'icon': 'assets/images/services/blood_donation.png', 'title': 'المجتمع الطبي', 'subtitle': 'تواصل مع المجتمع', 'screen': const HealthCommunityScreen()},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _isScrolled = _scrollController.position.pixels > 20;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildIcon(String path, {double size = 40}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: AppColors.primary, size: size);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'المزيد',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: _isScrolled ? 1 : 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserCard(user, isDark),
            const SizedBox(height: 20),
            Text(
              'المؤشرات الحيوية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildVitalsGrid(isDark),
            const SizedBox(height: 24),
            Text(
              'الخدمات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoriesBar(isDark),
            const SizedBox(height: 16),
            _buildFilteredServicesGrid(isDark),
            const SizedBox(height: 24),
            _buildLogoutButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User? user, bool isDark) {
    final displayName = user?.displayName ?? 'مستخدم';
    final email = user?.email ?? 'user@email.com';
    final initial = displayName.isNotEmpty ? displayName.substring(0, 1) : 'م';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary, size: 22),
            onPressed: () => _navigateTo(const PatientProfile()),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        return GestureDetector(
          onTap: () => _navigateTo(vital['screen'] as Widget),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(vital['icon'] as String, size: 50),
                const SizedBox(height: 4),
                Text(
                  vital['value'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  vital['unit'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  vital['label'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesBar(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilteredServicesGrid(bool isDark) {
    final services = _filteredServices;

    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'لا توجد خدمات في هذا القسم',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () => _navigateTo(service['screen'] as Widget),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(service['icon'] as String, size: 40),
                const SizedBox(height: 4),
                Text(
                  service['title'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  service['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }
}
