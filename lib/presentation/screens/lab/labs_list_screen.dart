import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/utils/image_utils.dart';
import 'package:sehatak/presentation/screens/lab/lab_booking_screen.dart';

class LabsListScreen extends StatefulWidget {
  const LabsListScreen({super.key});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = true;
  List<Map<String, dynamic>> _labs = [];
  final List<String> _categories = [
    'الكل',
    'دم',
    'بول',
    'هرمونات',
    'فيتامينات',
    'أشعة',
    'تحاليل عامة',
  ];

  @override
  void initState() {
    super.initState();
    _loadLabs();
  }

  Future<void> _loadLabs() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('labs')
          .where('isAvailable', isEqualTo: true)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _labs = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'category': data['category'] ?? '',
            'address': data['address'] ?? '',
            'rating': data['rating']?.toDouble() ?? 0.0,
            'reviews': data['reviews'] ?? 0,
            'phone': data['phone'] ?? '',
            'image': data['image'] ?? ImageService.lab1,
            'open': data['open'] ?? true,
            'price': data['price'] ?? '0',
            'tests': data['tests'] ?? [],
          };
        }).toList();
      } else {
        _loadFallbackLabs();
      }
    } catch (e) {
      _loadFallbackLabs();
    }
    setState(() => _isLoading = false);
  }

  void _loadFallbackLabs() {
    _labs = [
      {'id': '1', 'name': 'مختبرات الذبحاني', 'category': 'تحاليل عامة', 'address': 'صنعاء - شارع الأصبحي', 'rating': 4.9, 'reviews': 328, 'phone': '01-234567', 'image': ImageService.lab1, 'open': true, 'price': '100-500', 'tests': ['CBC', 'سكر', 'دهون']},
      {'id': '2', 'name': 'مختبرات العولقي', 'category': 'دم', 'address': 'صنعاء - شارع الستين', 'rating': 4.8, 'reviews': 256, 'phone': '01-234568', 'image': ImageService.lab2, 'open': true, 'price': '150-600', 'tests': ['CBC', 'حديد', 'فيتامين د']},
      {'id': '3', 'name': 'مختبرات المأمون', 'category': 'هرمونات', 'address': 'صنعاء - حدة', 'rating': 4.7, 'reviews': 189, 'phone': '01-234569', 'image': ImageService.lab3, 'open': true, 'price': '200-800', 'tests': ['TSH', 'T3', 'T4']},
      {'id': '4', 'name': 'مختبر الرازي', 'category': 'فيتامينات', 'address': 'صنعاء - باب اليمن', 'rating': 4.6, 'reviews': 89, 'phone': '01-234570', 'image': ImageService.lab1, 'open': false, 'price': '100-400', 'tests': ['فيتامين د', 'فيتامين ب12']},
    ];
  }

  List<Map<String, dynamic>> get _filteredLabs {
    var filtered = _labs;
    if (_selectedCategory != 'الكل') {
      filtered = filtered.where((l) => l['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((l) =>
        l['name'].contains(_searchQuery) ||
        l['address'].contains(_searchQuery)
      ).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المختبرات'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ شريط البحث المدمج
                Padding(
                  padding: const EdgeInsets.all(12),
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
                        Icon(Icons.search, color: isDark ? Colors.grey : Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'ابحث عن مختبر...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey : Colors.grey,
                              ),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          ),
                      ],
                    ),
                  ),
                ),

                // ✅ قائمة التصنيفات
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = category),
                          backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                          selectedColor: primaryColor.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: isSelected ? primaryColor : (isDark ? Colors.white : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ قائمة المختبرات
                Expanded(
                  child: _filteredLabs.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredLabs.length,
                          itemBuilder: (context, index) {
                            final lab = _filteredLabs[index];
                            return _buildLabCard(lab, isDark, primaryColor);
                          },
                        ),
                ),
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
            builder: (_) => LabBookingScreen(labId: lab['id'] as String),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // ✅ صورة المختبر
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: buildBannerImage(lab['image'], height: 60),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lab['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lab['address'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${lab['rating']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${lab['reviews']})',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: lab['open'] == true ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lab['open'] == true ? 'مفتوح' : 'مغلق',
                          style: TextStyle(
                            fontSize: 9,
                            color: lab['open'] == true ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${lab['rating']} ⭐',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    lab['price'],
                    style: TextStyle(
                      fontSize: 10,
                      color: primaryColor,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: isDark ? Colors.grey : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مختبرات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'حاول تغيير معايير البحث',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث عن مختبر'),
        content: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'ابحث بالاسم أو الموقع...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }
}
