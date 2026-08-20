import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/cart_service.dart';
import 'package:sehatak/core/models/cart/cart_item_model.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/cart/cart_screen.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  late TabController _tabController;
  final CartService _cartService = CartService();

  // قائمة التصنيفات
  final List<String> _categories = [
    'الكل',
    'مسكنات',
    'مضادات حيوية',
    'فيتامينات',
    'مكملات غذائية',
    'أدوية القلب',
    'أدوية الضغط',
    'أدوية السكري',
    'أجهزة طبية',
    'عناية بالبشرة',
    'منتجات أطفال',
  ];

  // قائمة المنتجات
  final List<Map<String, dynamic>> _allProducts = [
    // مسكنات
    {'id': 'p1', 'name': 'باراسيتامول 500mg', 'category': 'مسكنات', 'price': 500, 'image': 'assets/images/medicine_1.png', 'pharmacyName': 'صيدلية ابن حيان', 'stock': 50, 'unit': 'قرص', 'rating': 4.8, 'description': 'مسكن للألم وخافض للحرارة', 'manufacturer': 'شركة الدواء', 'dosage': 'قرص كل 6 ساعات', 'prescriptionRequired': false, 'inStock': true},
    {'id': 'p2', 'name': 'إيبوبروفين 400mg', 'category': 'مسكنات', 'price': 750, 'image': 'assets/images/medicine_2.png', 'pharmacyName': 'عالم الصيدلة', 'stock': 30, 'unit': 'قرص', 'rating': 4.7, 'description': 'مسكن للآلام ومضاد للالتهابات', 'manufacturer': 'شركة الدواء', 'dosage': 'قرص كل 8 ساعات', 'prescriptionRequired': false, 'inStock': true},
    {'id': 'p3', 'name': 'ديكلوفيناك 50mg', 'category': 'مسكنات', 'price': 650, 'image': 'assets/images/medicine_3.png', 'pharmacyName': 'صيدلية النهضة', 'stock': 40, 'unit': 'قرص', 'rating': 4.6, 'description': 'مسكن قوي للآلام والمفاصل', 'manufacturer': 'شركة الصحة', 'dosage': 'قرص مرتين يومياً', 'prescriptionRequired': true, 'inStock': true},
    {'id': 'p4', 'name': 'فيتامين د 1000IU', 'category': 'فيتامينات', 'price': 1200, 'image': 'assets/images/medicine_2.png', 'pharmacyName': 'عالم الصيدلة', 'stock': 30, 'unit': 'كبسولة', 'rating': 4.7, 'description': 'مكمل غذائي لفيتامين د', 'manufacturer': 'شركة الصحة', 'dosage': 'كبسولة يومياً', 'prescriptionRequired': false, 'inStock': true},
    {'id': 'p5', 'name': 'فيتامين سي 1000mg', 'category': 'فيتامينات', 'price': 800, 'image': 'assets/images/medicine_1.png', 'pharmacyName': 'صيدلية ابن حيان', 'stock': 45, 'unit': 'قرص فوار', 'rating': 4.6, 'description': 'مكمل غذائي لفيتامين سي', 'manufacturer': 'شركة الدواء', 'dosage': 'قرص يومياً', 'prescriptionRequired': false, 'inStock': true},
    {'id': 'p6', 'name': 'أموكسيسيلين 500mg', 'category': 'مضادات حيوية', 'price': 1500, 'image': 'assets/images/medicine_4.png', 'pharmacyName': 'صيدلية ابن حيان', 'stock': 20, 'unit': 'كبسولة', 'rating': 4.5, 'description': 'مضاد حيوي واسع المجال', 'manufacturer': 'شركة الصحة', 'dosage': 'كبسولة كل 8 ساعات', 'prescriptionRequired': true, 'inStock': true},
    {'id': 'p7', 'name': 'لوسارتان 50mg', 'category': 'أدوية الضغط', 'price': 800, 'image': 'assets/images/medicine_3.png', 'pharmacyName': 'صيدلية النهضة', 'stock': 30, 'unit': 'قرص', 'rating': 4.6, 'description': 'علاج ارتفاع ضغط الدم', 'manufacturer': 'شركة الدواء', 'dosage': 'قرص يومياً', 'prescriptionRequired': true, 'inStock': true},
    {'id': 'p8', 'name': 'ميتفورمين 500mg', 'category': 'أدوية السكري', 'price': 600, 'image': 'assets/images/medicine_3.png', 'pharmacyName': 'صيدلية النهضة', 'stock': 40, 'unit': 'قرص', 'rating': 4.5, 'description': 'علاج السكري من النوع الثاني', 'manufacturer': 'شركة الدواء', 'dosage': 'قرص مرتين يومياً', 'prescriptionRequired': true, 'inStock': true},
    {'id': 'p9', 'name': 'جهاز قياس ضغط', 'category': 'أجهزة طبية', 'price': 8500, 'image': 'assets/images/device_1.png', 'pharmacyName': 'صيدلية النهضة', 'stock': 10, 'unit': 'جهاز', 'rating': 4.9, 'description': 'جهاز قياس ضغط الدم الرقمي', 'manufacturer': 'شركة الأجهزة الطبية', 'prescriptionRequired': false, 'inStock': true},
    {'id': 'p10', 'name': 'كريم ترطيب للبشرة', 'category': 'عناية بالبشرة', 'price': 1800, 'image': 'assets/images/skin_1.png', 'pharmacyName': 'صيدلية ابن حيان', 'stock': 40, 'unit': 'أنبوب', 'rating': 4.5, 'description': 'كريم مرطب للبشرة الجافة', 'manufacturer': 'شركة العناية', 'prescriptionRequired': false, 'inStock': true},
    {'id': 'p11', 'name': 'حفاضات أطفال', 'category': 'منتجات أطفال', 'price': 2500, 'image': 'assets/images/baby_1.png', 'pharmacyName': 'عالم الصيدلة', 'stock': 60, 'unit': 'علبة', 'rating': 4.6, 'description': 'حفاضات أطفال مقاس M', 'manufacturer': 'شركة العناية', 'prescriptionRequired': false, 'inStock': true},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var products = _allProducts;
    if (_selectedCategory != 'الكل') {
      products = products.where((p) => p['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) =>
        p['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p['description'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p['manufacturer'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return products;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(Map<String, dynamic> product) async {
    final item = CartItemModel(
      id: product['id'],
      name: product['name'],
      price: product['price'].toDouble(),
      quantity: 1,
      category: product['category'],
      providerName: product['pharmacyName'],
      inStock: product['inStock'],
      image: product['image'],
      metadata: {'manufacturer': product['manufacturer']},
    );
    await _cartService.addItem(item);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة ${product['name']} إلى السلة'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('الصيدلية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InteractiveMapScreen(type: 'pharmacies'),
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              FutureBuilder<int>(
                future: _cartService.getItemCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data! > 0) {
                    return Positioned(
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
                          '${snapshot.data}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ابحث عن دواء...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // تبويبات التصنيفات
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                  backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // قائمة المنتجات
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد منتجات',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'حاول تغيير البحث أو التصنيف',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(product, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool isDark) {
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
            child: Image.asset(
              product['image'] ?? 'assets/images/medicine_1.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                  child: Icon(
                    Icons.medication,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                    size: 30,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product['pharmacyName'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${product['price']} ريال',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber[700],
                        ),
                        Text(
                          ' ${product['rating']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!product['inStock'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'غير متوفر',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (product['prescriptionRequired'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'وصفة طبية',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        _showProductDetails(product);
                      },
                      icon: const Icon(Icons.info_outline, size: 14),
                      label: const Text('تفاصيل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: product['inStock'] ? () => _addToCart(product) : null,
                      icon: const Icon(Icons.add_shopping_cart, size: 14),
                      label: const Text('إضافة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      product['image'] ?? 'assets/images/medicine_1.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.medication,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          product['pharmacyName'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber[700]),
                            Text(
                              ' ${product['rating']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('الوصف', product['description']),
              _buildDetailRow('الشركة المصنعة', product['manufacturer']),
              _buildDetailRow('الوحدة', product['unit']),
              _buildDetailRow('الجرعة', product['dosage'] ?? 'حسب التعليمات'),
              _buildDetailRow('السعر', '${product['price']} ريال'),
              if (product['prescriptionRequired'] == true)
                _buildDetailRow('وصفة طبية', 'مطلوب وصفة طبية'),
              _buildDetailRow('المخزون', product['inStock'] ? 'متوفر' : 'غير متوفر'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: product['inStock'] ? () {
                    _addToCart(product);
                    Navigator.pop(context);
                  } : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    product['inStock'] 
                      ? 'إضافة إلى السلة - ${product['price']} ريال'
                      : 'غير متوفر',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: product['inStock'] ? AppColors.primary : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
