import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_products_screen.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _filters = [
    'الكل',
    'توصيل مجاني',
    'تقييم مرتفع',
    'مناوبة',
    'قريب مني',
  ];

  final List<Map<String, dynamic>> _pharmacies = [
    {
      'id': '1',
      'name': 'صيدلية الشفاء',
      'address': 'شارع الزبيري، باب اليمن',
      'rating': 4.8,
      'reviews': 328,
      'delivery': true,
      'deliveryFree': true,
      'open24': true,
      'distance': '1.2 كم',
      'image': ImageService.pharmacy1,
      'categories': ['أدوية', 'مستلزمات', 'عناية'],
    },
    {
      'id': '2',
      'name': 'صيدلية اليمن',
      'address': 'شارع التحرير، بجانب البنك المركزي',
      'rating': 4.5,
      'reviews': 256,
      'delivery': true,
      'deliveryFree': false,
      'open24': false,
      'distance': '2.5 كم',
      'image': ImageService.pharmacy2,
      'categories': ['أدوية', 'فيتامينات'],
    },
    {
      'id': '3',
      'name': 'صيدلية الأمل',
      'address': 'شارع هائل، أمام جامعة صنعاء',
      'rating': 4.9,
      'reviews': 189,
      'delivery': true,
      'deliveryFree': true,
      'open24': true,
      'distance': '0.8 كم',
      'image': ImageService.pharmacy1,
      'categories': ['أدوية', 'مستلزمات', 'عناية', 'فيتامينات'],
    },
    {
      'id': '4',
      'name': 'صيدلية البرج',
      'address': 'شارع الستين، مجمع النخبة',
      'rating': 4.3,
      'reviews': 89,
      'delivery': false,
      'deliveryFree': false,
      'open24': false,
      'distance': '3.1 كم',
      'image': ImageService.pharmacy2,
      'categories': ['أدوية'],
    },
    {
      'id': '5',
      'name': 'صيدلية النور',
      'address': 'شارع القاهرة، حي السياسي',
      'rating': 4.6,
      'reviews': 210,
      'delivery': true,
      'deliveryFree': false,
      'open24': true,
      'distance': '1.8 كم',
      'image': ImageService.pharmacy1,
      'categories': ['أدوية', 'مستلزمات'],
    },
    {
      'id': '6',
      'name': 'صيدلية الروضة',
      'address': 'شارع هائل، حي الروضة',
      'rating': 4.7,
      'reviews': 145,
      'delivery': true,
      'deliveryFree': true,
      'open24': false,
      'distance': '2.0 كم',
      'image': ImageService.pharmacy2,
      'categories': ['أدوية', 'فيتامينات', 'عناية'],
    },
  ];

  List<Map<String, dynamic>> get _filteredPharmacies {
    var list = _pharmacies;
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) =>
        p['name'].toString().contains(_searchQuery) ||
        p['address'].toString().contains(_searchQuery)
      ).toList();
    }
    if (_selectedFilter != 'الكل') {
      switch (_selectedFilter) {
        case 'توصيل مجاني':
          list = list.where((p) => p['deliveryFree'] == true).toList();
          break;
        case 'تقييم مرتفع':
          list = list.where((p) => p['rating'] >= 4.5).toList();
          break;
        case 'مناوبة':
          list = list.where((p) => p['open24'] == true).toList();
          break;
        case 'قريب مني':
          list = list.take(3).toList();
          break;
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final filtered = _filteredPharmacies;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الصيدليات'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ زر السلة
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_rounded),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط البحث
          _buildSearchBar(isDark),
          const SizedBox(height: 8),
          // ✅ الفلاتر
          _buildFilters(),
          const SizedBox(height: 8),
          // ✅ قائمة الصيدليات
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final pharmacy = filtered[index];
                      return _buildPharmacyCard(pharmacy, isDark, primaryColor);
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
                  hintText: 'ابحث عن صيدلية...',
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
      height: 36,
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
            Icons.local_pharmacy_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد صيدليات',
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

  Widget _buildPharmacyCard(Map<String, dynamic> pharmacy, bool isDark, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyProductsScreen(pharmacyId: pharmacy['id']),
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
            // ✅ صورة الصيدلية
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: pharmacy['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => _shimmerPlaceholder(70, 70, 12),
                errorWidget: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: Icon(Icons.local_pharmacy, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ معلومات الصيدلية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pharmacy['name'],
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
                            pharmacy['rating'].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${pharmacy['reviews']})',
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
                    pharmacy['address'],
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // ✅ توصيل مجاني
                      if (pharmacy['deliveryFree'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_shipping, color: Colors.green, size: 10),
                              const SizedBox(width: 2),
                              const Text(
                                'توصيل مجاني',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (pharmacy['deliveryFree'] == true) const SizedBox(width: 4),
                      // ✅ مناوبة
                      if (pharmacy['open24'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.orange, size: 10),
                              const SizedBox(width: 2),
                              const Text(
                                'مناوبة',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      // ✅ المسافة
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pharmacy['distance'],
                          style: TextStyle(
                            fontSize: 9,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // ✅ التصنيفات
                  Wrap(
                    spacing: 4,
                    children: (pharmacy['categories'] as List).map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 8,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      );
                    }).toList(),
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
