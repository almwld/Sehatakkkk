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

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final List<String> _categories = ['الكل', 'طبية', 'صحية', 'لوجستية', 'توعوية'];

  final List<Map<String, dynamic>> _allServices = [
    {'id': '1', 'icon': Icons.medical_services, 'label': 'الأطباء', 'color': AppColors.primary, 'category': 'طبية', 'screen': const DoctorsListScreen(), 'description': 'استشر أفضل الأطباء في مختلف التخصصات'},
    {'id': '2', 'icon': Icons.local_pharmacy, 'label': 'الصيدلية', 'color': AppColors.success, 'category': 'طبية', 'screen': const PharmacyScreen(), 'description': 'اطلب أدويتك واستلمها في منزلك'},
    {'id': '3', 'icon': Icons.science, 'label': 'المختبرات', 'color': AppColors.purple, 'category': 'طبية', 'screen': const LabsListScreen(), 'description': 'احجز تحاليلك في أفضل المختبرات'},
    {'id': '4', 'icon': Icons.emergency, 'label': 'الطوارئ', 'color': AppColors.error, 'category': 'طبية', 'screen': const EmergencyNumbers(), 'description': 'أرقام الطوارئ والمساعدة الفورية'},
    {'id': '5', 'icon': Icons.chat, 'label': 'استشارة فورية', 'color': AppColors.teal, 'category': 'طبية', 'screen': const ConsultationScreen(), 'description': 'تحدث مع طبيبك عبر الفيديو والصوت'},
    {'id': '6', 'icon': Icons.calendar_month, 'label': 'المواعيد', 'color': AppColors.primaryDark, 'category': 'طبية', 'screen': const PatientAppointments(), 'description': 'إدارة مواعيدك الطبية بكل سهولة'},
    {'id': '7', 'icon': Icons.chat_rounded, 'label': 'الدردشة', 'color': AppColors.info, 'category': 'طبية', 'screen': const ChatScreen(), 'description': 'تواصل مع الأطباء والصيدليات'},
    {'id': '8', 'icon': Icons.map, 'label': 'الخريطة', 'color': Colors.orange, 'category': 'طبية', 'screen': const InteractiveMapScreen(), 'description': 'ابحث عن أقرب المنشآت الصحية'},
    {'id': '9', 'icon': Icons.bloodtype, 'label': 'التبرع بالدم', 'color': Colors.red, 'category': 'طبية', 'screen': const BloodDonationScreen(), 'description': 'أنقذ حياة بتبرعك بالدم'},
    {'id': '10', 'icon': Icons.shield, 'label': 'التأمين الصحي', 'color': Colors.blue, 'category': 'طبية', 'screen': const InsuranceCompanies(), 'description': 'خطط تأمين تناسب احتياجاتك'},
    {'id': '11', 'icon': Icons.favorite, 'label': 'الصحة العامة', 'color': AppColors.pink, 'category': 'صحية', 'screen': const HealthDashboard(), 'description': 'متابعة حالتك الصحية بشكل شامل'},
    {'id': '12', 'icon': Icons.monitor_heart, 'label': 'ضغط الدم', 'color': AppColors.error, 'category': 'صحية', 'screen': const BloodPressureScreen(), 'description': 'تتبع ومراقبة ضغط الدم'},
    {'id': '13', 'icon': Icons.biotech, 'label': 'تتبع السكر', 'color': AppColors.warning, 'category': 'صحية', 'screen': const GlucoseTrackerScreen(), 'description': 'مراقبة مستوى السكر في الدم'},
    {'id': '14', 'icon': Icons.monitor_weight, 'label': 'الوزن', 'color': AppColors.info, 'category': 'صحية', 'screen': const WeightTrackerScreen(), 'description': 'تتبع وزنك وحافظ على لياقتك'},
    {'id': '15', 'icon': Icons.medication, 'label': 'الأدوية', 'color': AppColors.success, 'category': 'صحية', 'screen': const MedicinesScreen(), 'description': 'إدارة أدويتك وتذكيرك بها'},
    {'id': '16', 'icon': Icons.healing, 'label': 'الإسعافات الأولية', 'color': Colors.orange, 'category': 'صحية', 'screen': const FirstAidScreen(), 'description': 'تعلم أساسيات الإسعافات الأولية'},
    {'id': '17', 'icon': Icons.article, 'label': 'المقالات الطبية', 'color': Colors.blueGrey, 'category': 'صحية', 'screen': const ArticlesScreen(), 'description': 'اقرأ أحدث المقالات الطبية'},
    {'id': '18', 'icon': Icons.group, 'label': 'مجتمع صحتك', 'color': Colors.teal, 'category': 'صحية', 'screen': const HealthCommunityScreen(), 'description': 'انضم لمجتمع صحي تفاعلي'},
    {'id': '19', 'icon': Icons.wallet, 'label': 'المحفظة', 'color': AppColors.amber, 'category': 'لوجستية', 'screen': const WalletScreen(), 'description': 'إدارة محفظتك الإلكترونية'},
    {'id': '21', 'icon': Icons.local_shipping, 'label': 'تتبع الطلب', 'color': Colors.purple, 'category': 'لوجستية', 'screen': const OrderTrackingScreen(), 'description': 'تتبع طلباتك في الوقت الفعلي'},
    {'id': '22', 'icon': Icons.home_work, 'label': 'خدمات منزلية', 'color': Colors.brown, 'category': 'لوجستية', 'screen': const ServicesScreen(), 'description': 'خدمات طبية في منزلك'},
    {'id': '23', 'icon': Icons.lightbulb, 'label': 'نصائح صحية', 'color': Colors.amber, 'category': 'توعوية', 'screen': const HealthDashboard(), 'description': 'نصائح يومية للحفاظ على صحتك'},
  ];

  List<Map<String, dynamic>> get _filteredServices {
    var list = _allServices;
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
        s['label'].toString().contains(_searchQuery) ||
        s['description'].toString().contains(_searchQuery)
      ).toList();
    }
    if (_selectedCategory != 'الكل') {
      list = list.where((s) => s['category'] == _selectedCategory).toList();
    }
    return list;
  }

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
            onPressed: () => _showSearchBar(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty) _buildSearchBar(isDark),
          _buildCategoryChips(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
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

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(25),
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
            Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, size: 18, color: isDark ? Colors.grey[400] : Colors.grey),
                onPressed: () => setState(() => _searchQuery = ''),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = selected ? category : 'الكل');
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0D5257),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0D5257),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0D5257) : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text('لا توجد خدمات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text('جرب تغيير البحث أو الفلتر', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
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
        padding: const EdgeInsets.all(10),
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
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service['icon'] as IconData, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              service['label'] as String,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              service['category'] as String,
              style: TextStyle(
                fontSize: 8,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSearch = '';
        return AlertDialog(
          title: const Text('بحث عن خدمة'),
          content: TextField(
            onChanged: (value) => tempSearch = value,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل اسم الخدمة...',
              prefixIcon: Icon(Icons.search),
            ),
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
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }
}
