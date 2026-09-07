import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/unified_cart_service.dart';
import 'cart_screen.dart';

class PharmacyProductsScreen extends StatefulWidget {
  final String pharmacyId;
  const PharmacyProductsScreen({super.key, required this.pharmacyId});

  @override
  State<PharmacyProductsScreen> createState() => _PharmacyProductsScreenState();
}

class _PharmacyProductsScreenState extends State<PharmacyProductsScreen> {
  final _cart = UnifiedCartService.instance;

  final products = const [
    {'id': 'panadol_extra', 'name': 'بانادول إكسترا', 'price': 1200.0, 'category': 'مسكنات', 'requiresPrescription': false, 'inStock': true},
    {'id': 'amoxicillin_500', 'name': 'أموكسيسيلين 500mg', 'price': 3500.0, 'category': 'مضادات حيوية', 'requiresPrescription': true, 'inStock': true},
    {'id': 'vitamin_c', 'name': 'فيتامين سي', 'price': 800.0, 'category': 'فيتامينات', 'requiresPrescription': false, 'inStock': true},
    {'id': 'omeprazole_20', 'name': 'أوميبرازول 20mg', 'price': 2500.0, 'category': 'مضادات الحموضة', 'requiresPrescription': false, 'inStock': true},
    {'id': 'metronidazole', 'name': 'مترونيدازول', 'price': 1800.0, 'category': 'مضادات حيوية', 'requiresPrescription': true, 'inStock': false},
    {'id': 'aloe_gel', 'name': 'جل الصبار', 'price': 1500.0, 'category': 'عناية بالبشرة', 'requiresPrescription': false, 'inStock': true},
  ];

  void _addToCart(Map<String, dynamic> product) {
    _cart.add(
      productId: product['id'] as String,
      name: product['name'] as String,
      unitPrice: (product['price'] as num).toDouble(),
      requiresPrescription: product['requiresPrescription'] as bool,
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت إضافة ${product['name']} إلى السلة')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          Stack(children: [
            IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())).then((_) => setState(() {}))),
            if (_cart.itemCount > 0)
              Positioned(top: 7, right: 7, child: Container(width: 19, height: 19, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Center(child: Text('${_cart.itemCount}', style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold))))),
          ]),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final inStock = product['inStock'] as bool;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 80, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.medication, color: AppColors.primary, size: 40))),
              const SizedBox(height: 12),
              Text(product['name'] as String, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(product['category'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const Spacer(),
              if (product['requiresPrescription'] as bool) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text('يتطلب وصفة', style: TextStyle(fontSize: 10, color: AppColors.warning))),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${product['price']} ${AppStrings.currencyYER}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                GestureDetector(onTap: inStock ? () => _addToCart(product) : null, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: inStock ? AppColors.primary : Colors.grey, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_shopping_cart, color: AppColors.white, size: 18))),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
