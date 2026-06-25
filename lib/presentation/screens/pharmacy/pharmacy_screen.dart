import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_options_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_details_screen.dart';
import 'package:sehatak/presentation/widgets/shimmer/shimmer_widgets.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _category = 'الكل';
  
  final Map<String, int> _cart = {};

  // ✅ الصيدليات في صنعاء
  final List<Map<String, dynamic>> _pharmacies = [
    {
      'id': 'ph1',
      'name': 'صيدلية الرحمة',
      'address': 'شارع حدة - أمام مستشفى الثورة',
      'phone': '01-234567',
      'rating': 4.8,
      'reviews': 156,
      'open': true,
      'delivery': true,
      'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=400',
      'distance': '1.2 كم',
    },
    {
      'id': 'ph2',
      'name': 'صيدلية النور',
      'address': 'شارع الستين - مقابل البنك المركزي',
      'phone': '01-345678',
      'rating': 4.7,
      'reviews': 128,
      'open': true,
      'delivery': true,
      'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=400',
      'distance': '2.5 كم',
    },
    {
      'id': 'ph3',
      'name': 'صيدلية الشفاء',
      'address': 'شارع الزراعة - بجوار مستشفى الكويت',
      'phone': '01-456789',
      'rating': 4.9,
      'reviews': 234,
      'open': true,
      'delivery': true,
      'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
      'distance': '0.8 كم',
    },
    {
      'id': 'ph4',
      'name': 'صيدلية الأمل',
      'address': 'حي التحرير - شارع الضباب',
      'phone': '01-567890',
      'rating': 4.5,
      'reviews': 89,
      'open': false,
      'delivery': true,
      'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=400',
      'distance': '3.1 كم',
    },
    {
      'id': 'ph5',
      'name': 'صيدلية اليمن',
      'address': 'شارع المطار - أمام الجامعة',
      'phone': '01-678901',
      'rating': 4.6,
      'reviews': 112,
      'open': true,
      'delivery': false,
      'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=400',
      'distance': '4.0 كم',
    },
    {
      'id': 'ph6',
      'name': 'صيدلية الصحة',
      'address': 'حي الروضة - شارع الثورة',
      'phone': '01-789012',
      'rating': 4.8,
      'reviews': 167,
      'open': true,
      'delivery': true,
      'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=400',
      'distance': '1.8 كم',
    },
    {
      'id': 'ph7',
      'name': 'صيدلية السلام',
      'address': 'شارع حدة - بجوار سوق الأحد',
      'phone': '01-890123',
      'rating': 4.4,
      'reviews': 76,
      'open': true,
      'delivery': true,
      'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=400',
      'distance': '2.2 كم',
    },
    {
      'id': 'ph8',
      'name': 'صيدلية الحياة',
      'address': 'حي الجراف - شارع الميثاق',
      'phone': '01-901234',
      'rating': 4.7,
      'reviews': 145,
      'open': false,
      'delivery': true,
      'image': 'https://images.unsplash.com/photo-1632833239869-a37e7a58066e?w=400',
      'distance': '3.5 كم',
    },
  ];

  // ✅ الأدوية والمنتجات
  final List<Map<String, dynamic>> _meds = [
    {'id': 'med-1', 'name': 'باراسيتامول 500mg', 'price': 500, 'category': 'مسكنات', 'inStock': true, 'requiresPrescription': false, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200', 'desc': 'مسكن للآلام وخافض للحرارة'},
    {'id': 'med-2', 'name': 'إيبوبروفين 400mg', 'price': 800, 'category': 'مسكنات', 'inStock': true, 'requiresPrescription': false, 'image': 'https://images.unsplash.com/photo-1550572012-edd7b1a7b51c?w=200', 'desc': 'مضاد للالتهاب ومسكن'},
    {'id': 'med-3', 'name': 'أموكسيسيلين 500mg', 'price': 1500, 'category': 'مضادات', 'inStock': true, 'requiresPrescription': true, 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=200', 'desc': 'مضاد حيوي واسع الطيف'},
    {'id': 'med-4', 'name': 'فيتامين د3 1000IU', 'price': 1200, 'category': 'فيتامينات', 'inStock': true, 'requiresPrescription': false, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200', 'desc': 'مكمل غذائي لصحة العظام'},
    {'id': 'med-5', 'name': 'أملوديبين 5mg', 'price': 2000, 'category': 'قلب', 'inStock': true, 'requiresPrescription': true, 'image': 'https://images.unsplash.com/photo-1586015555751-63e2b2f5a25b?w=200', 'desc': 'لعلاج ضغط الدم المرتفع'},
    {'id': 'med-6', 'name': 'ميتفورمين 500mg', 'price': 1000, 'category': 'سكري', 'inStock': true, 'requiresPrescription': true, 'image': 'https://images.unsplash.com/photo-1628771064730-9f8e4b3d7b3c?w=200', 'desc': 'لعلاج السكري من النوع الثاني'},
    {'id': 'med-7', 'name': 'مونتيلوكاست 10mg', 'price': 2500, 'category': 'تنفسي', 'inStock': false, 'requiresPrescription': true, 'image': 'https://images.unsplash.com/photo-1576602979108-6877b2f4f8d1?w=200', 'desc': 'لعلاج الربو والحساسية'},
    {'id': 'med-8', 'name': 'أزيثرومايسين 500mg', 'price': 3500, 'category': 'مضادات', 'inStock': true, 'requiresPrescription': true, 'image': 'https://images.unsplash.com/photo-1583911860205-72f8ac8dee0e?w=200', 'desc': 'مضاد حيوي للعدوى التنفسية'},
    {'id': 'med-9', 'name': 'بنادول إكسترا', 'price': 600, 'category': 'مسكنات', 'inStock': true, 'requiresPrescription': false, 'image': 'https://images.unsplash.com/photo-1632833239869-a37e7a58066e?w=200', 'desc': 'مسكن للصداع والآلام'},
    {'id': 'med-10', 'name': 'كالسيوم + مغنيسيوم', 'price': 1800, 'category': 'فيتامينات', 'inStock': true, 'requiresPrescription': false, 'image': 'https://images.unsplash.com/photo-1563213126-4276a5b3e1d7?w=200', 'desc': 'مكمل للعظام والعضلات'},
  ];

  int _getCartCount() => _cart.values.fold(0, (a, b) => a + b);
  int _getCartTotal() {
    int total = 0;
    for (final entry in _cart.entries) {
      final med = _meds.firstWhere((m) => m['id'] == entry.key);
      total += (med['price'] as int) * entry.value;
    }
    return total;
  }

  void _checkout() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryOptionsScreen(orderAmount: _getCartTotal().toDouble()),
      ),
    ).then((result) {
      if (result != null) {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم الطلب! التوصيل عبر ${result['company']} - ${result['time']}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final filtered = _category == 'الكل' 
        ? _meds 
        : _meds.where((m) => m['category'] == _category).toList();
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
                Tab(text: '🛒 المنتجات'),
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
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ✅ تبويب المنتجات
          _buildProductsTab(filtered, isDark),
          // ✅ تبويب الصيدليات
          _buildPharmaciesTab(isDark),
        ],
      ),
    );
  }

  // ============================================
  // 📦 تبويب المنتجات
  // ============================================
  Widget _buildProductsTab(List<Map<String, dynamic>> filtered, bool isDark) {
    return Column(
      children: [
        _buildSearchBar(isDark),
        _buildCategories(isDark),
        const SizedBox(height: 6),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filtered.length,
            itemBuilder: (c, i) {
              final m = filtered[i];
              final inCart = _cart[m['id']] ?? 0;
              return _buildProductCard(m, inCart, isDark);
            },
          ),
        ),
        if (_getCartCount() > 0) _buildCartBar(isDark),
      ],
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
            hintText: 'ابحث عن دواء...',
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

  Widget _buildCategories(bool isDark) {
    final cats = ['الكل', 'مسكنات', 'مضادات', 'فيتامينات', 'قلب', 'سكري', 'تنفسي'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (c, i) {
          final sel = _category == cats[i];
          return GestureDetector(
            onTap: () => setState(() => _category = cats[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : AppColors.surfaceContainerLow),
                borderRadius: BorderRadius.circular(10),
                boxShadow: sel ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)] : null,
              ),
              child: Text(
                cats[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppColors.darkGrey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> m, int inCart, bool isDark) {
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
              imageUrl: m['image'],
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ShimmerContainer(height: 100, borderRadius: 0),
              errorWidget: (_, __, ___) => Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.3), AppColors.primaryDark.withOpacity(0.3)]),
                ),
                child: const Center(child: Icon(Icons.medication, color: Colors.white, size: 40)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(m['desc'], style: const TextStyle(fontSize: 9, color: AppColors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (m['requiresPrescription'])
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('بوصفة', style: TextStyle(fontSize: 8, color: AppColors.warning)),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${m['price']} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
                    const Spacer(),
                    if (m['inStock'])
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: inCart > 0 ? () => setState(() {
                              if (inCart == 1) _cart.remove(m['id']);
                              else _cart[m['id']] = inCart - 1;
                            }) : null,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.remove, color: AppColors.primary, size: 16),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('$inCart', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _cart[m['id']] = inCart + 1),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text('غير متوفر', style: TextStyle(color: AppColors.error, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D33) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
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

  // ============================================
  // 🏥 تبويب الصيدليات
  // ============================================
  Widget _buildPharmaciesTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _pharmacies.length,
      itemBuilder: (context, index) {
        final ph = _pharmacies[index];
        return _buildPharmacyCard(ph, isDark);
      },
    );
  }

  Widget _buildPharmacyCard(Map<String, dynamic> ph, bool isDark) {
    return Container(
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
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.local_pharmacy, size: 40, color: AppColors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ph['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ph['address'],
                        style: const TextStyle(fontSize: 11, color: AppColors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(ph['phone'], style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppColors.amber),
                        const SizedBox(width: 2),
                        Text('${ph['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(' (${ph['reviews']})', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ph['open'] ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ph['open'] ? 'مفتوح 🟢' : 'مغلق 🔴',
                        style: TextStyle(
                          fontSize: 9,
                          color: ph['open'] ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (ph['delivery'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'توصيل 📦',
                          style: TextStyle(fontSize: 9, color: AppColors.info),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '📍 ${ph['distance']} من موقعك',
                  style: const TextStyle(fontSize: 10, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
