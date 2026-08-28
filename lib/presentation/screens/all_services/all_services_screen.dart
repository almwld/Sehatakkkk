import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/appointments/appointments_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_screen.dart';
import 'package:sehatak/presentation/screens/favorites/favorites_screen.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/video_consultation/video_consultation_screen.dart';
import 'package:sehatak/presentation/screens/packages/packages_screen.dart';
import 'package:sehatak/presentation/screens/family_planning/family_planning_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_screen.dart';
import 'package:sehatak/presentation/screens/diet_plan/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isGridView = true;

  final List<String> _categories = [
    'الكل',
    'الرعاية الصحية',
    'الأدوية والصيدلة',
    'التحاليل والمختبرات',
    'الطوارئ',
    'الاستشارات',
    'الخدمات المالية',
    'المواعيد',
    'الخرائط',
    'التأمين',
    'المجتمع',
    'التقارير',
  ];

  final List<Map<String, dynamic>> _allServices = [
    // ============================================================
    // 🏥 الرعاية الصحية
    // ============================================================
    {
      'id': 's1',
      'name': 'الأطباء',
      'icon': 'assets/images/services/consultation.png',
      'category': 'الرعاية الصحية',
      'description': 'استشر أفضل الأطباء في مختلف التخصصات',
      'screen': const DoctorsListScreen(),
      'color': Colors.blue,
      'popular': true,
    },
    {
      'id': 's2',
      'name': 'المستشفيات',
      'icon': 'assets/images/services/hospital.png',
      'category': 'الرعاية الصحية',
      'description': 'ابحث عن أقرب المستشفيات والمرافق الصحية',
      'screen': const HospitalScreen(),
      'color': Colors.red,
      'popular': true,
    },
    {
      'id': 's3',
      'name': 'صحتك',
      'icon': 'assets/images/services/health_tips.png',
      'category': 'الرعاية الصحية',
      'description': 'متابعة حالتك الصحية والإحصائيات',
      'screen': const HealthDashboard(),
      'color': Colors.green,
      'popular': true,
    },
    {
      'id': 's4',
      'name': 'المواعيد',
      'icon': 'assets/images/services/calendar_booking.png',
      'category': 'الرعاية الصحية',
      'description': 'إدارة وحجز المواعيد الطبية',
      'screen': const AppointmentsScreen(),
      'color': Colors.purple,
      'popular': true,
    },
    {
      'id': 's5',
      'name': 'المختبرات',
      'icon': 'assets/images/services/laboratory.png',
      'category': 'التحاليل والمختبرات',
      'description': 'حجز التحاليل والفحوصات المخبرية',
      'screen': const LabsListScreen(),
      'color': Colors.purple,
      'popular': true,
    },
    {
      'id': 's6',
      'name': 'التقارير الطبية',
      'icon': 'assets/images/services/medical_records.png',
      'category': 'الرعاية الصحية',
      'description': 'عرض وتحميل التقارير الطبية',
      'screen': const MedicalReportsScreen(),
      'color': Colors.indigo,
      'popular': false,
    },

    // ============================================================
    // 💊 الأدوية والصيدلة
    // ============================================================
    {
      'id': 's7',
      'name': 'الصيدلية',
      'icon': 'assets/images/services/pharmacy.png',
      'category': 'الأدوية والصيدلة',
      'description': 'طلب الأدوية وتوصيلها إلى منزلك',
      'screen': const PharmacyScreen(),
      'color': Colors.green,
      'popular': true,
    },
    {
      'id': 's8',
      'name': 'الأدوية',
      'icon': 'assets/images/services/medications.png',
      'category': 'الأدوية والصيدلة',
      'description': 'البحث عن الأدوية ومعلوماتها',
      'screen': const MedicinesScreen(),
      'color': Colors.teal,
      'popular': true,
    },
    {
      'id': 's9',
      'name': 'تذكير الأدوية',
      'icon': 'assets/images/services/first_aid.png',
      'category': 'الأدوية والصيدلة',
      'description': 'تذكير بمواعيد تناول الأدوية',
      'screen': const MedicationReminderScreen(),
      'color': Colors.orange,
      'popular': false,
    },

    // ============================================================
    // 🚨 الطوارئ
    // ============================================================
    {
      'id': 's10',
      'name': 'الطوارئ',
      'icon': 'assets/images/services/emergency.png',
      'category': 'الطوارئ',
      'description': 'أرقام الطوارئ والمساعدة الفورية',
      'screen': const EmergencyNumbers(),
      'color': Colors.red,
      'popular': true,
    },
    {
      'id': 's11',
      'name': 'الإسعافات الأولية',
      'icon': 'assets/images/services/first_aid.png',
      'category': 'الطوارئ',
      'description': 'دليل الإسعافات الأولية',
      'screen': const FirstAidScreen(),
      'color': Colors.orange,
      'popular': false,
    },

    // ============================================================
    // 💬 الاستشارات
    // ============================================================
    {
      'id': 's12',
      'name': 'استشارة فورية',
      'icon': 'assets/images/services/consultation.png',
      'category': 'الاستشارات',
      'description': 'تحدث مع طبيبك الآن',
      'screen': const ConsultationScreen(),
      'color': Colors.blue,
      'popular': true,
    },
    {
      'id': 's13',
      'name': 'استشارة فيديو',
      'icon': 'assets/images/services/video_consultation.png',
      'category': 'الاستشارات',
      'description': 'استشارة طبية عبر الفيديو',
      'screen': const VideoConsultationScreen(),
      'color': Colors.cyan,
      'popular': true,
    },
    {
      'id': 's14',
      'name': 'المساعد الذكي',
      'icon': 'assets/images/services/ai_assistant.png',
      'category': 'الاستشارات',
      'description': 'اسأل المساعد الطبي الذكي',
      'screen': const AiChatbotScreen(),
      'color': Colors.purple,
      'popular': true,
    },

    // ============================================================
    // 💰 الخدمات المالية
    // ============================================================
    {
      'id': 's15',
      'name': 'المحفظة',
      'icon': 'assets/images/services/wallet.png',
      'category': 'الخدمات المالية',
      'description': 'إدارة محفظتك المالية',
      'screen': const WalletScreen(),
      'color': Colors.amber,
      'popular': true,
    },
    {
      'id': 's16',
      'name': 'الباقات الصحية',
      'icon': 'assets/images/services/packages.png',
      'category': 'الخدمات المالية',
      'description': 'عرض الباقات والاشتراكات الصحية',
      'screen': const PackagesScreen(),
      'color': Colors.pink,
      'popular': false,
    },

    // ============================================================
    // 🗺️ الخرائط
    // ============================================================
    {
      'id': 's17',
      'name': 'الخريطة التفاعلية',
      'icon': 'assets/images/services/map_location.png',
      'category': 'الخرائط',
      'description': 'المنشآت الصحية القريبة منك',
      'screen': const InteractiveMapScreen(),
      'color': Colors.green,
      'popular': true,
    },
    {
      'id': 's18',
      'name': 'بالقرب منك',
      'icon': 'assets/images/services/map_location.png',
      'category': 'الخرائط',
      'description': 'الخدمات الصحية القريبة من موقعك',
      'screen': const InteractiveMapScreen(),
      'color': Colors.teal,
      'popular': false,
    },

    // ============================================================
    // 🛡️ التأمين
    // ============================================================
    {
      'id': 's19',
      'name': 'التأمين الصحي',
      'icon': 'assets/images/services/health_insurance.png',
      'category': 'التأمين',
      'description': 'خطط التأمين الصحي والاشتراكات',
      'screen': const InsuranceCompanies(),
      'color': Colors.blue,
      'popular': false,
    },

    // ============================================================
    // 👥 المجتمع
    // ============================================================
    {
      'id': 's20',
      'name': 'المجتمع الطبي',
      'icon': 'assets/images/services/medical_community.png',
      'category': 'المجتمع',
      'description': 'تواصل مع المجتمع الطبي',
      'screen': const HealthCommunityScreen(),
      'color': Colors.purple,
      'popular': false,
    },
    {
      'id': 's21',
      'name': 'المقالات الطبية',
      'icon': 'assets/images/services/medical_articles.png',
      'category': 'المجتمع',
      'description': 'أحدث المقالات الطبية',
      'screen': const ArticlesScreen(),
      'color': Colors.blue,
      'popular': true,
    },

    // ============================================================
    // 🩺 أدوات صحية
    // ============================================================
    {
      'id': 's22',
      'name': 'ضغط الدم',
      'icon': 'assets/images/tracking/blood_pressure.png',
      'category': 'الرعاية الصحية',
      'description': 'متابعة ضغط الدم',
      'screen': const BloodPressureScreen(),
      'color': Colors.red,
      'popular': false,
    },
    {
      'id': 's23',
      'name': 'سكر الدم',
      'icon': 'assets/images/tracking/blood_sugar.png',
      'category': 'الرعاية الصحية',
      'description': 'مراقبة مستوى السكر في الدم',
      'screen': const GlucoseTrackerScreen(),
      'color': Colors.orange,
      'popular': false,
    },
    {
      'id': 's24',
      'name': 'الوزن',
      'icon': 'assets/images/tracking/weight_tracking.png',
      'category': 'الرعاية الصحية',
      'description': 'تتبع الوزن واللياقة البدنية',
      'screen': const WeightTrackerScreen(),
      'color': Colors.purple,
      'popular': false,
    },
    {
      'id': 's25',
      'name': 'النوم',
      'icon': 'assets/images/tracking/sleep_tracking.png',
      'category': 'الرعاية الصحية',
      'description': 'تتبع جودة النوم',
      'color': Colors.indigo,
      'popular': false,
    },
    {
      'id': 's26',
      'name': 'التبرع بالدم',
      'icon': 'assets/images/services/blood_donation.png',
      'category': 'الرعاية الصحية',
      'description': 'مراكز التبرع بالدم',
      'screen': const BloodDonationScreen(),
      'color': Colors.red,
      'popular': false,
    },

    // ============================================================
    // 👨‍👩‍👧‍👦 رعاية عائلية
    // ============================================================
    {
      'id': 's27',
      'name': 'صحة المرأة',
      'icon': 'assets/images/services/womens_health.png',
      'category': 'الرعاية الصحية',
      'description': 'متابعة صحة المرأة',
      'screen': const FamilyPlanningScreen(),
      'color': Colors.pink,
      'popular': false,
    },
    {
      'id': 's28',
      'name': 'الصحة النفسية',
      'icon': 'assets/images/tracking/mental_health.png',
      'category': 'الرعاية الصحية',
      'description': 'دعم الصحة النفسية',
      'screen': const MentalHealthScreen(),
      'color': Colors.purple,
      'popular': false,
    },
    {
      'id': 's29',
      'name': 'النظام الغذائي',
      'icon': 'assets/images/tracking/fruits.png',
      'category': 'الرعاية الصحية',
      'description': 'خطط غذائية صحية',
      'screen': const DietPlanScreen(),
      'color': Colors.green,
      'popular': false,
    },

    // ============================================================
    // ⚙️ إعدادات
    // ============================================================
    {
      'id': 's30',
      'name': 'الملف الشخصي',
      'icon': 'assets/images/ui/user_profile.png',
      'category': 'الرعاية الصحية',
      'description': 'إدارة ملفك الشخصي',
      'screen': const PatientProfile(),
      'color': Colors.blue,
      'popular': false,
    },
    {
      'id': 's31',
      'name': 'الإشعارات',
      'icon': 'assets/images/services/notifications.png',
      'category': 'الرعاية الصحية',
      'description': 'إدارة الإشعارات',
      'screen': const NotificationsScreen(),
      'color': Colors.orange,
      'popular': false,
    },
    {
      'id': 's32',
      'name': 'جميع الخدمات',
      'icon': 'assets/images/ui/all_services.png',
      'category': 'الرعاية الصحية',
      'description': 'استعراض جميع الخدمات',
      'screen': const ServicesScreen(),
      'color': AppColors.primary,
      'popular': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    var services = _allServices;
    
    // فلتر حسب الفئة
    if (_selectedCategory != 'الكل') {
      services = services.where((s) => s['category'] == _selectedCategory).toList();
    }
    
    // فلتر حسب البحث
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      services = services.where((s) {
        final name = (s['name'] as String).toLowerCase();
        final description = (s['description'] as String).toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }
    
    return services;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final services = _filteredServices;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('جميع الخدمات'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(isDark),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'عرض كقائمة' : 'عرض كشبكة',
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط الفلاتر
          _buildCategoriesBar(isDark),
          // ✅ عرض الخدمات
          Expanded(
            child: services.isEmpty
                ? _buildEmptyState(isDark)
                : _isGridView
                    ? _buildGridView(services, isDark)
                    : _buildListView(services, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'ابحث عن خدمة...',
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                size: 18,
              ),
              onPressed: () => setState(() => _searchQuery = ''),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar(bool isDark) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? const Color(0xFF1A2540)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
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

  Widget _buildGridView(List<Map<String, dynamic>> services, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(service, isDark);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> services, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceListItem(service, isDark);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark) {
    final color = service['color'] as Color;
    final isPopular = service['popular'] as bool? ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => service['screen'] as Widget),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ أيقونة الخدمة
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(
                  service['icon'] as String,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.circle,
                    color: color,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ✅ اسم الخدمة
            Text(
              service['name'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // ✅ الوصف
            Text(
              service['description'] as String,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // ✅ شارة "الأكثر طلباً"
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'الأكثر طلباً',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceListItem(Map<String, dynamic> service, bool isDark) {
    final color = service['color'] as Color;
    final isPopular = service['popular'] as bool? ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => service['screen'] as Widget),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ✅ أيقونة الخدمة
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  service['icon'] as String,
                  width: 28,
                  height: 28,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.circle,
                    color: color,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service['name'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 10, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                'شائع',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service['description'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service['category'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على خدمات تطابق بحثك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'الكل';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة تعيين الفلتر'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
