import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/presentation/widgets/app_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'حكومي', 'خاص', 'جامعي', 'تخصصي'];

  final List<Map<String, dynamic>> _hospitals = [
    {'id': '1', 'name': 'مستشفى الثورة العام', 'location': 'صنعاء', 'specialty': 'حكومي', 'rating': 4.8, 'reviews': 450, 'phone': '01-222222', 'image': ImageKit.hospital1, 'open': true, 'emergency': true, 'beds': 500},
    {'id': '2', 'name': 'المستشفى الجمهوري', 'location': 'صنعاء', 'specialty': 'حكومي', 'rating': 4.7, 'reviews': 380, 'phone': '01-999444', 'image': ImageKit.hospital2, 'open': true, 'emergency': true, 'beds': 450},
    {'id': '3', 'name': 'مستشفى الكويت الجامعي', 'location': 'صنعاء', 'specialty': 'جامعي', 'rating': 4.9, 'reviews': 520, 'phone': '01-333333', 'image': ImageKit.hospital3, 'open': true, 'emergency': true, 'beds': 400},
    {'id': '4', 'name': 'مستشفى السبعين للأمومة', 'location': 'صنعاء', 'specialty': 'تخصصي', 'rating': 4.6, 'reviews': 290, 'phone': '01-444444', 'image': ImageKit.hospital4, 'open': true, 'emergency': true, 'beds': 300},
    {'id': '5', 'name': 'المستشفى العسكري', 'location': 'صنعاء', 'specialty': 'حكومي', 'rating': 4.5, 'reviews': 310, 'phone': '01-777777', 'image': ImageKit.hospital5, 'open': true, 'emergency': true, 'beds': 600},
    {'id': '6', 'name': 'مستشفى آزال', 'location': 'صنعاء', 'specialty': 'خاص', 'rating': 4.4, 'reviews': 220, 'phone': '01-555555', 'image': ImageKit.hospital6, 'open': true, 'emergency': true, 'beds': 150},
  ];

  List<Map<String, dynamic>> get _filteredHospitals {
    var list = _hospitals;
    if (_searchQuery.isNotEmpty) {
      list = list.where((h) =>
        h['name'].toString().contains(_searchQuery) ||
        h['location'].toString().contains(_searchQuery) ||
        h['specialty'].toString().contains(_searchQuery)
      ).toList();
    }
    if (_selectedFilter != 'الكل') {
      list = list.where((h) => h['specialty'] == _selectedFilter).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredHospitals;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'المستشفيات',
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
          // ✅ التصنيفات
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(filter, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.primary),
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
          ),
          // ✅ القائمة
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final hospital = filtered[index];
                      return _buildHospitalCard(hospital, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital, bool isDark) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('جاري عرض تفاصيل ${hospital['name']}'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                imageUrl: hospital['image'],
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        hospital['location'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hospital['specialty'],
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            hospital['rating'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${hospital['reviews']})',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: hospital['open'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: hospital['open'] ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hospital['open'] ? 'مفتوح' : 'مغلق',
                              style: TextStyle(
                                color: hospital['open'] ? Colors.green : Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${hospital['beds']} سرير',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey[600] : Colors.grey[400]),
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
          Icon(Icons.local_hospital_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا توجد مستشفيات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير البحث أو التصنيف',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSearch = '';
        return AlertDialog(
          title: const Text('بحث عن مستشفى'),
          content: TextField(
            onChanged: (value) => tempSearch = value,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل اسم المستشفى...',
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
