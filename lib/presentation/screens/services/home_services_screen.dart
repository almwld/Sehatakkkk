import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/presentation/widgets/app_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/ambulance/ambulance_request_screen.dart';
import 'package:sehatak/presentation/screens/first_aid/first_aid_screen.dart';
import 'package:sehatak/presentation/screens/nursing/nursing_care_screen.dart';
import 'package:sehatak/presentation/screens/doctor/home_visit_screen.dart';
import 'package:sehatak/presentation/screens/lab/home_lab_test_screen.dart';
import 'package:sehatak/presentation/screens/physiotherapy/physiotherapy_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';

class HomeServicesScreen extends StatefulWidget {
  const HomeServicesScreen({super.key});

  @override
  State<HomeServicesScreen> createState() => _HomeServicesScreenState();
}

class _HomeServicesScreenState extends State<HomeServicesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'رعاية منزلية',
    'طوارئ',
    'فحوصات',
    'علاج طبيعي',
  ];

  final List<Map<String, dynamic>> _services = [
    // ✅ الرعاية المنزلية
    {
      'id': '1',
      'icon': Icons.health_and_safety,
      'title': 'تمريض منزلي',
      'subtitle': 'رعاية تمريضية متكاملة في منزلك',
      'color': Colors.blue,
      'category': 'رعاية منزلية',
      'screen': const NursingCareScreen(),
      'badge': 'متاح',
    },
    {
      'id': '2',
      'icon': Icons.medical_services,
      'title': 'زيارات طبية',
      'subtitle': 'طبيب يزورك في منزلك لتشخيص حالتك',
      'color': Colors.teal,
      'category': 'رعاية منزلية',
      'screen': const HomeVisitScreen(),
      'badge': 'متاح',
    },
    {
      'id': '3',
      'icon': Icons.physical_therapy,
      'title': 'علاج طبيعي منزلي',
      'subtitle': 'جلسات علاج طبيعي في منزلك',
      'color': Colors.orange,
      'category': 'رعاية منزلية',
      'screen': const PhysiotherapyScreen(),
      'badge': 'قريباً',
    },

    // ✅ الطوارئ
    {
      'id': '4',
      'icon': Icons.ambulance,
      'title': 'سيارة إسعاف',
      'subtitle': 'طلب سيارة إسعاف فورية للطوارئ',
      'color': Colors.red,
      'category': 'طوارئ',
      'screen': const AmbulanceRequestScreen(),
      'badge': 'طارئ',
    },
    {
      'id': '5',
      'icon': Icons.healing,
      'title': 'إسعافات أولية',
      'subtitle': 'دليل الإسعافات الأولية للحالات الطارئة',
      'color': Colors.deepOrange,
      'category': 'طوارئ',
      'screen': const FirstAidScreen(),
      'badge': 'دليل',
    },

    // ✅ الفحوصات
    {
      'id': '6',
      'icon': Icons.science,
      'title': 'فحص عينة سريع',
      'subtitle': 'فحص مخبري في منزلك دون الحاجة للذهاب للمختبر',
      'color': Colors.purple,
      'category': 'فحوصات',
      'screen': const HomeLabTestScreen(),
      'badge': 'جديد',
    },
    {
      'id': '7',
      'icon': Icons.monitor_heart,
      'title': 'قياس ضغط الدم',
      'subtitle': 'مراقبة ضغط الدم في منزلك',
      'color': Colors.pink,
      'category': 'فحوصات',
      'screen': const BloodPressureScreen(),
      'badge': 'شائع',
    },
    {
      'id': '8',
      'icon': Icons.biotech,
      'title': 'فحص السكر',
      'subtitle': 'مراقبة مستوى السكر في الدم منزلياً',
      'color': Colors.amber,
      'category': 'فحوصات',
      'screen': const GlucoseTrackerScreen(),
      'badge': 'شائع',
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    var list = _services;

    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
        s['title'].toString().contains(_searchQuery) ||
        s['subtitle'].toString().contains(_searchQuery)
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
    final filtered = _filteredServices;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'الخدمات المنزلية',
        backgroundColor: AppColors.primary,
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
          // ✅ شريط البحث
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _searchQuery,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                  ],
                ),
              ),
            ),

          // ✅ الفلاتر
          _buildCategoryChips(isDark),

          // ✅ قائمة الخدمات
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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

  Widget _buildCategoryChips(bool isDark) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                setState(() {
                  _selectedCategory = selected ? category : 'الكل';
                });
              },
              backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.primary),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.grey[700]! : Colors.grey.shade300),
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
          Icon(
            Icons.home_work_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
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
            'جرب تغيير البحث أو التصنيف',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark) {
    final color = service['color'] as Color;
    final badge = service['badge'] as String?;
    final screen = service['screen'] as Widget;
    final isAvailable = badge != 'قريباً';

    return GestureDetector(
      onTap: isAvailable ? () => _navigateTo(screen) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ✅ أيقونة الخدمة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'] as IconData,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // ✅ معلومات الخدمة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        service['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badge == 'طارئ'
                                ? Colors.red.withOpacity(0.15)
                                : badge == 'جديد'
                                    ? Colors.green.withOpacity(0.15)
                                    : badge == 'قريباً'
                                        ? Colors.orange.withOpacity(0.15)
                                        : Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badge == 'طارئ'
                                  ? Colors.red
                                  : badge == 'جديد'
                                      ? Colors.green
                                      : badge == 'قريباً'
                                          ? Colors.orange
                                          : Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // ✅ التصنيف
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service['category'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ سهم
            Icon(
              isAvailable ? Icons.arrow_forward_ios : Icons.lock_outline,
              size: 16,
              color: isAvailable
                  ? (isDark ? Colors.grey[400] : Colors.grey[400])
                  : Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSearch = '';
        return AlertDialog(
          title: 'بحث في الخدمات المنزلية',
          content: TextField(
            onChanged: (value) => tempSearch = value,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'ابحث عن خدمة...',
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
