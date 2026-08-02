import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = true;
  List<Map<String, dynamic>> _medicines = [];

  final List<String> _categories = [
    'الكل', 'مسكنات', 'مضادات حيوية', 'فيتامينات', 'أجهزة طبية', 'مضادات التهابية', 'مكملات غذائية'
  ];

  final List<Map<String, dynamic>> _mockMedicines = [
    {'id': '1', 'name': 'باراسيتامول 500mg', 'category': 'مسكنات', 'price': 500, 'image': ImageKit.medicine1, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 50, 'unit': 'قرص', 'rating': 4.8, 'discount': 20, 'prescription': false},
    {'id': '2', 'name': 'فيتامين د 1000IU', 'category': 'فيتامينات', 'price': 1200, 'image': ImageKit.medicine2, 'pharmacyName': 'عالم الصيدلة', 'stock': 30, 'unit': 'كبسولة', 'rating': 4.7, 'discount': 15, 'prescription': false},
    {'id': '3', 'name': 'جهاز قياس ضغط', 'category': 'أجهزة طبية', 'price': 8500, 'image': ImageKit.medicine3, 'pharmacyName': 'صيدلية النهضة', 'stock': 10, 'unit': 'جهاز', 'rating': 4.9, 'discount': 10, 'prescription': false},
    {'id': '4', 'name': 'أموكسيسيلين 500mg', 'category': 'مضادات حيوية', 'price': 1500, 'image': ImageKit.medicine4, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 20, 'unit': 'كبسولة', 'rating': 4.5, 'discount': 0, 'prescription': true},
    {'id': '5', 'name': 'ديكلوفيناك 50mg', 'category': 'مسكنات', 'price': 650, 'image': ImageKit.medicine1, 'pharmacyName': 'صيدلية النهضة', 'stock': 40, 'unit': 'قرص', 'rating': 4.6, 'discount': 5, 'prescription': true},
    {'id': '6', 'name': 'نابروكسين 250mg', 'category': 'مضادات التهابية', 'price': 550, 'image': ImageKit.medicine2, 'pharmacyName': 'عالم الصيدلة', 'stock': 35, 'unit': 'قرص', 'rating': 4.4, 'discount': 0, 'prescription': false},
    {'id': '7', 'name': 'أسبرين 100mg', 'category': 'مسكنات', 'price': 300, 'image': ImageKit.medicine3, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 60, 'unit': 'قرص', 'rating': 4.3, 'discount': 25, 'prescription': false},
    {'id': '8', 'name': 'إيبوبروفين 400mg', 'category': 'مضادات التهابية', 'price': 750, 'image': ImageKit.medicine4, 'pharmacyName': 'صيدلية النهضة', 'stock': 25, 'unit': 'قرص', 'rating': 4.7, 'discount': 0, 'prescription': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _medicines = _mockMedicines;
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    var list = _medicines;
    if (_searchQuery.isNotEmpty) {
      list = list.where((m) =>
        m['name'].toString().contains(_searchQuery) ||
        m['category'].toString().contains(_searchQuery) ||
        m['pharmacyName'].toString().contains(_searchQuery)
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
        title: const Text('الصيدلية'),
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
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن دواء...',
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
                ),
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
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
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
    final hasDiscount = medicine['discount'] > 0;
    final priceAfterDiscount = hasDiscount ? medicine['price'] * (1 - medicine['discount'] / 100) : medicine['price'];

    return Container(
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
              url: medicine['image'],
              width: 70,
              height: 70,
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
                        medicine['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (medicine['prescription'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'وصفة',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        medicine['category'],
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
                          medicine['rating'].toString(),
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
                const SizedBox(height: 2),
                Text(
                  medicine['pharmacyName'],
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
                    if (hasDiscount) ...[
                      Text(
                        '${medicine['price']} ر.ي',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'خصم ${medicine['discount']}%',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '${priceAfterDiscount.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_shopping_cart, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'أضف',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
}
