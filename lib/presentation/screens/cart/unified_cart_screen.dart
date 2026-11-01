import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/cart/cart_item.dart';
import 'package:sehatak/core/services/cart/cart_service.dart';
import 'package:sehatak/presentation/screens/checkout/checkout_screen.dart';

class UnifiedCartScreen extends StatefulWidget { const UnifiedCartScreen({super.key}); @override State<UnifiedCartScreen> createState() => _UnifiedCartScreenState(); }
class _UnifiedCartScreenState extends State<UnifiedCartScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  String _money(double value) => '${value.toStringAsFixed(0)} ${_t('ريال')}';
  final CartService _cartService = CartService(); List<CartItem> _items = []; bool _isLoading = true;
  @override void initState() { super.initState(); _loadCart(); }
  Future<void> _loadCart() async { if (mounted) setState(() => _isLoading = true); _items = await _cartService.getItems(); if (mounted) setState(() => _isLoading = false); }
  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get _discount => _items.fold(0.0, (sum, item) => sum + item.discountAmount);
  double get _total => _subtotal - _discount;
  void _updateQuantity(CartItem item, int newQuantity) { _cartService.updateQuantity(item.id, item.type, newQuantity); _loadCart(); }
  void _removeItem(CartItem item) { _cartService.removeItem(item.id, item.type); _loadCart(); ToastService.showError(context, '${_t('تم إزالة المنتج من السلة')}: ${item.name}'); }
  void _clearCart() { showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: Text(_t('مسح السلة')), content: Text(_t('هل أنت متأكد من رغبتك في مسح جميع العناصر؟')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(_t('إلغاء'))), TextButton(onPressed: () async { await _cartService.clearCart(); if (dialogContext.mounted) Navigator.pop(dialogContext); _loadCart(); }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: Text(_t('مسح')))])); }
  void _proceedToCheckout() { if (_items.isEmpty) { ToastService.showSuccess(context, 'السلة فارغة'); return; } Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(items: _items.map((item) => item.toMap()).toList(), total: _total))); }
  @override Widget build(BuildContext context) { final isDark = Theme.of(context).brightness == Brightness.dark; return Scaffold(backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC), appBar: CustomAppBar(title: _t('سلة المشتريات'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [if (_items.isNotEmpty) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clearCart), IconButton(icon: const Icon(Icons.refresh), onPressed: _loadCart)]), body: _isLoading ? const Center(child: CircularProgressIndicator()) : _items.isEmpty ? _buildEmptyState(isDark) : Column(children: [Expanded(child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _items.length, itemBuilder: (context, index) => _buildCartItem(_items[index], isDark))), _buildCartSummary(isDark)])); }
  Widget _buildEmptyState(bool isDark) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart_outlined, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[300]), const SizedBox(height: 16), Text(_t('سلة المشتريات فارغة'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 8), Text(_t('أضف منتجات من الأقسام المختلفة'), style: const TextStyle(fontSize: 14)), const SizedBox(height: 24), ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.shopping_bag), label: Text(_t('تسوق الآن')), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))]));
  Widget _buildCartItem(CartItem item, bool isDark) { final hasDiscount = item.discount != null && item.discount! > 0; return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(item.typeIcon, style: const TextStyle(fontSize: 20)))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis), if (item.providerName != null) Text(item.providerName!, style: const TextStyle(fontSize: 11)), const SizedBox(height: 4), Text(_money(hasDiscount ? item.totalWithDiscount : item.totalPrice), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)), if (item.isPrescription) Text(_t('يحتاج وصفة'), style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.w600))])), Column(children: [Row(children: [IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: item.quantity > 1 ? () => _updateQuantity(item, item.quantity - 1) : null, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)), Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () => _updateQuantity(item, item.quantity + 1), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28))]), IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _removeItem(item), padding: EdgeInsets.zero, constraints: const BoxConstraints(), color: Colors.red)])])); }
  Widget _buildCartSummary(bool isDark) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_t('المجموع الفرعي')), Text(_money(_subtotal))],
            ),
            if (_discount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('الخصم'), style: const TextStyle(color: Colors.green)),
                  Text('-${_money(_discount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_t('الإجمالي'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_money(_total), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('${_t('إتمام الطلب')} (${_money(_total)})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
}
