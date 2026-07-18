import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health_community/health_community_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/orders/order_tracking_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/articles/articles_screen.dart';
import 'package:sehatak/presentation/screens/home_services/home_services_screen.dart';

// ============================================================
// 📱 ServicesScreen - جميع الخدمات
// ============================================================
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'طبية',
    'صحية',
    'لوجستية',
    'توعوية',
  ];

  // ============================================================
  // 📋 قائمة الخدمات (23 خدمة)
  // ============================================================
  final List<Map<String, dynamic>> _allServices = [
    // 🔹 الخدمات الطبية (10)
    {
      'id': '1',
      'icon': Icons.medical_services,
      'label': 'الأطباء',
      'color': AppColors.primary,
      'category': 'طبية',
      'screen': const DoctorsListScreen(),
      'description': 'استشر أفضل الأطباء في مختلف التخصصات',
    },
    {
      'id': '2',
      'icon': Icons.local_pharmacy,
      'label': 'الصيدلية',
      'color': AppColors.success,
      'category': 'طبية',
      'screen': const PharmacyScreen(),
      'description': 'اطلب أدويتك واستلمها في منزلك',
    },
    {
      'id': '3',
      'icon': Icons.science,
      'label': 'المختبرات',
      'color': AppColors.purple,
      'category': 'طبية',
      'screen': const LabsListScreen(),
      'description': 'احجز تحاليلك في أفضل المختبرات',
    },
    {
      'id': '4',
      'icon': Icons.emergency,
      'label': 'الطوارئ',
      'color': AppColors.error,
      'category': 'طبية',
      'screen': const EmergencyNumbers(),
      'description': 'أرقام الطوارئ والمساعدة الفورية',
    },
    {
      'id': '5',
      'icon': Icons.video_call,
      'label': 'استشارة فورية',
      'color': AppColors.teal,
      'category': 'طبية',
      'screen': const ConsultationScreen(),
      'description': 'تحدث مع طبيبك عبر الفيديو والصوت',
    },
    {
      'id': '6',
      'icon': Icons.calendar_month,
      'label': 'المواعيد',
      'color': AppColors.primaryDark,
      'category': 'طبية',
      'screen': const PatientAppointments(),
      'description': 'إدارة مواعيدك الطبية بكل سهولة',
    },
    {
      'id': '7',
      'icon': Icons.chat_rounded,
      'label': 'الدردشة',
      'color': AppColors.info,
      'category': 'طبية',
      'screen': const ChatScreen(),
      'description': 'تواصل مع الأطباء والصيدليات',
    },
    {
      'id': '8',
      'icon': Icons.map,
      'label': 'الخريطة',
      'color': Colors.orange,
      'category': 'طبية',
      'screen': const InteractiveMapScreen(),
      'description': 'ابحث عن أقرب المنشآت الصحية',
    },
    {
      'id': '9',
      'icon': Icons.bloodtype,
      'label': 'التبرع بالدم',
      'color': Colors.red,
      'category': 'طبية',
      'screen': const BloodDonationScreen(),
      'description': 'أنقذ حياة بتبرعك بالدم',
    },
    {
      'id': '10',
      'icon': Icons.shield,
      'label': 'التأمين الصحي',
      'color': Colors.blue,
      'category': 'طبية',
      'screen': const InsuranceCompanies(),
      'description': 'خطط تأمين تناسب احتياجاتك',
    },

    // 🔹 الخدمات الصحية (8)
    {
      'id': '11',
      'icon': Icons.favorite,
      'label': 'الصحة العامة',
      'color': AppColors.pink,
      'category': 'صحية',
      'screen': const HealthDashboard(),
      'description': 'متابعة حالتك الصحية بشكل شامل',
    },
    {
      'id': '12',
      'icon': Icons.monitor_heart,
      'label': 'ضغط الدم',
      'color': AppColors.error,
      'category': 'صحية',
      'screen': const BloodPressureScreen(),
      'description': 'تتبع ومراقبة ضغط الدم',
    },
    {
      'id': '13',
      'icon': Icons.biotech,
      'label': 'تتبع السكر',
      'color': AppColors.warning,
      'category': 'صحية',
      'screen': const GlucoseTrackerScreen(),
      'description': 'مراقبة مستوى السكر في الدم',
    },
    {
      'id': '14',
      'icon': Icons.monitor_weight,
      'label': 'الوزن',
      'color': AppColors.info,
      'category': 'صحية',
      'screen': const WeightTrackerScreen(),
      'description': 'تتبع وزنك وحافظ على لياقتك',
    },
    {
      'id': '15',
      'icon': Icons.medication,
      'label': 'الأدوية',
      'color': AppColors.success,
      'category': 'صحية',
      'screen': const MedicinesScreen(),
      'description': 'إدارة أدويتك وتذكيرك بها',
    },
    {
      'id': '16',
      'icon': Icons.healing,
      'label': 'الإسعافات الأولية',
      'color': Colors.orange,
      'category': 'صحية',
      'screen': const FirstAidScreen(),
      'description': 'تعلم أساسيات الإسعافات الأولية',
    },
    {
      'id': '17',
      'icon': Icons.article,
      'label': 'المقالات الطبية',
      'color': Colors.blueGrey,
      'category': 'صحية',
      'screen': const ArticlesScreen(),
      'description': 'اقرأ أحدث المقالات الطبية',
    },
    {
      'id': '18',
      'icon': Icons.group,
      'label': 'مجتمع صحتك',
      'color': Colors.teal,
      'category': 'صحية',
      'screen': const HealthCommunityScreen(),
      'description': 'انضم لمجتمع صحي تفاعلي',
    },

    // 🔹 الخدمات اللوجستية (3)
    {
      'id': '19',
      'icon': Icons.wallet,
      'label': 'المحفظة',
      'color': AppColors.amber,
      'category': 'لوجستية',
      'screen': const WalletScreen(),
      'description': 'إدارة محفظتك الإلكترونية',
    },
    {
      'id': '20',
      'icon': Icons.local_shipping,
      'label': 'تتبع الطلب',
      'color': Colors.purple,
      'category': 'لوجستية',
      'screen': const OrderTrackingScreen(),
      'description': 'تتبع طلباتك في الوقت الفعلي',
    },
    {
      'id': '21',
      'icon': Icons.home_work,
      'label': 'خدمات منزلية',
      'color': Colors.brown,
      'category': 'لوجستية',
      'screen': const HomeServicesScreen(),
      'description': 'خدمات طبية متكاملة في منزلك',
    },

    // 🔹 الخدمات التوعوية (2)
    {
      'id': '22',
      'icon': Icons.lightbulb,
      'label': 'نصائح صحية',
      'color': Colors.amber,
      'category': 'توعوية',
      'screen': const HealthDashboard(),
      'description': 'نصائح يومية للحفاظ على صحتك',
    },
    {
      'id': '23',
      'icon': Icons.school,
      'label': 'التثقيف الصحي',
      'color': Colors.indigo,
      'category': 'توعوية',
      'screen': const ArticlesScreen(),
      'description': 'معلومات صحية مفيدة لك ولعائلتك',
    },
  ];

  // ============================================================
  // 🔍 فلترة الخدمات
  // ============================================================
  List<Map<String, dynamic>> get _filteredServices {
    var list = _allServices;

    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
          s['label'].toString().contains(_searchQuery) ||
          s['description'].toString().contains(_searchQuery)).toList();
    }

    if (_selectedCategory != 'الكل') {
      list = list.where((s) => s['category'] == _selectedCategory).toList();
    }

    return list;
  }

  // ============================================================
  // 🎨 بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final filtered = _filteredServices;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('جميع الخدمات'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط البحث (يظهر عند البحث)
          if (_searchQuery.isNotEmpty) _buildSearchBar(isDark),

          // ✅ فلاتر التصنيفات
          _buildCategoryChips(isDark),

          // ✅ قائمة الخدمات
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final service = filtered[index];
                      return _buildServiceCard(service, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔧 أجزاء الواجهة
  // ============================================================

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(25),
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
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                textAlign: TextAlign.right,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'ابحث عن خدمة...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () => setState(() => _searchQuery = ''),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: const Color(0xFF0D5257),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[700]),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
              onSelected: (_) => setState(() => _selectedCategory = category),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0D5257) : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark) {
    final color = service['color'] as Color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => service['screen'] as Widget),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'] as IconData,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              service['label'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              service['description'] as String,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات مطابقة',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير كلمة البحث أو التصنيف',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔍 نافذة البحث المنبثقة
  // ============================================================
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSearch = '';
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
          title: const Text('بحث عن خدمة'),
          content: TextField(
            textAlign: TextAlign.right,
            autofocus: true,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: const InputDecoration(
              hintText: 'ابحث عن خدمة...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            onChanged: (value) => tempSearch = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = tempSearch);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D5257),
              ),
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }
}
