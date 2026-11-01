import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/widgets/common/app_image.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/imagekit.dart';
import '../../../core/services/unified_cart_service.dart';
import 'cart_screen.dart';

class PharmacyProductsScreen extends StatefulWidget {
  final String pharmacyId;
  const PharmacyProductsScreen({super.key, required this.pharmacyId});

  @override
  State<PharmacyProductsScreen> createState() => _PharmacyProductsScreenState();
}

class _PharmacyProductsScreenState extends State<PharmacyProductsScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  final _cart = UnifiedCartService.instance;
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('pharmacyId', isEqualTo: widget.pharmacyId)
          .get();
      final products = snapshot.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .where((product) =>
              product['approvalStatus'] == 'approved' &&
              product['isPublished'] == true &&
              product['isActive'] == true)
          .toList();
      if (mounted) setState(() => _products = products);
    } catch (_) {
      if (mounted) setState(() => _error = _t('تعذر تحميل منتجات الصيدلية حالياً'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    _cart.add(
      productId: (product['productId'] ?? product['id']).toString(),
      name: (product['name'] ?? _t('منتج')).toString(),
      unitPrice: (product['price'] as num?)?.toDouble() ?? 0,
      requiresPrescription: product['requiresPrescription'] == true,
      pharmacyId: widget.pharmacyId,
      providerName: (product['pharmacyName'] ?? product['sellerName'] ?? '').toString(),
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_t('تمت إضافة')} ${product['name']} ${_t('إلى السلة')}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('المنتجات')),
        actions: [
          Stack(children: [
            IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())).then((_) => setState(() {}))),
            if (_cart.itemCount > 0)
              Positioned(top: 7, right: 7, child: Container(width: 19, height: 19, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Center(child: Text('${_cart.itemCount}', style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold))))),
          ]),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _loadProducts, child: Text(_t('إعادة المحاولة'))),
                ]))
              : _products.isEmpty
                  ? Center(child: Text(_t('لا توجد منتجات متاحة في هذه الصيدلية حالياً')))
                  : GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final stock = (product['stock'] as num?)?.toInt() ?? 0;
          final inStock = product['inStock'] == true || stock > 0;
          final imageUrl = ImageKit.productImage(
            imageUrl: product['imageUrl']?.toString(),
            productId: (product['id'] ?? product['productId'])?.toString(),
            dosageForm: product['dosageForm']?.toString(),
            category: product['category']?.toString(),
            genericName: product['genericName']?.toString(),
          );
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.startsWith('http')
                    ? AppImage(
                        imageUrl: imageUrl,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : buildImageShimmer(
                        context,
                        width: double.infinity,
                        height: 80,
                        radius: BorderRadius.circular(12),
                      ),
              ),
              const SizedBox(height: 12),
              Text(_t((product['name'] ?? _t('منتج')).toString()), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(_t((product['category'] ?? '').toString()), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const Spacer(),
              if (product['requiresPrescription'] == true) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(_t('يتطلب وصفة'), style: TextStyle(fontSize: 10, color: AppColors.warning))),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(AppStrings.of(context).formatCurrency((product['price'] as num?) ?? 0), style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                GestureDetector(onTap: inStock ? () => _addToCart(product) : null, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: inStock ? AppColors.primary : Colors.grey, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_shopping_cart, color: AppColors.white, size: 18))),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
