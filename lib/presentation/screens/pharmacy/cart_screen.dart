import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/utils/image_utils.dart';
import 'package:sehatak/presentation/screens/pharmacy/models/product_model.dart';
import 'package:sehatak/presentation/screens/pharmacy/models/order_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String _deliveryAddress = '';
  String _deliveryNotes = '';
  String _paymentMethod = 'jeeb';

  final Map<String, String> _paymentMethods = {
    'jeeb': 'جيب',
    'jawali': 'جوالي كاش',
    'karimi': 'كريمي جوال',
  };

  final Map<String, IconData> _paymentIcons = {
    'jeeb': Icons.account_balance_wallet,
    'jawali': Icons.phone_android,
    'karimi': Icons.credit_card,
  };

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    // ✅ تحميل السلة من Firebase أو SharedPreferences
    setState(() {
      _cartItems = [
        CartItem(
          productId: '1',
          name: 'باراسيتامول 500mg',
          price: 500,
          quantity: 2,
          image: ImageService.medicine1,
          pharmacyId: 'ph1',
          pharmacyName: 'صيدلية ابن حيان',
          maxStock: 10,
        ),
        CartItem(
          productId: '2',
          name: 'فيتامين د 1000IU',
          price: 1200,
          quantity: 1,
          image: ImageService.medicine2,
          pharmacyId: 'ph2',
          pharmacyName: 'عالم الصيدلة',
          maxStock: 5,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('سلة المشتريات (${_cartItems.length})'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart(isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(_cartItems[index], index, isDark);
                    },
                  ),
                ),
                _buildCheckoutSection(isDark, primaryColor),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
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
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تصفح الصيدلية وأضف المنتجات',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('مواصلة التسوق'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          // ✅ صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: buildProductImage(item.image, size: 60),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.pharmacyName,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item.price} ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'متوفر',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ أزرار الكمية
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => _updateQuantity(index, item.quantity - 1),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => _updateQuantity(index, item.quantity + 1),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ],
              ),
              Text(
                '${item.price * item.quantity} ر.ي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(bool isDark, Color primaryColor) {
    final subtotal = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final deliveryFee = 500.0;
    final discount = 0.0;
    final total = subtotal + deliveryFee - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ ملخص السعر
          _buildPriceRow('المجموع الفرعي', '${subtotal.toStringAsFixed(0)} ر.ي', isDark),
          _buildPriceRow('رسوم التوصيل', '${deliveryFee.toStringAsFixed(0)} ر.ي', isDark),
          if (discount > 0) _buildPriceRow('الخصم', '-${discount.toStringAsFixed(0)} ر.ي', isDark, isDiscount: true),
          const Divider(),
          _buildPriceRow(
            'المجموع',
            '${total.toStringAsFixed(0)} ر.ي',
            isDark,
            isTotal: true,
          ),
          const SizedBox(height: 12),

          // ✅ زر الدفع
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _cartItems.isEmpty ? null : _showPaymentDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إتمام الشراء',
                style: TextStyle(
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

  Widget _buildPriceRow(String label, String value, bool isDark, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : (isTotal ? AppColors.primary : (isDark ? Colors.white : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1) {
      _removeItem(index);
      return;
    }
    if (newQuantity > _cartItems[index].maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الكمية المطلوبة غير متوفرة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _cartItems[index].quantity = newQuantity;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف المنتج من السلة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفريغ السلة'),
        content: const Text('هل أنت متأكد من رغبتك في تفريغ السلة بالكامل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _cartItems.clear());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تفريغ'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._paymentMethods.entries.map((entry) {
              final isSelected = _paymentMethod == entry.key;
              return GestureDetector(
                onTap: () => setState(() => _paymentMethod = entry.key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _paymentIcons[entry.key],
                        color: isSelected ? AppColors.primary : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => _deliveryAddress = value,
              decoration: const InputDecoration(
                hintText: 'عنوان التوصيل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => _deliveryNotes = value,
              decoration: const InputDecoration(
                hintText: 'ملاحظات إضافية (اختياري)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _deliveryAddress.isEmpty ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تأكيد الدفع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subtotal = _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
      final deliveryFee = 500.0;
      final total = subtotal + deliveryFee;

      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        items: _cartItems.map((item) => OrderItem(
          productId: item.productId,
          productName: item.name,
          productImage: item.image,
          quantity: item.quantity,
          price: item.price,
          total: item.price * item.quantity,
        )).toList(),
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: 0,
        total: total,
        status: 'pending',
        paymentMethod: _paymentMethod,
        paymentStatus: 'paid',
        deliveryAddress: _deliveryAddress,
        deliveryNotes: _deliveryNotes.isNotEmpty ? _deliveryNotes : null,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .set(order.toMap());

      // ✅ إضافة إشعار
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'title': 'تم تأكيد الطلب',
        'body': 'تم تأكيد طلبك رقم #${order.id.substring(0, 8)} وسيتم توصيله قريباً',
        'type': 'order',
        'orderId': order.id,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      setState(() => _cartItems.clear());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تأكيد الطلب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }
}

class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;
  final String image;
  final String pharmacyId;
  final String pharmacyName;
  final int maxStock;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.maxStock,
  });
}
