import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/lab/lab_tests_screen.dart';

class LabsListScreen extends StatefulWidget {
  const LabsListScreen({super.key});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  bool _showHomeService = false;

  final List<String> _filters = ['الكل', 'معتمد', 'خدمة منزلية', 'نتائج سريعة', 'أسعار منخفضة'];

  final List<Map<String, dynamic>> _allLabs = [
    {'id': '1', 'name': 'المختبر الوطني', 'address': 'شارع الستين، أمام المستشفى العسكري', 'rating': 4.8, 'reviews': 328, 'tests': '650+', 'price': 250, 'accredited': true, 'homeService': true, 'quickResults': true, 'image': ImageService.lab1, 'categories': ['دم', 'بول', 'أشعة'], 'phone': '01-012345', 'workingHours': '8 ص - 10 م'},
    {'id': '2', 'name': 'مختبر الثقة', 'address': 'شارع الزبيري، عمارة النعمان', 'rating': 4.6, 'reviews': 256, 'tests': '520+', 'price': 200, 'accredited': true, 'homeService': true, 'quickResults': false, 'image': ImageService.pharmacy1, 'categories': ['دم', 'هرمونات'], 'phone': '01-123456', 'workingHours': '8 ص - 11 م'},
    {'id': '3', 'name': 'مختبر البرج', 'address': 'شارع هائل، جولة كنتاكي', 'rating': 4.4, 'reviews': 189, 'tests': '480+', 'price': 280, 'accredited': true, 'homeService': false, 'quickResults': true, 'image': ImageService.lab1, 'categories': ['دم', 'أشعة', 'ميكروبيولوجي'], 'phone': '01-234567', 'workingHours': '9 ص - 10 م'},
  ];

  List<Map<String, dynamic>> get _filteredLabs {
    var list = _allLabs;
    if (_searchQuery.isNotEmpty) {
      list = list.where((l) =>
        l['name'].toString().contains(_searchQuery) ||
        l['address'].toString().contains(_searchQuery)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final filtered = _filteredLabs;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المختبرات'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showHomeService ? Icons.home_work : Icons.home_work_outlined, color: _showHomeService ? Colors.white : Colors.white70),
            onPressed: () => setState(() => _showHomeService = !_showHomeService),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchBar(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty) _buildSearchBar(isDark),
          _buildFilters(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final lab = filtered[index];
                      return _buildLabCard(lab, isDark, primaryColor);
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
                  hintText: 'ابحث عن مختبر...',
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

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'الكل';
                  if (_selectedFilter != 'الكل') _showHomeService = false;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0D5257),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0D5257),
                fontSize: 11,
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
          Icon(Icons.science_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text('لا توجد مختبرات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text('جرب تغيير البحث أو الفلتر', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildLabCard(Map<String, dynamic> lab, bool isDark, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LabTestsScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
              child: CachedNetworkImage(
                imageUrl: lab['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: Icon(Icons.science, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lab['name'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(lab['rating'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(width: 2),
                          Text('(${lab['reviews']})', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(lab['address'], style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: [
                      if (lab['accredited'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.green, size: 10),
                              const SizedBox(width: 2),
                              const Text('معتمد', style: TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      if (lab['homeService'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_work, color: Colors.blue, size: 10),
                              const SizedBox(width: 2),
                              const Text('خدمة منزلية', style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      if (lab['quickResults'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.speed, color: Colors.orange, size: 10),
                              const SizedBox(width: 2),
                              const Text('نتائج سريعة', style: TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(lab['tests'], style: TextStyle(fontSize: 9, color: primaryColor, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${lab['price']} ر.ي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor)),
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

  void _showSearchBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSearch = '';
        return AlertDialog(
          title: const Text('بحث عن مختبر'),
          content: TextField(
            onChanged: (value) => tempSearch = value,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل اسم المختبر...',
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
