import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/providers/cart_provider.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_detail_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = true;
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _pharmacies = [];
  List<Map<String, dynamic>> _medicalSupplies = [];
  List<Map<String, dynamic>> _beautyProducts = [];

  final List<String> _tabs = ['صيدليات', 'أدوية', 'مستلزمات', 'عناية'];

  // ✅ بيانات الصيدليات
  final List<Map<String, dynamic>> _mockPharmacies = [
    {'id': '1', 'name': 'صيدلية ابن حيان', 'address': 'صنعاء - شارع حدة', 'rating': 4.9, 'reviews': 450, 'phone': '01-234580', 'image': ImageKit.pharmacy1, 'open': true, 'delivery': true, 'distance': '1.2 كم'},
    {'id': '2', 'name': 'صيدلية عالم الصيدلة', 'address': 'صنعاء - شارع الستين', 'rating': 4.8, 'reviews': 380, 'phone': '01-234581', 'image': ImageKit.pharmacy2, 'open': true, 'delivery': true, 'distance': '2.5 كم'},
    {'id': '3', 'name': 'صيدلية النهضة', 'address': 'صنعاء - باب اليمن', 'rating': 4.7, 'reviews': 320, 'phone': '01-234582', 'image': ImageKit.pharmacy3, 'open': true, 'delivery': false, 'distance': '3.8 كم'},
    {'id': '4', 'name': 'صيدلية الشفاء', 'address': 'صنعاء - شارع الزبيري', 'rating': 4.6, 'reviews': 280, 'phone': '01-234583', 'image': ImageKit.pharmacy1, 'open': false, 'delivery': true, 'distance': '4.1 كم'},
    {'id': '5', 'name': 'صيدلية الأمانة', 'address': 'صنعاء - التحرير', 'rating': 4.5, 'reviews': 210, 'phone': '01-234584', 'image': ImageKit.pharmacy2, 'open': true, 'delivery': true, 'distance': '5.0 كم'},
    {'id': '6', 'name': 'صيدلية اليمن الحديثة', 'address': 'صنعاء - حدة', 'rating': 4.4, 'reviews': 180, 'phone': '01-234585', 'image': ImageKit.pharmacy3, 'open': true, 'delivery': false, 'distance': '6.2 كم'},
  ];

  // ✅ بيانات الأدوية
  final List<Map<String, dynamic>> _mockMedicines = [
    {'id': 'm1', 'name': 'باراسيتامول 500mg', 'category': 'مسكنات', 'price': 500, 'image': ImageKit.medicine1, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 50, 'unit': 'قرص', 'rating': 4.8, 'discount': 20, 'prescription': false},
    {'id': 'm2', 'name': 'فيتامين د 1000IU', 'category': 'فيتامينات', 'price': 1200, 'image': ImageKit.medicine2, 'pharmacyName': 'عالم الصيدلة', 'stock': 30, 'unit': 'كبسولة', 'rating': 4.7, 'discount': 15, 'prescription': false},
    {'id': 'm3', 'name': 'أموكسيسيلين 500mg', 'category': 'مضادات حيوية', 'price': 1500, 'image': ImageKit.medicine4, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 20, 'unit': 'كبسولة', 'rating': 4.5, 'discount': 0, 'prescription': true},
    {'id': 'm4', 'name': 'ديكلوفيناك 50mg', 'category': 'مسكنات', 'price': 650, 'image': ImageKit.medicine1, 'pharmacyName': 'صيدلية النهضة', 'stock': 40, 'unit': 'قرص', 'rating': 4.6, 'discount': 5, 'prescription': true},
    {'id': 'm5', 'name': 'نابروكسين 250mg', 'category': 'مضادات التهابية', 'price': 550, 'image': ImageKit.medicine2, 'pharmacyName': 'عالم الصيدلة', 'stock': 35, 'unit': 'قرص', 'rating': 4.4, 'discount': 0, 'prescription': false},
    {'id': 'm6', 'name': 'أسبرين 100mg', 'category': 'مسكنات', 'price': 300, 'image': ImageKit.medicine3, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 60, 'unit': 'قرص', 'rating': 4.3, 'discount': 25, 'prescription': false},
    {'id': 'm7', 'name': 'إيبوبروفين 400mg', 'category': 'مضادات التهابية', 'price': 750, 'image': ImageKit.medicine4, 'pharmacyName': 'صيدلية النهضة', 'stock': 25, 'unit': 'قرص', 'rating': 4.7, 'discount': 0, 'prescription': false},
    {'id': 'm8', 'name': 'لوسارتان 50mg', 'category': 'أدوية ضغط', 'price': 800, 'image': ImageKit.medicine1, 'pharmacyName': 'عالم الصيدلة', 'stock': 30, 'unit': 'قرص', 'rating': 4.6, 'discount': 10, 'prescription': true},
    {'id': 'm9', 'name': 'ميتفورمين 500mg', 'category': 'أدوية سكر', 'price': 600, 'image': ImageKit.medicine2, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 40, 'unit': 'قرص', 'rating': 4.5, 'discount': 0, 'prescription': true},
    {'id': 'm10', 'name': 'فيتامين سي 1000mg', 'category': 'فيتامينات', 'price': 800, 'image': ImageKit.medicine3, 'pharmacyName': 'صيدلية النهضة', 'stock': 45, 'unit': 'قرص فوار', 'rating': 4.8, 'discount': 15, 'prescription': false},
    {'id': 'm11', 'name': 'مكمل أوميغا 3', 'category': 'مكملات غذائية', 'price': 1500, 'image': ImageKit.medicine4, 'pharmacyName': 'عالم الصيدلة', 'stock': 20, 'unit': 'كبسولة', 'rating': 4.9, 'discount': 10, 'prescription': false},
    {'id': 'm12', 'name': 'جلوكوفاج 500mg', 'category': 'أدوية سكر', 'price': 650, 'image': ImageKit.medicine1, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 35, 'unit': 'قرص', 'rating': 4.4, 'discount': 0, 'prescription': true},
  ];

  // ✅ المستلزمات الطبية
  final List<Map<String, dynamic>> _mockMedicalSupplies = [
    {'id': 's1', 'name': 'جهاز قياس ضغط رقمي', 'price': 8500, 'image': ImageKit.medicine3, 'category': 'أجهزة', 'rating': 4.9, 'stock': 10, 'discount': 10},
    {'id': 's2', 'name': 'جهاز قياس سكر الدم', 'price': 6500, 'image': ImageKit.medicine4, 'category': 'أجهزة', 'rating': 4.8, 'stock': 8, 'discount': 5},
    {'id': 's3', 'name': 'ميزان حرارة رقمي', 'price': 3500, 'image': ImageKit.medicine1, 'category': 'أجهزة', 'rating': 4.6, 'stock': 15, 'discount': 0},
    {'id': 's4', 'name': 'جهاز بخاخ (Nebulizer)', 'price': 12000, 'image': ImageKit.medicine2, 'category': 'أجهزة', 'rating': 4.7, 'stock': 5, 'discount': 15},
    {'id': 's5', 'name': 'ضمادات طبية (متنوعة)', 'price': 250, 'image': ImageKit.medicine3, 'category': 'مستهلكات', 'rating': 4.5, 'stock': 100, 'discount': 0},
    {'id': 's6', 'name': 'شاش طبي (لفة)', 'price': 180, 'image': ImageKit.medicine4, 'category': 'مستهلكات', 'rating': 4.4, 'stock': 80, 'discount': 0},
    {'id': 's7', 'name': 'لاصقات طبية', 'price': 120, 'image': ImageKit.medicine1, 'category': 'مستهلكات', 'rating': 4.3, 'stock': 120, 'discount': 0},
    {'id': 's8', 'name': 'قفازات طبية (100 قطعة)', 'price': 400, 'image': ImageKit.medicine2, 'category': 'مستهلكات', 'rating': 4.6, 'stock': 60, 'discount': 5},
  ];

  // ✅ منتجات العناية
  final List<Map<String, dynamic>> _mockBeautyProducts = [
    {'id': 'b1', 'name': 'كريم ترطيب للبشرة', 'price': 1800, 'image': ImageKit.medicine1, 'category': 'عناية بالبشرة', 'rating': 4.7, 'stock': 40, 'discount': 10},
    {'id': 'b2', 'name': 'غسول للبشرة الدهنية', 'price': 1500, 'image': ImageKit.medicine2, 'category': 'عناية بالبشرة', 'rating': 4.6, 'stock': 35, 'discount': 5},
    {'id': 'b3', 'name': 'كريم واقي شمس SPF 50', 'price': 2200, 'image': ImageKit.medicine3, 'category': 'عناية بالبشرة', 'rating': 4.8, 'stock': 30, 'discount': 15},
    {'id': 'b4', 'name': 'مصل فيتامين سي', 'price': 3500, 'image': ImageKit.medicine4, 'category': 'عناية بالبشرة', 'rating': 4.9, 'stock': 20, 'discount': 20},
    {'id': 'b5', 'name': 'شامبو للأطفال', 'price': 1200, 'image': ImageKit.medicine1, 'category': 'عناية بالطفل', 'rating': 4.8, 'stock': 45, 'discount': 0},
    {'id': 'b6', 'name': 'حفاضات أطفال (M)', 'price': 2500, 'image': ImageKit.medicine2, 'category': 'عناية بالطفل', 'rating': 4.9, 'stock': 60, 'discount': 10},
    {'id': 'b7', 'name': 'زيت تدليك للأطفال', 'price': 1200, 'image': ImageKit.medicine3, 'category': 'عناية بالطفل', 'rating': 4.7, 'stock': 30, 'discount': 0},
    {'id': 'b8', 'name': 'كريم حفاض للأطفال', 'price': 1500, 'image': ImageKit.medicine4, 'category': 'عناية بالطفل', 'rating': 4.6, 'stock': 40, 'discount': 5},
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
    await Future.delayed(const Duration(milliseconds: 500));
    _medicines = _mockMedicines;
    _pharmacies = _mockPharmacies;
    _medicalSupplies = _mockMedicalSupplies;
    _beautyProducts = _mockBeautyProducts;
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredPharmacies {
    var list = _pharmacies;
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) =>
        p['name'].toString().contains(_searchQuery) ||
        p['address'].toString().contains(_searchQuery)
      ).toList();
    }
    return list;
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

  List<Map<String, dynamic>> get _filteredSupplies {
    var list = _medicalSupplies;
    if (_searchQuery.isNotEmpty) {
      list = list.where((s) =>
        s['name'].toString().contains(_searchQuery) ||
        s['category'].toString().contains(_searchQuery)
      ).toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredBeauty {
    var list = _beautyProducts;
    if (_searchQuery.isNotEmpty) {
      list = list.where((b) =>
        b['name'].toString().contains(_searchQuery) ||
        b['category'].toString().contains(_searchQuery)
      ).toList();
    }
    return list;
  }

  void _openPharmacyDetail(Map<String, dynamic> pharmacy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PharmacyDetailScreen(pharmacy: pharmacy),
      ),
    );
  }

  void _toggleCartItem(Map<String, dynamic> product, CartProvider cartProvider) {
    final isInCart = cartProvider.isInCart(product['id']);
    if (isInCart) {
      cartProvider.removeItem(product['id']);
      ToastService.showError(context, 'تم إزالة ${product['name']} من السلة');
    } else {
      cartProvider.addItem(
        CartItem(
          id: product['id'],
          name: product['name'],
          price: product['price'].toDouble(),
          image: product['image'],
          category: product['category'],
          discount: product['discount']?.toDouble(),
          pharmacyName: product['pharmacyName'],
          unit: product['unit'],
        ),
      );
      ToastService.showSuccess(context, '✅ تم إضافة ${product['name']} إلى السلة');
    }
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
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            isScrollable: true,
            indicatorWeight: 3,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                              hintText: 'ابحث عن دواء، صيدلية، مستلزمات...',
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

  // ============================================================
  // 🏪 تبويب الصيدليات
  // ============================================================
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
      onTap: () => _openPharmacyDetail(pharmacy),
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
                imageUrl: pharmacy['image'],
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
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
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
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: pharmacy['open'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
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
                                color: pharmacy['open'] ? Colors.green : Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (pharmacy['delivery'] == true)
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
                                  color: Colors.blue,
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
                          pharmacy['distance'],
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

  // ============================================================
  // 💊 تبويب الأدوية
  // ============================================================
  Widget _buildMedicinesTab(bool isDark) {
    final categories = ['الكل', 'مسكنات', 'مضادات حيوية', 'فيتامينات', 'أدوية ضغط', 'أدوية سكر', 'مكملات غذائية'];

    return Column(
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(category, style: TextStyle(fontSize: 11, color: isDark ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                  backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
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

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(medicine['id']);
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
                  imageUrl: medicine['image'],
                  width: 60,
                  height: 60,
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
                        if (medicine['prescription'] == true)
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
                        GestureDetector(
                          onTap: () => _toggleCartItem(medicine, cartProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isInCart ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                                  color: isInCart ? Colors.red : AppColors.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isInCart ? 'إزالة' : 'أضف',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isInCart ? Colors.red : AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  // ============================================================
  // 🩺 تبويب المستلزمات الطبية
  // ============================================================
  Widget _buildSuppliesTab(bool isDark) {
    final filtered = _filteredSupplies;
    if (filtered.isEmpty) {
      return _buildEmptyState(isDark, 'لا توجد مستلزمات طبية');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildSupplyCard(item, isDark);
      },
    );
  }

  Widget _buildSupplyCard(Map<String, dynamic> item, bool isDark) {
    final hasDiscount = item['discount'] > 0;
    final priceAfterDiscount = hasDiscount ? item['price'] * (1 - item['discount'] / 100) : item['price'];

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(item['id']);
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AppImage(
                    imageUrl: item['image'],
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  '${item['price']} ر.ي',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              Text(
                                '${priceAfterDiscount.toStringAsFixed(0)} ر.ي',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _toggleCartItem(item, cartProvider),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isInCart ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                                color: isInCart ? Colors.red : AppColors.primary,
                                size: 16,
                              ),
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
      },
    );
  }

  // ============================================================
  // 🧴 تبويب العناية
  // ============================================================
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildBeautyCard(item, isDark);
      },
    );
  }

  Widget _buildBeautyCard(Map<String, dynamic> item, bool isDark) {
    final hasDiscount = item['discount'] > 0;
    final priceAfterDiscount = hasDiscount ? item['price'] * (1 - item['discount'] / 100) : item['price'];

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isInCart = cartProvider.isInCart(item['id']);
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AppImage(
                    imageUrl: item['image'],
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount) ...[
                                Text(
                                  '${item['price']} ر.ي',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              Text(
                                '${priceAfterDiscount.toStringAsFixed(0)} ر.ي',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _toggleCartItem(item, cartProvider),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isInCart ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                                color: isInCart ? Colors.red : AppColors.primary,
                                size: 16,
                              ),
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
      },
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
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
        ],
      ),
    );
  }
}
