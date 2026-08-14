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
    {'title': 'عداد الخطوات', 'value': '5,230', 'unit': 'خطوة', 'icon': 'assets/images/tracking/fitness.png', 'color': Colors.orange, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'ضغط الدم', 'value': '120/80', 'unit': 'ملم زئبق', 'icon': 'assets/images/tracking/blood_pressure.png', 'color': Colors.red, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'معدل القلب', 'value': '72', 'unit': 'نبضة/د', 'icon': 'assets/images/tracking/blood_pressure.png', 'color': Colors.pink, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'نسبة السكر', 'value': '95', 'unit': 'مغ/دسل', 'icon': 'assets/images/tracking/blood_sugar.png', 'color': Colors.blue, 'status': 'مرتفع', 'statusColor': Colors.red},
  ];

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ✅ دالة عرض أيقونة PNG/URL بحجم أكبر وبألوانها الأصلية (إلغاء الـ tint)
  Widget _buildIcon(String iconPath, Color fallbackColor, {double size = 32}) {
    final actualSize = size * 1.25; // زيادة الحجم بنسبة 25%

    // إذا كان مسار الأيقونة رابط شبكي
    if (iconPath.startsWith('http') || iconPath.startsWith('https')) {
      return Image.network(
        iconPath,
        width: actualSize,
        height: actualSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: fallbackColor, size: actualSize),
      );
    }

    // افتراض أنه ملف محلي داخل assets — لا نمرر اللون لكي لا يتم تلطيخ الأيقونة
    return Image.asset(
      iconPath,
      width: actualSize,
      height: actualSize,
      fit: BoxFit.contain,
      // لا نستخدم color: ... لأن ذلك يغيّر لون الـ PNG ويمحو تفاصيلها
      errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: fallbackColor, size: actualSize),
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
    _scroll_controller.addListener(() {
      final maxScroll = _scroll_controller.position.maxScrollExtent;
      final currentScroll = _scroll_controller.position.pixels;
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

    setState(() {
      _isAdmin = _adminEmails.contains(user.email);
      _isCheckingAdmin = false;
    });
  }

  @override
  void dispose() {
    _scroll_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontSizeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('المزيد', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isCheckingAdmin)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ),
          if (_isAdmin && !_isCheckingAdmin)
            IconButton(onPressed: () => _navigateTo(const PlatformDashboard()), icon: const Icon(Icons.admin_panel_settings)),
        ],
      ),
      body: Column(
        children: [
          // الفئات
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : (isDark ? const Color(0xFF0B1121) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppColors.primary : Colors.transparent),
                    ),
                    child: Center(
                      child: Text(cat, style: TextStyle(color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87))),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              controller: _scroll_controller,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                // المؤشرات الحيوية
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _vitals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final v = _vitals[index];
                      return Container(
                        width: 220,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2540) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            _buildIcon(v['icon'] as String, v['color'] as Color, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(v['title'], style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                  const SizedBox(height: 6),
                                  Text('${v['value']} ${v['unit']}', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(v['status'], style: TextStyle(color: v['statusColor'] as Color, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // قائمة الخدمات
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _filteredServices.map((s) {
                    return GestureDetector(
                      onTap: () => _navigateTo(s['screen'] as Widget),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 18,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2540) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildIcon(s['icon'] as String, AppColors.primary, size: 48),
                            const SizedBox(height: 8),
                            Text(s['title'], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                            const SizedBox(height: 4),
                            Text(s['subtitle'], textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // إعدادات إضافية ومجموعات
                if (_isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('لوحة التحكم'),
                    onTap: () => _navigateTo(const PlatformDashboard()),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
