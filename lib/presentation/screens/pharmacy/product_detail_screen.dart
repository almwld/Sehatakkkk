import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ صورة المنتج
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.medication,
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ✅ اسم المنتج
            Text(
              product.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // ✅ الصيدلية والتقييم
            Row(
              children: [
                Icon(Icons.store, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  product.pharmacyName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(
                  ' ${product.rating.toStringAsFixed(1)} (${product.reviews})',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ✅ السعر
            Row(
              children: [
                if (product.discount != null && product.discount! > 0) ...[
                  Text(
                    '${product.price.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '${product.priceWithDiscount.toStringAsFixed(0)} ريال',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ ${product.dosage ?? 'وحدة'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (!product.inStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'غير متوفر',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // ✅ الوصف
            Card(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 الوصف',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ✅ التفاصيل
            Card(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 تفاصيل إضافية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('🏭 المصنع', product.manufacturer ?? 'غير معروف', isDark),
                    if (product.dosage != null)
                      _buildDetailRow('💊 الجرعة', product.dosage!, isDark),
                    _buildDetailRow('📦 المخزون', '${product.stock} وحدة', isDark),
                    _buildDetailRow('📂 التصنيف', product.categoryText, isDark),
                    if (product.prescriptionRequired)
                      _buildDetailRow('⚠️ وصفة طبية', 'مطلوب', isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ✅ اختيار الكمية وإضافة للسلة
            if (product.inStock) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'الكمية:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              if (_quantity < product.stock) {
                                setState(() => _quantity++);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('لا يوجد مخزون كاف'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(product.priceWithDiscount * _quantity).toStringAsFixed(0)} ريال',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // ✅ إضافة للسلة
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart),
                      const SizedBox(width: 8),
                      Text(
                        'أضف إلى السلة - ${(product.priceWithDiscount * _quantity).toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'هذا المنتج غير متوفر حالياً',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
