import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/pharmacy_service.dart';
import 'package:sehatak/core/services/pharmacy_cache_service.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';
import 'package:sehatak/presentation/screens/cart/cart_screen.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/widgets/product_card.dart';
import 'package:sehatak/presentation/screens/pharmacy/widgets/pharmacy_card.dart';
import 'package:sehatak/presentation/screens/pharmacy/widgets/loading_shimmer.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final PharmacyService _service = PharmacyService();
  final PharmacyCacheService _cache = PharmacyCacheService();
  
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = true;
  bool _isOffline = false;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  
  // ✅ Pagination
  final int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;

  final List<String> _categories = [
    'الكل',
    'مسكنات',
    'مضادات حيوية',
    'فيتامينات',
    'مكملات غذائية',
    'أدوية الضغط',
    'أدوية القلب',
    'أدوية السكري',
    'أجهزة طبية',
    'عناية بالبشرة',
    'عناية بالشعر',
    'مكياج',
    'عطور',
    'عناية بالجسم',
    'عناية بالفم والأسنان',
    'عناية بالطفل',
    'حفاضات',
    'أغذية أطفال',
    'حليب أطفال',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ تحميل المنتجات
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      // ✅ محاولة جلب من Firebase
      final products = await _service.getProducts(limit: _pageSize);
      
      if (products.isNotEmpty) {
        setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoading = false;
          _isOffline = false;
        });
        // ✅ حفظ في الكاش
        await _cache.saveProducts(products);
      } else {
        // ✅ إذا كانت Firebase فارغة، جلب من الكاش
        await _loadFromCache();
      }
    } catch (e) {
      // ✅ في حالة الخطأ، جلب من الكاش
      await _loadFromCache();
      setState(() => _isOffline = true);
    }
  }

  // ✅ تحميل من الكاش
  Future<void> _loadFromCache() async {
    final cached = await _cache.getProducts();
    if (cached.isNotEmpty) {
      setState(() {
        _products = cached;
        _filteredProducts = cached;
        _isLoading = false;
        _isOffline = true;
      });
    } else {
      // ✅ إذا كان الكاش فارغاً، استخدم بيانات افتراضية
      _loadFallbackData();
    }
  }

  // ✅ بيانات افتراضية (للحالات القصوى)
  void _loadFallbackData() {
    setState(() {
      _isLoading = false;
      _isOffline = true;
      _products = _getFallbackProducts();
      _filteredProducts = _products;
    });
  }

  // ✅ التحقق من الاتصال
  Future<void> _checkConnectivity() async {
    // محاكاة التحقق (يمكن استخدام Connectivity Plus)
  }

  // ✅ تحميل المزيد (Pagination)
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final lastDoc = _products.isNotEmpty 
          ? await _firestore.collection('products').doc(_products.last.id).get()
          : null;

      final newProducts = await _service.getProductsPaginated(
        category: _selectedCategory == 'الكل' ? null : _selectedCategory,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        lastDoc: lastDoc,
        limit: _pageSize,
      );

      if (newProducts.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _products.addAll(newProducts);
          _filteredProducts = _products;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  // ✅ تصفية المنتجات
  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == 'الكل' || 
            product.categoryText == _selectedCategory;
        
        final matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('💊 الصيدليات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ حالة الاتصال
          if (_isOffline)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📶 Offline',
                style: TextStyle(color: Colors.orange, fontSize: 10),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InteractiveMapScreen(type: 'pharmacies'),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '🛒 منتجات'),
            Tab(text: '🏪 صيدليات'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ✅ شريط البحث
          _buildSearchBar(isDark),
          
          // ✅ تصنيفات
          if (_tabController.index == 0)
            _buildCategoryFilter(isDark),
          
          // ✅ المحتوى
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(isDark),
                _buildPharmaciesTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ شريط البحث
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterProducts();
          });
        },
        decoration: InputDecoration(
          hintText: '🔍 ابحث عن دواء أو صيدلية...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _filterProducts();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ✅ تصنيفات
  Widget _buildCategoryFilter(bool isDark) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
                _filterProducts();
              });
            },
            backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
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
    );
  }

  // ✅ تبويب المنتجات
  Widget _buildProductsTab(bool isDark) {
    if (_isLoading) {
      return const LoadingShimmer();
    }

    if (_filteredProducts.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          if (notification.metrics.extentAfter < 100) {
            _loadMore();
          }
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: _filteredProducts.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredProducts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final product = _filteredProducts[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
            onAddToCart: () {
              // ✅ إضافة للسلة
            },
          );
        },
      ),
    );
  }

  // ✅ تبويب الصيدليات
  Widget _buildPharmaciesTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الصيدليات...',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  // ✅ حالة فارغة
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isOffline ? 'أنت غير متصل، استخدم البيانات المخزنة' : 'حاول تغيير البحث أو التصنيف',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          if (_isOffline) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('محاولة الاتصال'),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ بيانات افتراضية (Fallback)
  List<ProductModel> _getFallbackProducts() {
    final now = DateTime.now();
    return [
      ProductModel(
        id: 'fb1',
        name: 'باراسيتامول 500mg',
        nameEn: 'Paracetamol',
        category: ProductCategory.painkiller,
        description: 'مسكن للألم وخافض للحرارة',
        price: 500,
        imageUrl: 'assets/images/medicine_1.png',
        pharmacyId: 'ph1',
        pharmacyName: 'صيدلية ابن حيان',
        pharmacyImage: 'assets/images/pharmacies/pharmacy_1.png',
        stock: 50,
        inStock: true,
        rating: 4.8,
        reviews: 120,
        keywords: ['paracetamol', 'مسكن'],
        createdAt: now,
        updatedAt: now,
      ),
      ProductModel(
        id: 'fb2',
        name: 'فيتامين د 1000IU',
        nameEn: 'Vitamin D',
        category: ProductCategory.vitamin,
        description: 'مكمل غذائي لفيتامين د',
        price: 1200,
        imageUrl: 'assets/images/medicine_2.png',
        pharmacyId: 'ph2',
        pharmacyName: 'عالم الصيدلة',
        pharmacyImage: 'assets/images/pharmacies/pharmacy_2.png',
        stock: 30,
        inStock: true,
        rating: 4.7,
        reviews: 80,
        keywords: ['vitamin d', 'فيتامين د'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
