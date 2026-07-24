import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/cart_item_model.dart';
import 'package:sehatak/core/services/cart_service.dart';
import 'package:sehatak/presentation/screens/checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  List<CartItemModel> _items = [];
  bool _isLoading = true;
  double _deliveryFee = 500; // 500 ريال رسوم توصيل افتراضية

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await _cartService.getItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  double get _subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get _tax {
    return _subtotal * 0.05; // 5% ضريبة
  }

  double get _total {
    return _subtotal + _deliveryFee + _tax;
  }

  void _updateQuantity(CartItemModel item, int newQuantity) async {
    await _cartService.updateQuantity(item.id, newQuantity);
    await _loadCart();
  }

  void _removeItem(CartItemModel item) async {
    await _cartService.removeItem(item.id);
    await _loadCart();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🗑️ تم إزالة ${item.name} من السلة'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل أنت متأكد من رغبتك في مسح جميع العناصر من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cartService.clearCart();
      await _loadCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ تم مسح السلة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _proceedToCheckout() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة، أضف منتجات أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          items: _items,
          subtotal: _subtotal,
          deliveryFee: _deliveryFee,
          tax: _tax,
          total: _total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCart,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyState(isDark)
              : Column(
                  children: [
                    // ✅ قائمة المنتجات
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildCartItem(item);
                        },
                      ),
                    ),
                    // ✅ ملخص السلة
                    _buildCartSummary(isDark),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
            'سلة المشتريات فارغة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف منتجات من الصيدلية أو المختبرات',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('تسوق الآن'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Row(
        children: [
          // ✅ صورة المنتج
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: item.image != null
                  ? DecorationImage(
                      image: AssetImage(item.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.image == null
                ? Icon(
                    Icons.medication,
                    color: Colors.grey.shade400,
                    size: 30,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // ✅ معلومات المنتج
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.category != null)
                  Text(
                    item.category!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // ✅ أزرار تعديل الكمية
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: item.quantity > 1
                                ? () => _updateQuantity(item, item.quantity - 1)
                                : null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => _updateQuantity(item, item.quantity + 1),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.total.toStringAsFixed(0)} ريال',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ زر الحذف
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => _removeItem(item),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ تفاصيل الأسعار
          _buildSummaryRow('المجموع الفرعي', _subtotal),
          _buildSummaryRow('رسوم التوصيل', _deliveryFee),
          _buildSummaryRow('الضريبة (5%)', _tax),
          const Divider(),
          _buildSummaryRow(
            'الإجمالي',
            _total,
            isTotal: true,
          ),
          const SizedBox(height: 12),
          // ✅ زر إتمام الطلب
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'إتمام الطلب (${_total.toStringAsFixed(0)} ريال)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} ريال',
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
