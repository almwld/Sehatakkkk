import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/providers/cart_provider.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                cartProvider.clearCart();
                ToastService.showError(context, 'تم تفريغ السلة');
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyCart(isDark, context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItem(item, isDark, context);
                    },
                  ),
                ),
                _buildCartSummary(cartProvider, isDark, context),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(bool isDark, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'السلة فارغة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف منتجات من الصيدلية',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('تسوق الآن'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, bool isDark, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppImage(
              imageUrl: item.image ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorWidget: Container(
                width: 50,
                height: 50,
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.medication, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.pharmacyName != null)
                  Text(
                    item.pharmacyName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item.price.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    if (item.discount != null && item.discount! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${item.discount!.toInt()}%',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: () {
                  final provider = Provider.of<CartProvider>(context, listen: false);
                  provider.updateQuantity(item.id, item.quantity - 1);
                },
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  minimumSize: const Size(30, 30),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.quantity}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () {
                  final provider = Provider.of<CartProvider>(context, listen: false);
                  provider.updateQuantity(item.id, item.quantity + 1);
                },
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  minimumSize: const Size(30, 30),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                onPressed: () {
                  final provider = Provider.of<CartProvider>(context, listen: false);
                  provider.removeItem(item.id);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cartProvider, bool isDark, BuildContext context) {
    // ✅ حساب الخصم يدوياً من العناصر
    final totalBeforeDiscount = cartProvider.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final totalAfterDiscount = cartProvider.items.fold<double>(
      0,
      (sum, item) {
        final discount = item.discount ?? 0;
        final priceAfterDiscount = item.price * (1 - discount / 100);
        return sum + (priceAfterDiscount * item.quantity);
      },
    );
    final discountAmount = totalBeforeDiscount - totalAfterDiscount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المجموع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${cartProvider.finalPrice.toStringAsFixed(0)} ر.ي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (discountAmount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الخصم',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  '-${discountAmount.toStringAsFixed(0)} ر.ي',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: cartProvider.isEmpty
                  ? null
                  : () {
                      ToastService.showSuccess(context, '✅ تم تأكيد الطلب!');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                cartProvider.isEmpty
                    ? 'السلة فارغة'
                    : 'تأكيد الطلب (${cartProvider.itemCount} منتج)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
