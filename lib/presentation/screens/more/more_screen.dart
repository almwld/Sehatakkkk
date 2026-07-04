import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_icons.dart';
import 'package:sehatak/presentation/widgets/service_icon_widget.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_prescriptions.dart';
import 'package:sehatak/presentation/screens/patient/patient_medical_history.dart';
import 'package:sehatak/presentation/screens/reports/reports_dashboard.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/services/services_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/ai/symptom_checker_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'رعاية عائلية',
    'أدوات تشخيصية',
    'لوجستيات',
  ];

  // ✅ قائمة الخدمات المصنفة
  final List<Map<String, dynamic>> _services = [
    // 📋 الملف الشخصي
    {
      'id': 'profile',
      'title': 'الملف الشخصي',
      'icon': AppIcons.doctor,
      'category': 'الكل',
      'screen': const PatientProfile(),
    },
    {
      'id': 'appointments',
      'title': 'مواعيدي',
      'icon': AppIcons.navHealthRecord,
      'category': 'الكل',
      'screen': const PatientAppointments(),
    },
    {
      'id': 'prescriptions',
      'title': 'الوصفات الطبية',
      'icon': AppIcons.pharmacy,
      'category': 'الكل',
      'screen': const PatientPrescriptions(),
    },
    {
      'id': 'medical_history',
      'title': 'السجل الطبي',
      'icon': AppIcons.healthRecord,
      'category': 'الكل',
      'screen': const PatientMedicalHistory(),
    },

    // 💰 المالية
    {
      'id': 'wallet',
      'title': 'محفظتي',
      'icon': AppIcons.paymentJawali,
      'category': 'الكل',
      'screen': const WalletScreen(),
    },
    {
      'id': 'reports',
      'title': 'التقارير',
      'icon': AppIcons.labBlood,
      'category': 'الكل',
      'screen': const ReportsDashboard(),
    },

    // 👨‍👩‍👧‍👦 رعاية عائلية
    {
      'id': 'family_doctor',
      'title': 'طبيب العائلة',
      'icon': AppIcons.specialtyPediatrics,
      'category': 'رعاية عائلية',
      'screen': const ConsultationScreen(),
    },
    {
      'id': 'child_growth',
      'title': 'نمو الطفل',
      'icon': AppIcons.specialtyPediatric,
      'category': 'رعاية عائلية',
      'screen': const HealthDashboard(),
    },
    {
      'id': 'family_planning',
      'title': 'تنظيم الأسرة',
      'icon': AppIcons.specialtyDentistry,
      'category': 'رعاية عائلية',
      'screen': const HealthCommunityScreen(),
    },
    {
      'id': 'home_care',
      'title': 'رعاية منزلية',
      'icon': AppIcons.consultationHomeVisit,
      'category': 'رعاية عائلية',
      'screen': const ServicesScreen(),
    },

    // 🩺 أدوات تشخيصية
    {
      'id': 'symptom_checker',
      'title': 'فحص الأعراض',
      'icon': AppIcons.specialtyBrain,
      'category': 'أدوات تشخيصية',
      'screen': const SymptomCheckerScreen(),
    },
    {
      'id': 'stress_meter',
      'title': 'مقياس التوتر',
      'icon': AppIcons.specialtyHeart,
      'category': 'أدوات تشخيصية',
      'screen': const HealthDashboard(),
    },
    {
      'id': 'risk_calculator',
      'title': 'حاسبة المخاطر',
      'icon': AppIcons.specialtyDna,
      'category': 'أدوات تشخيصية',
      'screen': const HealthDashboard(),
    },

    // 🏥 لوجستيات
    {
      'id': 'labs',
      'title': 'المختبرات',
      'icon': AppIcons.labBlood,
      'category': 'لوجستيات',
      'screen': const LabsListScreen(),
    },
    {
      'id': 'insurance',
      'title': 'التأمين الصحي',
      'icon': AppIcons.planGold,
      'category': 'لوجستيات',
      'screen': const InsuranceCompanies(),
    },
    {
      'id': 'health_map',
      'title': 'خريطة المرافق',
      'icon': AppIcons.navHome,
      'category': 'لوجستيات',
      'screen': const ServicesScreen(),
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedCategory == 'الكل') return _services;
    return _services.where((s) => s['category'] == _selectedCategory).toList();
  }

  void _goToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final filteredServices = _filteredServices;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المزيد'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              _goToScreen(context, const SettingsScreen());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط الفلتر
          _buildFilterChips(isDark),
          const SizedBox(height: 8),

          // ✅ قائمة الخدمات
          Expanded(
            child: filteredServices.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return _buildServiceCard(service, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 ويدجتس
  // ============================================================
  Widget _buildFilterChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      height: 48,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : (isDark ? const Color(0xFF1A2540) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryColor : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark) {
    final iconPath = service['icon'] as String;
    final isPng = iconPath.endsWith('.png');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0D5257).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: isPng
                ? Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    color: const Color(0xFF0D5257),
                  )
                : Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    color: const Color(0xFF0D5257),
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.medical_services_rounded,
                        color: const Color(0xFF0D5257),
                        size: 24,
                      );
                    },
                  ),
          ),
        ),
        title: Text(
          service['title'] as String,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          service['category'] as String,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          _goToScreen(context, service['screen'] as Widget);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات في هذا القسم',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
