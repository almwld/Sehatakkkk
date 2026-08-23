import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_detail_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class PharmacyScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const PharmacyScreen({super.key, this.scrollController});
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = true;

  final List<String> _categories = [
    'الكل', 'مسكنات', 'مضادات حيوية', 'فيتامينات', 'مكملات غذائية',
    'أدوية ضغط', 'أدوية سكر', 'أجهزة طبية', 'عناية بالبشرة', 'منتجات أطفال'
  ];

  final List<Map<String, dynamic>> _pharmacies = [
    {'id': 'p1', 'name': 'صيدلية ابن حيان', 'address': 'صنعاء - شارع حدة', 'rating': 4.9, 'reviews': 450, 'phone': '01-234580', 'image': ImageKit.pharmacy1, 'open': true, 'delivery': true, 'distance': '1.2 كم', 'workingHours': '8:00 ص - 11:00 م'},
    {'id': 'p2', 'name': 'عالم الصيدلة', 'address': 'صنعاء - شارع الستين', 'rating': 4.8, 'reviews': 380, 'phone': '01-234581', 'image': ImageKit.pharmacy2, 'open': true, 'delivery': true, 'distance': '2.5 كم', 'workingHours': '9:00 ص - 12:00 م'},
    {'id': 'p3', 'name': 'صيدلية النهضة', 'address': 'صنعاء - باب اليمن', 'rating': 4.7, 'reviews': 320, 'phone': '01-234582', 'image': ImageKit.pharmacy3, 'open': true, 'delivery': false, 'distance': '3.8 كم', 'workingHours': '8:00 ص - 10:00 م'},
  ];

  final List<Map<String, dynamic>> _medicines = [
    {'id': 'm1', 'name': 'باراسيتامول 500 ملغ', 'category': 'مسكنات', 'price': 500, 'image': ImageKit.medicine1, 'pharmacy': 'صيدلية ابن حيان', 'rating': 4.8, 'discount': 20, 'prescription': false, 'stock': 50},
    {'id': 'm2', 'name': 'فيتامين د 1000 وحدة دولية', 'category': 'فيتامينات', 'price': 1200, 'image': ImageKit.medicine2, 'pharmacy': 'عالم الصيدلة', 'rating': 4.7, 'discount': 15, 'prescription': false, 'stock': 30},
    {'id': 'm3', 'name': 'أموكسيسيلين 500 ملغ', 'category': 'مضادات حيوية', 'price': 1500, 'image': ImageKit.medicine4, 'pharmacy': 'صيدلية ابن حيان', 'rating': 4.5, 'discount': 0, 'prescription': true, 'stock': 20},
    {'id': 'm4', 'name': 'ديكلوفيناك 50 ملغ', 'category': 'مسكنات', 'price': 650, 'image': ImageKit.medicine1, 'pharmacy': 'صيدلية النهضة', 'rating': 4.6, 'discount': 5, 'prescription': true, 'stock': 40},
    {'id': 'm5', 'name': 'مكمل أوميغا 3', 'category': 'مكملات غذائية', 'price': 1500, 'image': ImageKit.medicine3, 'pharmacy': 'عالم الصيدلة', 'rating': 4.9, 'discount': 10, 'prescription': false, 'stock': 25},
    {'id': 'm6', 'name': 'لوسارتان 50 ملغ', 'category': 'أدوية ضغط', 'price': 800, 'image': ImageKit.medicine2, 'pharmacy': 'صيدلية ابن حيان', 'rating': 4.6, 'discount': 0, 'prescription': true, 'stock': 35},
    {'id': 'm7', 'name': 'ميتفورمين 500 ملغ', 'category': 'أدوية سكر', 'price': 600, 'image': ImageKit.medicine4, 'pharmacy': 'صيدلية النهضة', 'rating': 4.5, 'discount': 0, 'prescription': true, 'stock': 40},
    {'id': 'm8', 'name': 'جهاز قياس ضغط رقمي', 'category': 'أجهزة طبية', 'price': 8500, 'image': ImageKit.medicine3, 'pharmacy': 'عالم الصيدلة', 'rating': 4.9, 'discount': 10, 'prescription': false, 'stock': 10},
  ];

  final List<Map<String, dynamic>> _supplies = [
    {'id': 's1', 'name': 'جهاز قياس ضغط رقمي', 'price': 8500, 'image': ImageKit.medicine3, 'category': 'أجهزة', 'rating': 4.9, 'stock': 10},
    {'id': 's2', 'name': 'جهاز قياس سكر الدم', 'price': 6500, 'image': ImageKit.medicine4, 'category': 'أجهزة', 'rating': 4.8, 'stock': 8},
    {'id': 's3', 'name': 'ميزان حرارة رقمي', 'price': 3500, 'image': ImageKit.medicine1, 'category': 'أجهزة', 'rating': 4.6, 'stock': 15},
    {'id': 's4', 'name': 'ضمادات طبية', 'price': 250, 'image': ImageKit.medicine2, 'category': 'مستهلكات', 'rating': 4.5, 'stock': 100},
    {'id': 's5', 'name': 'شاش طبي', 'price': 180, 'image': ImageKit.medicine3, 'category': 'مستهلكات', 'rating': 4.4, 'stock': 80},
  ];

  final List<Map<String, dynamic>> _beautyProducts = [
    {'id': 'b1', 'name': 'كريم ترطيب للبشرة', 'price': 1800, 'image': ImageKit.medicine1, 'category': 'عناية بالبشرة', 'rating': 4.7, 'stock': 40},
    {'id': 'b2', 'name': 'غسول للبشرة الدهنية', 'price': 1500, 'image': ImageKit.medicine2, 'category': 'عناية بالبشرة', 'rating': 4.6, 'stock': 35},
    {'id': 'b3', 'name': 'واقي شمس SPF 50', 'price': 2200, 'image': ImageKit.medicine3, 'category': 'عناية بالبشرة', 'rating': 4.8, 'stock': 30},
    {'id': 'b4', 'name': 'شامبو للأطفال', 'price': 1200, 'image': ImageKit.medicine4, 'category': 'عناية بالطفل', 'rating': 4.8, 'stock': 45},
    {'id': 'b5', 'name': 'حفاضات أطفال', 'price': 2500, 'image': ImageKit.medicine1, 'category': 'عناية بالطفل', 'rating': 4.9, 'stock': 60},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredPharmacies {
    if (_searchQuery.isEmpty) return _pharmacies;
    return _pharmacies.where((p) =>
      p['name'].toString().contains(_searchQuery) ||
      p['address'].toString().contains(_searchQuery)
    ).toList();
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    var list = _medicines;
    if (_searchQuery.isNotEmpty) {
      list = list.where((m) =>
        m['name'].toString().contains(_searchQuery) ||
        m['category'].toString().contains(_searchQuery) ||
        m['pharmacy'].toString().contains(_searchQuery)
      ).toList();
    }
    if (_selectedCategory != 'الكل') {
      list = list.where((m) => m['category'] == _selectedCategory).toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredSupplies {
    if (_searchQuery.isEmpty) return _supplies;
    return _supplies.where((s) =>
      s['name'].toString().contains(_searchQuery) ||
      s['category'].toString().contains(_searchQuery)
    ).toList();
  }

  List<Map<String, dynamic>> get _filteredBeauty {
    if (_searchQuery.isEmpty) return _beautyProducts;
    return _beautyProducts.where((b) =>
      b['name'].toString().contains(_searchQuery) ||
      b['category'].toString().contains(_searchQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الصيدلية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'صيدليات'),
            Tab(text: 'أدوية'),
            Tab(text: 'مستلزمات'),
            Tab(text: 'عناية'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 13),
        ),
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
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'نتيجة البحث: $_searchQuery',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _searchQuery = ''),
                          child: const Text('مسح'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPharmaciesTab(isDark),
                      _buildMedicinesTab(isDark),
                      _buildSuppliesTab(isDark),
                      _buildBeautyTab(isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // صيدليات
  Widget _buildPharmaciesTab(bool isDark) {
    final filtered = _filteredPharmacies;
    if (filtered.isEmpty) {
      return _buildEmptyState(isDark, 'لا توجد صيدليات');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final pharmacy = filtered[index];
        return _buildPharmacyCard(pharmacy, isDark);
      },
    );
  }

  Widget _buildPharmacyCard(Map<String, dynamic> pharmacy, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyDetailScreen(pharmacy: pharmacy),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
              child: AppImage(
                imageUrl: pharmacy['image'] as String,
                width: 70,
                height: 70,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pharmacy['address'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        pharmacy['rating'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        ' (${pharmacy['reviews']})',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: pharmacy['open'] ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pharmacy['open'] ? 'مفتوح' : 'مغلق',
                        style: TextStyle(
                          fontSize: 11,
                          color: pharmacy['open'] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (pharmacy['delivery'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.delivery_dining, size: 12, color: Colors.blue),
                              const SizedBox(width: 2),
                              Text(
                                'توصيل',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
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
                          pharmacy['distance'],
                          style: TextStyle(
                            fontSize: 12,
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

  // أدوية
  Widget _buildMedicinesTab(bool isDark) {
    return Column(
      children: [
        Container(
          height: 42,
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
        Expanded(
          child: _filteredMedicines.isEmpty
              ? _buildEmptyState(isDark, 'لا توجد أدوية')
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _filteredMedicines[index];
                    return _buildMedicineCard(medicine, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, bool isDark) {
    final hasDiscount = medicine['discount'] > 0;
    final priceAfterDiscount = hasDiscount ? medicine['price'] * (1 - medicine['discount'] / 100) : medicine['price'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppImage(
              imageUrl: medicine['image'] as String,
              width: 50,
              height: 50,
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
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
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
                        borderRadius: BorderRadius.circular(4),
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
                  medicine['pharmacy'],
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
                      child: const Row(
                        children: [
                          Icon(Icons.add_shopping_cart, size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
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

  // مستلزمات
  Widget _buildSuppliesTab(bool isDark) {
    final filtered = _filteredSupplies;
    if (filtered.isEmpty) {
      return _buildEmptyState(isDark, 'لا توجد مستلزمات');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildSupplyCard(item, isDark);
      },
    );
  }

  Widget _buildSupplyCard(Map<String, dynamic> item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AppImage(
                imageUrl: item['image'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
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
                          item['category'],
                          style: const TextStyle(fontSize: 8, color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            item['rating'].toString(),
                            style: TextStyle(
                              fontSize: 9,
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
                        '${item['price']} ر.ي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 16),
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

  // عناية
  Widget _buildBeautyTab(bool isDark) {
    final filtered = _filteredBeauty;
    if (filtered.isEmpty) {
      return _buildEmptyState(isDark, 'لا توجد منتجات عناية');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildBeautyCard(item, isDark);
      },
    );
  }

  Widget _buildBeautyCard(Map<String, dynamic> item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AppImage(
                imageUrl: item['image'] as String,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
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
                          item['category'],
                          style: const TextStyle(fontSize: 8, color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            item['rating'].toString(),
                            style: TextStyle(
                              fontSize: 9,
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
                        '${item['price']} ر.ي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 16),
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

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'الكل';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة تعيين'),
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
          title: const Text('بحث في الصيدلية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => tempSearch = value,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن دواء، صيدلية، مستلزمات...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ],
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
