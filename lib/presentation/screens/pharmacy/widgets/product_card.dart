import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // ✅ صورة المنتج
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.medication,
                          size: 40,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                // ✅ علامة الوصفة
                if (product.prescriptionRequired)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'وصفة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // ✅ خصم
                if (product.discount != null && product.discount! > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.red],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${product.discount!.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // ✅ حالة التوفر
                if (!product.inStock)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: Text(
                          'غير متوفر',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // ✅ معلومات المنتج
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ✅ التصنيف
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: product.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.categoryText,
                      style: TextStyle(
                        fontSize: 10,
                        color: product.categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ✅ التقييم
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber[700]),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' (${product.reviews})',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // ✅ السعر والزر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.discount != null && product.discount! > 0)
                            Text(
                              '${product.price.toStringAsFixed(0)} ريال',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '${product.priceWithDiscount.toStringAsFixed(0)} ريال',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      if (product.inStock)
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 18,
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
      ),
    );
  }
}
