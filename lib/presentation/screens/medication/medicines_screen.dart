import 'package:sehatak/presentation/widgets/app_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  String _selectedSort = 'الاسم';

  final List<String> _categories = [
    'الكل', 'مسكنات', 'مضادات حيوية', 'فيتامينات', 'مكملات غذائية', 'أدوية ضغط', 'أدوية سكر'
  ];

  final List<Map<String, dynamic>> _medicines = [
    {'id': '1', 'name': 'باراسيتامول 500mg', 'category': 'مسكنات', 'price': 500, 'image': ImageKit.medicine1, 'inStock': true, 'rating': 4.8, 'reviews': 328},
    {'id': '2', 'name': 'فيتامين د 1000IU', 'category': 'فيتامينات', 'price': 1200, 'image': ImageKit.medicine2, 'inStock': true, 'rating': 4.7, 'reviews': 256},
    {'id': '3', 'name': 'جهاز قياس ضغط', 'category': 'مكملات غذائية', 'price': 8500, 'image': ImageKit.medicine3, 'inStock': true, 'rating': 4.9, 'reviews': 189},
    {'id': '4', 'name': 'أموكسيسيلين 500mg', 'category': 'مضادات حيوية', 'price': 1500, 'image': ImageKit.medicine4, 'inStock': true, 'rating': 4.5, 'reviews': 145},
    {'id': '5', 'name': 'ديكلوفيناك 50mg', 'category': 'مسكنات', 'price': 650, 'image': ImageKit.medicine1, 'inStock': true, 'rating': 4.6, 'reviews': 210},
    {'id': '6', 'name': 'نابروكسين 250mg', 'category': 'مسكنات', 'price': 550, 'image': ImageKit.medicine2, 'inStock': true, 'rating': 4.4, 'reviews': 98},
    {'id': '7', 'name': 'أسبرين 100mg', 'category': 'مسكنات', 'price': 300, 'image': ImageKit.medicine3, 'inStock': false, 'rating': 4.3, 'reviews': 76},
    {'id': '8', 'name': 'إيبوبروفين 400mg', 'category': 'مسكنات', 'price': 750, 'image': ImageKit.medicine4, 'inStock': true, 'rating': 4.7, 'reviews': 312},
    {'id': '9', 'name': 'لوسارتان 50mg', 'category': 'أدوية ضغط', 'price': 800, 'image': ImageKit.medicine1, 'inStock': true, 'rating': 4.6, 'reviews': 178},
    {'id': '10', 'name': 'ميتفورمين 500mg', 'category': 'أدوية سكر', 'price': 600, 'image': ImageKit.medicine2, 'inStock': true, 'rating': 4.5, 'reviews': 156},
    {'id': '11', 'name': 'فيتامين سي 1000mg', 'category': 'فيتامينات', 'price': 800, 'image': ImageKit.medicine3, 'inStock': true, 'rating': 4.8, 'reviews': 420},
    {'id': '12', 'name': 'مكمل أوميغا 3', 'category': 'مكملات غذائية', 'price': 1500, 'image': ImageKit.medicine4, 'inStock': true, 'rating': 4.9, 'reviews': 289},
  ];

  List<Map<String, dynamic>> get _filteredMedicines {
    var list = _medicines;
    if (_searchQuery.isNotEmpty) {
      list = list.where((m) =>
        m['name'].toString().contains(_searchQuery) ||
        m['category'].toString().contains(_searchQuery)
      ).toList();
    }
    if (_selectedCategory != 'الكل') {
      list = list.where((m) => m['category'] == _selectedCategory).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredMedicines;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الأدوية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ التصنيفات
          Container(
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
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final medicine = filtered[index];
                      return _buildMedicineCard(medicine, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, bool isDark) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ الصورة
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AppImage(
                imageUrl: medicine['image'],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ✅ المعلومات
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    medicine['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          medicine['category'],
                          style: const TextStyle(fontSize: 8, color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            medicine['rating'].toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${medicine['price']} ر.ي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: medicine['inStock'] ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا توجد أدوية',
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
          title: const Text('بحث عن دواء'),
          content: TextField(
            onChanged: (value) => tempSearch = value,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل اسم الدواء...',
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ترتيب حسب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...['الاسم', 'السعر (منخفض)', 'السعر (مرتفع)'].map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedSort,
                      onChanged: (value) {
                        setStateSheet(() => _selectedSort = value!);
                        setState(() {});
                        Navigator.pop(context);
                      },
                      activeColor: AppColors.primary,
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
