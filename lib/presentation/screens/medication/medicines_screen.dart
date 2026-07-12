import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'مسكنات',
    'مضادات حيوية',
    'أدوية ضغط',
    'أدوية سكر',
    'فيتامينات',
    'مكملات غذائية',
  ];

  final List<Map<String, dynamic>> _medicines = [
    {
      'id': '1',
      'name': 'باراسيتامول 500mg',
      'category': 'مسكنات',
      'price': 150,
      'description': 'مسكن للألم وخافض للحرارة',
      'image': "assets/images/medicines/medicine_1.png",
      'inStock': true,
    },
    {
      'id': '2',
      'name': 'أموكسيسيلين 500mg',
      'category': 'مضادات حيوية',
      'price': 250,
      'description': 'مضاد حيوي واسع المجال',
      'image': "assets/images/medicines/medicine_2.png",
      'inStock': true,
    },
    {
      'id': '3',
      'name': 'لوسارتان 50mg',
      'category': 'أدوية ضغط',
      'price': 180,
      'description': 'لعلاج ارتفاع ضغط الدم',
      'image': "assets/images/medicines/medicine_3.png",
      'inStock': true,
    },
    {
      'id': '4',
      'name': 'ميتفورمين 500mg',
      'category': 'أدوية سكر',
      'price': 200,
      'description': 'لعلاج السكري من النوع الثاني',
      'image': "assets/images/medicines/medicine_4.png",
      'inStock': false,
    },
    {
      'id': '5',
      'name': 'فيتامين C 1000mg',
      'category': 'فيتامينات',
      'price': 120,
      'description': 'مقوي للمناعة ومضاد للأكسدة',
      'image': "assets/images/medicines/medicine_1.png",
      'inStock': true,
    },
    {
      'id': '6',
      'name': 'أوميغا 3 1000mg',
      'category': 'مكملات غذائية',
      'price': 300,
      'description': 'مكمل غذائي لصحة القلب والدماغ',
      'image': "assets/images/medicines/medicine_2.png",
      'inStock': true,
    },
    {
      'id': '7',
      'name': 'إيبوبروفين 400mg',
      'category': 'مسكنات',
      'price': 170,
      'description': 'مسكن للآلام ومضاد للالتهابات',
      'image': "assets/images/medicines/medicine_3.png",
      'inStock': true,
    },
    {
      'id': '8',
      'name': 'أزيثروميسين 250mg',
      'category': 'مضادات حيوية',
      'price': 280,
      'description': 'مضاد حيوي لعلاج الالتهابات',
      'image': "assets/images/medicines/medicine_4.png",
      'inStock': true,
    },
    {
      'id': '9',
      'name': 'فيتامين D3 2000IU',
      'category': 'فيتامينات',
      'price': 140,
      'description': 'مقوي للعظام والمناعة',
      'image': "assets/images/medicines/medicine_1.png",
      'inStock': true,
    },
    {
      'id': '10',
      'name': 'زنك 50mg',
      'category': 'مكملات غذائية',
      'price': 110,
      'description': 'مقوي للمناعة وصحة الجلد',
      'image': "assets/images/medicines/medicine_1.png",
      'inStock': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredMedicines {
    return _medicines.where((medicine) {
      final nameMatch = medicine['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryMatch = _selectedCategory == 'الكل' || medicine['category'] == _selectedCategory;
      return nameMatch && categoryMatch;
    }).toList();
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
            icon: const Icon(Icons.shopping_cart_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ابحث عن دواء...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(
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
                      setState(() {
                        _selectedCategory = selected ? category : 'الكل';
                      });
                    },
                    backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_rounded,
                          size: 64,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد أدوية',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: medicine['image'],
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 70,
                height: 70,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.medication, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                width: 70,
                height: 70,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: const Icon(Icons.medication, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    medicine['category'],
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ الحل الصحيح: maxLines في Text وليس TextStyle
                Text(
                  medicine['description'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${medicine['price']} ريال',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: medicine['inStock'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  medicine['inStock'] ? 'متوفر' : 'غير متوفر',
                  style: TextStyle(
                    fontSize: 10,
                    color: medicine['inStock'] ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                color: AppColors.primary,
                onPressed: medicine['inStock'] ? () {} : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
