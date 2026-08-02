import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
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
    'ميكروبيولوجي',
  ];

  final List<Map<String, dynamic>> _mockLabs = [
    {'id': '1', 'name': 'مختبرات الذبحاني', 'category': 'تحاليل عامة', 'address': 'صنعاء - شارع الأصبحي', 'rating': 4.9, 'reviews': 328, 'phone': '01-234567', 'image': ImageKit.lab1, 'open': true, 'price': '100-500', 'tests': ['CBC', 'سكر', 'دهون']},
    {'id': '2', 'name': 'مختبرات العولقي', 'category': 'دم', 'address': 'صنعاء - شارع الستين', 'rating': 4.8, 'reviews': 256, 'phone': '01-234568', 'image': ImageKit.lab2, 'open': true, 'price': '150-600', 'tests': ['CBC', 'حديد', 'فيتامين د']},
    {'id': '3', 'name': 'مختبرات المأمون', 'category': 'هرمونات', 'address': 'صنعاء - حدة', 'rating': 4.7, 'reviews': 189, 'phone': '01-234569', 'image': ImageKit.lab3, 'open': true, 'price': '200-800', 'tests': ['TSH', 'T3', 'T4']},
    {'id': '4', 'name': 'مختبر الرازي', 'category': 'فيتامينات', 'address': 'صنعاء - باب اليمن', 'rating': 4.6, 'reviews': 89, 'phone': '01-234570', 'image': ImageKit.lab1, 'open': false, 'price': '100-400', 'tests': ['فيتامين د', 'فيتامين ب12']},
    {'id': '5', 'name': 'مختبرات النخبة', 'category': 'دم', 'address': 'صنعاء - التحرير', 'rating': 4.5, 'reviews': 145, 'phone': '01-234571', 'image': ImageKit.lab2, 'open': true, 'price': '120-550', 'tests': ['CBC', 'سكر', 'دهون']},
    {'id': '6', 'name': 'مختبرات اليمن الحديثة', 'category': 'أشعة', 'address': 'صنعاء - شارع الزبيري', 'rating': 4.4, 'reviews': 112, 'phone': '01-234572', 'image': ImageKit.lab3, 'open': true, 'price': '200-900', 'tests': ['أشعة', 'سونار']},
  ];

  @override
  void initState() {
    super.initState();
    _loadLabs();
  }

  Future<void> _loadLabs() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _labs = _mockLabs;
    setState(() => _isLoading = false);
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
    final filtered = _filteredLabs;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المختبرات'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ شريط البحث
                Padding(
                  padding: const EdgeInsets.all(12),
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
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'ابحث عن مختبر...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 18, color: isDark ? Colors.grey[400] : Colors.grey),
                            onPressed: () => setState(() => _searchQuery = ''),
                          ),
                      ],
                    ),
                  ),
                ),
                // ✅ التصنيفات
                SizedBox(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(category, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = category),
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
                            final lab = filtered[index];
                            return _buildLabCard(lab, isDark);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildLabCard(Map<String, dynamic> lab, bool isDark) {
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
                url: lab['image'],
                width: 70,
                height: 70,
              ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lab['category'],
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
                            lab['rating'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
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
                          color: lab['open'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: lab['open'] ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lab['open'] ? 'مفتوح' : 'مغلق',
                              style: TextStyle(
                                color: lab['open'] ? Colors.green : Colors.red,
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
                          lab['price'],
                          style: TextStyle(
                            fontSize: 11,
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
          Icon(Icons.science_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
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
          title: const Text('البحث عن مختبر'),
          content: TextField(
            onChanged: (value) => tempSearch = value,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'ابحث بالاسم أو الموقع...',
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
