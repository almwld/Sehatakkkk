import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
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
import 'package:sehatak/presentation/screens/report_issue/report_issue_screen.dart';
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

class _MoreScreenState extends State<MoreScreen> {
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

  // ✅ بيانات المؤشرات الحيوية
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
      'icon': 'assets/images/tracking/fitness.png',
      'label': 'اللياقة',
      'value': '85',
      'unit': '%',
      'color': Colors.green,
      'screen': const SleepTrackerScreen()
    },
    {
      'icon': 'assets/images/tracking/weight_tracking.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.purple,
      'screen': const WeightTrackerScreen()
    },
  ];

  // ✅ الخدمات المفلترة
  List<Map<String, dynamic>> get _filteredServices {
    switch (_selectedCategory) {
      case 'رعاية عائلية':
        return [
          {'icon': Icons.woman, 'title': 'صحة المرأة', 'subtitle': 'متابعة الدورة والحمل', 'screen': const FamilyPlanningScreen()},
          {'icon': Icons.child_care, 'title': 'نمو الطفل', 'subtitle': 'مراحل التطور', 'screen': const FamilyPlanningScreen()},
          {'icon': Icons.house_rounded, 'title': 'طبيب العائلة', 'subtitle': 'رعاية منزلية متكاملة', 'screen': const DoctorsListScreen()},
          {'icon': Icons.pregnant_woman, 'title': 'متابعة الحمل', 'subtitle': 'أسابيع الحمل بدقة', 'screen': const FamilyPlanningScreen()},
          {'icon': Icons.health_and_safety, 'title': 'الصحة النفسية', 'subtitle': 'دعم الصحة النفسية', 'screen': const MentalHealthScreen()},
          {'icon': Icons.restaurant, 'title': 'نظام غذائي', 'subtitle': 'خطط غذائية صحية', 'screen': const DietPlanScreen()},
          {'icon': Icons.nightlight, 'title': 'تتبع النوم', 'subtitle': 'مراقبة جودة النوم', 'screen': const SleepTrackerScreen()},
        ];
      case 'أدوات تشخيصية':
        return [
          {'icon': Icons.monitor_heart, 'title': 'ضغط الدم', 'subtitle': 'متابعة ضغط الدم', 'screen': const BloodPressureScreen()},
          {'icon': Icons.biotech, 'title': 'تتبع السكر', 'subtitle': 'مراقبة مستوى السكر', 'screen': const GlucoseTrackerScreen()},
          {'icon': Icons.monitor_weight, 'title': 'الوزن', 'subtitle': 'تتبع الوزن واللياقة', 'screen': const WeightTrackerScreen()},
          {'icon': Icons.medication, 'title': 'تذكير الأدوية', 'subtitle': 'تذكير بمواعيد الأدوية', 'screen': const MedicationReminderScreen()},
          {'icon': Icons.bloodtype, 'title': 'التبرع بالدم', 'subtitle': 'مراكز التبرع بالدم', 'screen': const BloodDonationScreen()},
          {'icon': Icons.article, 'title': 'المقالات الطبية', 'subtitle': 'أحدث المقالات الطبية', 'screen': const ArticlesScreen()},
          {'icon': Icons.emergency, 'title': 'الإسعافات الأولية', 'subtitle': 'دليل الإسعافات الأولية', 'screen': const FirstAidScreen()},
          {'icon': Icons.medical_services, 'title': 'التقارير الطبية', 'subtitle': 'عرض التقارير الطبية', 'screen': const MedicalReportsScreen()},
        ];
      case 'لوجستيات وتأمين':
        return [
          {'icon': Icons.local_pharmacy, 'title': 'صيدلية', 'subtitle': 'طلب الأدوية وتوصيلها', 'screen': const PharmacyScreen()},
          {'icon': Icons.science, 'title': 'مختبرات', 'subtitle': 'حجز التحاليل والفحوصات', 'screen': const LabsListScreen()},
          {'icon': Icons.shield, 'title': 'تأمين صحي', 'subtitle': 'خطط التأمين والاشتراك', 'screen': const InsuranceCompanies()},
          {'icon': Icons.map, 'title': 'خرائط المرافق', 'subtitle': 'أقرب المستشفيات والصيدليات', 'screen': const InteractiveMapScreen()},
          {'icon': Icons.local_hospital, 'title': 'المستشفيات', 'subtitle': 'أقرب المستشفيات', 'screen': const InteractiveMapScreen()},
          {'icon': Icons.wallet, 'title': 'المحفظة', 'subtitle': 'إدارة محفظتك', 'screen': const WalletScreen()},
          {'icon': Icons.subscriptions, 'title': 'الباقات', 'subtitle': 'عرض الباقات المتاحة', 'screen': const SubscriptionsScreen()},
        ];
      case 'إعدادات':
        return [
          {'icon': Icons.person, 'title': 'الملف الشخصي', 'subtitle': 'إدارة ملفك الشخصي', 'screen': const PatientProfile()},
          {'icon': Icons.settings, 'title': 'الإعدادات', 'subtitle': 'إعدادات التطبيق', 'screen': const SettingsScreen()},
          {'icon': Icons.notifications, 'title': 'الإشعارات', 'subtitle': 'إدارة الإشعارات', 'screen': const NotificationsScreen()},
          {'icon': Icons.privacy_tip, 'title': 'الخصوصية', 'subtitle': 'إعدادات الخصوصية', 'screen': const PrivacyScreen()},
          {'icon': Icons.assignment, 'title': 'الشروط والأحكام', 'subtitle': 'عرض الشروط والأحكام', 'screen': const TermsScreen()},
          {'icon': Icons.info, 'title': 'عن التطبيق', 'subtitle': 'معلومات عن التطبيق', 'screen': const AboutScreen()},
          {'icon': Icons.help, 'title': 'مركز المساعدة', 'subtitle': 'الأسئلة الشائعة والدعم', 'screen': const HelpCenterScreen()},
          {'icon': Icons.contact_support, 'title': 'اتصل بنا', 'subtitle': 'تواصل مع فريق الدعم', 'screen': const ContactUsScreen()},
          {'icon': Icons.share, 'title': 'مشاركة التطبيق', 'subtitle': 'شارك التطبيق مع أصدقائك', 'screen': const ShareAppScreen()},
          {'icon': Icons.star, 'title': 'تقييم التطبيق', 'subtitle': 'قيم التطبيق', 'screen': const RateAppScreen()},
          {'icon': Icons.report, 'title': 'الإبلاغ عن مشكلة', 'subtitle': 'أبلغ عن مشكلة', 'screen': const ReportIssueScreen()},
          {'icon': Icons.download, 'title': 'تحميل البيانات', 'subtitle': 'تحميل بياناتك الصحية', 'screen': const DownloadDataScreen()},
          {'icon': Icons.text_fields, 'title': 'حجم الخط', 'subtitle': 'تغيير حجم الخط', 'screen': const FontSizeScreen()},
        ];
      default:
        return [
          {'icon': Icons.medical_services, 'title': 'الأطباء', 'subtitle': 'استشر أفضل الأطباء', 'screen': const DoctorsListScreen()},
          {'icon': Icons.local_pharmacy, 'title': 'الصيدلية', 'subtitle': 'طلب الأدوية وتوصيلها', 'screen': const PharmacyScreen()},
          {'icon': Icons.science, 'title': 'المختبرات', 'subtitle': 'حجز التحاليل والفحوصات', 'screen': const LabsListScreen()},
          {'icon': Icons.emergency, 'title': 'الطوارئ', 'subtitle': 'أرقام الطوارئ والمساعدة', 'screen': const EmergencyNumbers()},
          {'icon': Icons.chat, 'title': 'استشارة فورية', 'subtitle': 'تحدث مع طبيبك الآن', 'screen': const ConsultationScreen()},
          {'icon': Icons.favorite, 'title': 'صحتك', 'subtitle': 'متابعة حالتك الصحية', 'screen': const HealthDashboard()},
          {'icon': Icons.wallet, 'title': 'المحفظة', 'subtitle': 'إدارة محفظتك', 'screen': const WalletScreen()},
          {'icon': Icons.calendar_month, 'title': 'المواعيد', 'subtitle': 'إدارة مواعيدك', 'screen': const AppointmentsScreen()},
          {'icon': Icons.map, 'title': 'الخريطة', 'subtitle': 'المنشآت الصحية القريبة', 'screen': const InteractiveMapScreen()},
          {'icon': Icons.shield, 'title': 'التأمين الصحي', 'subtitle': 'خطط التأمين والاشتراكات', 'screen': const InsuranceCompanies()},
          {'icon': Icons.bloodtype, 'title': 'التبرع بالدم', 'subtitle': 'مراكز التبرع بالدم', 'screen': const BloodDonationScreen()},
          {'icon': Icons.person, 'title': 'الملف الشخصي', 'subtitle': 'إدارة ملفك الشخصي', 'screen': const PatientProfile()},
          {'icon': Icons.settings, 'title': 'الإعدادات', 'subtitle': 'إعدادات التطبيق', 'screen': const SettingsScreen()},
          {'icon': Icons.grid_view, 'title': 'جميع الخدمات', 'subtitle': 'استعراض جميع الخدمات', 'screen': const ServicesScreen()},
          {'icon': Icons.smart_toy, 'title': 'المساعد الذكي', 'subtitle': 'اسأل المساعد الطبي', 'screen': const AiChatbotScreen()},
          {'icon': Icons.health_and_safety, 'title': 'المجتمع الطبي', 'subtitle': 'تواصل مع المجتمع', 'screen': const HealthCommunityScreen()},
          {'icon': Icons.woman, 'title': 'صحة المرأة', 'subtitle': 'متابعة الدورة والحمل', 'screen': const FamilyPlanningScreen()},
          {'icon': Icons.child_care, 'title': 'نمو الطفل', 'subtitle': 'مراحل التطور', 'screen': const FamilyPlanningScreen()},
          {'icon': Icons.health_and_safety, 'title': 'الصحة النفسية', 'subtitle': 'دعم الصحة النفسية', 'screen': const MentalHealthScreen()},
          {'icon': Icons.restaurant, 'title': 'نظام غذائي', 'subtitle': 'خطط غذائية صحية', 'screen': const DietPlanScreen()},
          {'icon': Icons.nightlight, 'title': 'تتبع النوم', 'subtitle': 'مراقبة جودة النوم', 'screen': const SleepTrackerScreen()},
          {'icon': Icons.medication, 'title': 'تذكير الأدوية', 'subtitle': 'تذكير بمواعيد الأدوية', 'screen': const MedicationReminderScreen()},
          {'icon': Icons.article, 'title': 'المقالات الطبية', 'subtitle': 'أحدث المقالات الطبية', 'screen': const ArticlesScreen()},
          {'icon': Icons.emergency, 'title': 'الإسعافات الأولية', 'subtitle': 'دليل الإسعافات الأولية', 'screen': const FirstAidScreen()},
          {'icon': Icons.medical_services, 'title': 'التقارير الطبية', 'subtitle': 'عرض التقارير الطبية', 'screen': const MedicalReportsScreen()},
          {'icon': Icons.subscriptions, 'title': 'الباقات', 'subtitle': 'عرض الباقات المتاحة', 'screen': const SubscriptionsScreen()},
        ];
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.position.pixels > 20;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.logout, color: Colors.red),
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
            const SizedBox(height: 16),
            Text(
              'المؤشرات الحيوية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildVitalsGrid(isDark),
            const SizedBox(height: 16),
            Text(
              'الخدمات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildCategoriesBar(isDark),
            const SizedBox(height: 12),
            _buildFilteredServicesGrid(isDark),
            const SizedBox(height: 16),
            _buildLogoutButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User? user, bool isDark) {
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
            radius: 32,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              user?.displayName?.substring(0, 1) ?? 'م',
              style: TextStyle(
                fontSize: 24,
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
                  user?.displayName ?? 'مستخدم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'user@email.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary),
            onPressed: () {
              _navigateTo(const PatientProfile());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar(bool isDark) {
    return SizedBox(
      height: 45,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
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

  Widget _buildVitalsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        return GestureDetector(
          onTap: () {
            final screen = vital['screen'] as Widget;
            _navigateTo(screen);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  vital['icon'] as String,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.circle,
                      color: vital['color'] as Color,
                      size: 40,
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  vital['value'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  vital['unit'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vital['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () {
            final screen = service['screen'] as Widget;
            _navigateTo(screen);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 6),
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
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
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
