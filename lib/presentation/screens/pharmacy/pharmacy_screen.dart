import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/data/models/medication_data.dart';
import 'package:sehatak/data/models/pharmacy_data.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_details_screen.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'الكل';
  String _selectedType = 'الكل';

  final List<String> _categories = [
    'الكل', 'مسكنات', 'مضادات حيوية', 'فيتامينات', 'قلب وضغط', 
    'سكري', 'جهاز تنفسي', 'جهاز هضمي', 'مستحضرات تجميل', 
    'مستلزمات صحية', 'مكملات غذائية'
  ];

  final List<String> _types = ['الكل', 'دواء', 'تجميل', 'جهاز', 'مكمل'];

  final Map<String, int> _cart = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMedications {
    var list = MedicationData.medications;
    if (_selectedCategory != 'الكل') {
      list = list.where((m) => m['category'] == _selectedCategory).toList();
    }
    if (_selectedType != 'الكل') {
      list = list.where((m) => m['type'] == _selectedType).toList();
    }
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      list = list.where((m) => m['name'].toLowerCase().contains(q) || m['brand'].toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<Map<String, dynamic>> get _filteredPharmacies {
    var list = PharmacyData.pharmacies;
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      list = list.where((p) => p['name'].toLowerCase().contains(q) || p['address'].toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int _getCartCount() => _cart.values.fold(0, (a, b) => a + b);
  int _getCartTotal() {
    int total = 0;
    for (final entry in _cart.entries) {
      final med = MedicationData.medications.firstWhere((m) => m['id'] == entry.key);
      total += (med['price'] as int) * entry.value;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصيدلية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: '💊 المنتجات'),
                Tab(text: '🏥 الصيدليات'),
              ],
            ),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _checkout,
              ),
              if (_getCartCount() > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_getCartCount()}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          if (_tabCtrl.index == 0) _buildFilters(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildProductsTab(isDark),
                _buildPharmaciesTab(isDark),
              ],
            ),
          ),
          if (_getCartCount() > 0) _buildCartBar(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن دواء، منتج، صيدلية...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          // ✅ تصنيفات المنتجات
          SizedBox(
            height: 35,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, index) {
                final cat = _categories[index];
                final sel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 10,
                        color: sel ? Colors.white : AppColors.darkGrey,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          // ✅ أنواع المنتجات
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, index) {
                final type = _types[index];
                final sel = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: sel ? AppColors.primary : Colors.grey[300]!),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 9,
                        color: sel ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(bool isDark) {
    final items = _filteredMedications;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final inCart = _cart[item['id']] ?? 0;
        return _buildProductCard(item, inCart, isDark);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, int inCart, bool isDark) {
    final isCosmetic = item['type'] == 'تجميل';
    final isDevice = item['type'] == 'جهاز';
    final color = isCosmetic ? AppColors.pink : isDevice ? AppColors.info : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: isDark ? const Color(0xFF2D3A54) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: item['image'],
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 100, color: Colors.grey[300]),
              errorWidget: (_, __, ___) => Container(
                height: 100,
                color: color.withOpacity(0.3),
                child: Icon(Icons.medication, color: color, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['type'] == 'دواء' ? '💊' : item['type'] == 'تجميل' ? '💄' : item['type'] == 'جهاز' ? '📟' : '🧪',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(item['brand'], style: const TextStyle(fontSize: 9, color: AppColors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item['price']} ر.ي',
                      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                    ),
                    const Spacer(),
                    if (item['prescription'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('بوصفة', style: TextStyle(fontSize: 7, color: AppColors.warning)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: inCart > 0 ? () => setState(() {
                        if (inCart == 1) _cart.remove(item['id']);
                        else _cart[item['id']] = inCart - 1;
                      }) : null,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove, color: AppColors.primary, size: 14),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('$inCart', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _cart[item['id']] = inCart + 1),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 14),
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

  Widget _buildPharmaciesTab(bool isDark) {
    final pharmacies = _filteredPharmacies;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pharmacies.length,
      itemBuilder: (context, index) {
        final ph = pharmacies[index];
        return _buildPharmacyCard(ph, isDark);
      },
    );
  }

  Widget _buildPharmacyCard(Map<String, dynamic> ph, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyDetailsScreen(pharmacy: ph),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          border: Border.all(color: isDark ? const Color(0xFF2D3A54) : Colors.transparent),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: ph['image'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(width: 70, height: 70, color: Colors.grey[300]),
                errorWidget: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.local_pharmacy, size: 30, color: AppColors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ph['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(ph['address'], style: const TextStyle(fontSize: 10, color: AppColors.grey), maxLines: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.amber),
                      Text(' ${ph['rating']} (${ph['reviews']})', style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: ph['open'] ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ph['open'] ? 'مفتوح' : 'مغلق',
                          style: TextStyle(fontSize: 8, color: ph['open'] ? AppColors.success : AppColors.error),
                        ),
                      ),
                      if (ph['delivery'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('توصيل', style: TextStyle(fontSize: 8, color: AppColors.info)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D33) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_getCartCount()} منتجات', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  Text('${_getCartTotal()} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary)),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _checkout,
                icon: const Icon(Icons.delivery_dining),
                label: const Text('إتمام الطلب', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkout() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السلة فارغة')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ تم إتمام الطلب بنجاح! المبلغ: ${_getCartTotal()} ريال'), backgroundColor: AppColors.success),
    );
    setState(() => _cart.clear());
  }
}
