import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
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

  final List<String> _filters = [
    'الكل',
    'معتمد',
    'خدمة منزلية',
    'نتائج سريعة',
    'أسعار منخفضة',
  ];

  // ✅ 12 مختبر
  final List<Map<String, dynamic>> _allLabs = [
    {
      'id': '1',
      'name': 'المختبر الوطني',
      'address': 'شارع الستين، أمام المستشفى العسكري',
      'rating': 4.8,
      'reviews': 328,
      'tests': '650+',
      'price': 250,
      'accredited': true,
      'homeService': true,
      'quickResults': true,
      'image': ImageService.lab1,
      'categories': ['دم', 'بول', 'أشعة'],
      'phone': '01-012345',
      'workingHours': '8 ص - 10 م',
    },
    {
      'id': '2',
      'name': 'مختبر الثقة',
      'address': 'شارع الزبيري، عمارة النعمان',
      'rating': 4.6,
      'reviews': 256,
      'tests': '520+',
      'price': 200,
      'accredited': true,
      'homeService': true,
      'quickResults': false,
      'image': ImageService.pharmacy1,
      'categories': ['دم', 'هرمونات'],
      'phone': '01-123456',
      'workingHours': '8 ص - 11 م',
    },
    {
      'id': '3',
      'name': 'مختبر البرج',
      'address': 'شارع هائل، جولة كنتاكي',
      'rating': 4.4,
      'reviews': 189,
      'tests': '480+',
      'price': 280,
      'accredited': true,
      'homeService': false,
      'quickResults': true,
      'image': ImageService.lab1,
      'categories': ['دم', 'أشعة', 'ميكروبيولوجي'],
      'phone': '01-234567',
      'workingHours': '9 ص - 10 م',
    },
    {
      'id': '4',
      'name': 'مختبر اليقين',
      'address': 'شارع التحرير، عمارة البساطي',
      'rating': 4.2,
      'reviews': 89,
      'tests': '350+',
      'price': 180,
      'accredited': true,
      'homeService': true,
      'quickResults': false,
      'image': ImageService.pharmacy2,
      'categories': ['دم', 'بول'],
      'phone': '01-345678',
      'workingHours': '8 ص - 9 م',
    },
    {
      'id': '5',
      'name': 'مختبرات الحياة',
      'address': 'شارع الخمسين، الحصبة',
      'rating': 4.3,
      'reviews': 145,
      'tests': '420+',
      'price': 220,
      'accredited': false,
      'homeService': true,
      'quickResults': true,
      'image': ImageService.lab1,
      'categories': ['دم', 'هرمونات', 'فيتامينات'],
      'phone': '01-456789',
      'workingHours': '7 ص - 11 م',
    },
    {
      'id': '6',
      'name': 'معمل ابن سينا',
      'address': 'شارع الزبيري، بجانب برج زبيدة',
      'rating': 4.7,
      'reviews': 210,
      'tests': '380+',
      'price': 300,
      'accredited': true,
      'homeService': false,
      'quickResults': true,
      'image': ImageService.pharmacy1,
      'categories': ['أشعة', 'ميكروبيولوجي'],
      'phone': '01-567890',
      'workingHours': '8 ص - 10 م',
    },
    {
      'id': '7',
      'name': 'مختبر الأمل',
      'address': 'شارع هائل، أمام جامعة صنعاء',
      'rating': 4.0,
      'reviews': 67,
      'tests': '290+',
      'price': 160,
      'accredited': false,
      'homeService': true,
      'quickResults': false,
      'image': ImageService.pharmacy2,
      'categories': ['دم', 'بول'],
      'phone': '01-678901',
      'workingHours': '9 ص - 8 م',
    },
    {
      'id': '8',
      'name': 'معامل النخبة',
      'address': 'شارع الستين، مجمع النخبة',
      'rating': 4.9,
      'reviews': 456,
      'tests': '550+',
      'price': 350,
      'accredited': true,
      'homeService': true,
      'quickResults': true,
      'image': ImageService.lab1,
      'categories': ['دم', 'أشعة', 'هرمونات', 'ميكروبيولوجي'],
      'phone': '01-789012',
      'workingHours': '6 ص - 12 م',
    },
    {
      'id': '9',
      'name': 'مختبر الشروق',
      'address': 'شارع القاهرة، باب اليمن',
      'rating': 4.1,
      'reviews': 78,
      'tests': '310+',
      'price': 190,
      'accredited': false,
      'homeService': false,
      'quickResults': false,
      'image': ImageService.pharmacy1,
      'categories': ['دم', 'بول'],
      'phone': '01-890123',
      'workingHours': '8 ص - 9 م',
    },
    {
      'id': '10',
      'name': 'معمل الدقة',
      'address': 'شارع العدين، السنينة',
      'rating': 4.5,
      'reviews': 178,
      'tests': '460+',
      'price': 260,
      'accredited': true,
      'homeService': true,
      'quickResults': true,
      'image': ImageService.lab1,
      'categories': ['دم', 'هرمونات', 'فيتامينات'],
      'phone': '01-901234',
      'workingHours': '7 ص - 10 م',
    },
    {
      'id': '11',
      'name': 'مختبر الصحة',
      'address': 'شارع الأربعين، شارع صخر',
      'rating': 3.9,
      'reviews': 54,
      'tests': '270+',
      'price': 150,
      'accredited': false,
      'homeService': true,
      'quickResults': false,
      'image': ImageService.pharmacy2,
      'categories': ['دم', 'بول'],
      'phone': '01-112345',
      'workingHours': '9 ص - 7 م',
    },
    {
      'id': '12',
      'name': 'معامل اليمن',
      'address': 'شارع التحرير، عمارة الحمدي',
      'rating': 4.6,
      'reviews': 234,
      'tests': '500+',
      'price': 290,
      'accredited': true,
      'homeService': true,
      'quickResults': true,
      'image': ImageService.lab1,
      'categories': ['دم', 'أشعة', 'ميكروبيولوجي'],
      'phone': '01-223456',
      'workingHours': '8 ص - 11 م',
    },
  ];

  List<Map<String, dynamic>> get _filteredLabs {
    var list = _allLabs;
    if (_searchQuery.isNotEmpty) {
      list = list.where((l) =>
        l['name'].toString().contains(_searchQuery) ||
        l['address'].toString().contains(_searchQuery)
      ).toList();
    }
    if (_selectedFilter != 'الكل') {
      switch (_selectedFilter) {
        case 'معتمد':
          list = list.where((l) => l['accredited'] == true).toList();
          break;
        case 'خدمة منزلية':
          list = list.where((l) => l['homeService'] == true).toList();
          break;
        case 'نتائج سريعة':
          list = list.where((l) => l['quickResults'] == true).toList();
          break;
        case 'أسعار منخفضة':
          list = list.where((l) => (l['price'] as int) <= 200).toList();
          break;
      }
    }
    if (_showHomeService) {
      list = list.where((l) => l['homeService'] == true).toList();
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
          // ✅ زر الخدمة المنزلية
          IconButton(
            icon: Icon(
              _showHomeService ? Icons.home_work : Icons.home_work_outlined,
              color: _showHomeService ? Colors.white : Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _showHomeService = !_showHomeService;
                if (_showHomeService) {
                  _selectedFilter = 'الكل';
                }
              });
            },
            tooltip: 'خدمة منزلية',
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              _showSearchBar();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط البحث
          if (_searchQuery.isNotEmpty)
            _buildSearchBar(isDark),
          // ✅ الفلاتر
          _buildFilters(),
          // ✅ قائمة المختبرات
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
                autofocus: true,
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
                  if (_selectedFilter != 'الكل') {
                    _showHomeService = false;
                  }
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
          Icon(
            Icons.science_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مختبرات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير البحث أو الفلتر',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard(Map<String, dynamic> lab, bool isDark, Color primaryColor) {
    final isAccredited = lab['accredited'] as bool;
    final hasHomeService = lab['homeService'] as bool;
    final hasQuickResults = lab['quickResults'] as bool;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabTestsScreen(labId: lab['id']),
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
          border: isAccredited
              ? Border.all(color: Colors.green.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // ✅ صورة المختبر
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: lab['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => _shimmerPlaceholder(70, 70, 12),
                errorWidget: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: Icon(Icons.science, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ معلومات المختبر
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lab['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            lab['rating'].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${lab['reviews']})',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lab['address'],
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ✅ الشارات
                  Wrap(
                    spacing: 4,
                    children: [
                      if (isAccredited)
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
                              const Text(
                                'معتمد',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hasHomeService)
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
                              const Text(
                                'خدمة منزلية',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hasQuickResults)
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
                              const Text(
                                'نتائج سريعة',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // ✅ الفحوصات
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lab['tests'],
                          style: TextStyle(
                            fontSize: 9,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // ✅ السعر
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${lab['price']} ر.ي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ سهم
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder(double width, double height, double radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
