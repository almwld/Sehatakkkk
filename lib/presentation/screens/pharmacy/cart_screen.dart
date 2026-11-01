import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/unified_cart_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  final _cart = UnifiedCartService.instance;
  final _address = TextEditingController();
  bool _delivery = true, _processing = false;
    @override void dispose() { _address.dispose(); super.dispose(); }
  Future<void> _checkout() async {
    if (_cart.items.isEmpty || _processing) return;
    if (_delivery && _address.text.trim().isEmpty) { ToastService.showWarning(_t('أدخل عنوان التوصيل أولاً')); return; }
    setState(() => _processing = true);
    try {
      final result = await _cart.checkout(deliveryFee: 0, deliveryAddress: _delivery ? _address.text.trim() : null, deliveryRequired: _delivery);
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(_t('تم الدفع بنجاح')), content: Text(_t('رقم الطلب:') + ' ${result['orderId']}\n' + _t('الإجمالي:') + ' ${result['total']} ر.ي\n' + _t('رقم الفاتورة:') + ' ${result['invoiceId'] ?? '—'}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(_t('متابعة')))]));
      setState(() {});
    } catch (e) { if (mounted) ToastService.showError(_t('تعذر إتمام الدفع') + ': $e'); } finally { if (mounted) setState(() => _processing = false); }
  }
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final total = _cart.subtotal;
    if (_cart.items.isEmpty) return Scaffold(appBar: AppBar(title: Text(_t('السلة')), backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: Center(child: Text(_t('السلة فارغة'))));
    return Scaffold(appBar: AppBar(title: Text(_t('السلة الموحدة')), backgroundColor: AppColors.primary, foregroundColor: Colors.white), backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC), body: ListView(padding: const EdgeInsets.all(16), children: [
      ..._cart.items.map((item) => Card(child: ListTile(title: Text(item.name), subtitle: Text('${item.unitPrice.toStringAsFixed(0)} ر.ي × ${item.quantity}'), trailing: Wrap(spacing: 2, children: [IconButton(onPressed: () => setState(() => _cart.decrement(item.productId)), icon: const Icon(Icons.remove_circle_outline)), Text('${item.quantity}'), IconButton(onPressed: () => setState(() => _cart.increment(item.productId)), icon: const Icon(Icons.add_circle_outline)), IconButton(onPressed: () => setState(() => _cart.remove(item.productId)), icon: const Icon(Icons.delete_outline, color: Colors.red))])))),
      const SizedBox(height: 8),
      SwitchListTile(title: Text(_t('توصيل الطلب')), value: _delivery, onChanged: _processing ? null : (v) => setState(() => _delivery = v)),
      if (_delivery) TextField(controller: _address, maxLines: 2, decoration: InputDecoration(labelText: _t('عنوان التوصيل'), border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined))),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_t('المجموع')), Text('${_cart.subtotal.toStringAsFixed(0)} ر.ي')]), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_t('التوصيل')), Text(_delivery ? _t('تحسب عند التأكيد') : _t('بدون توصيل'))]), const Divider(height: 24), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_t('الإجمالي'), style: TextStyle(fontWeight: FontWeight.bold)), Text('${_delivery ? _cart.subtotal.toStringAsFixed(0) : total.toStringAsFixed(0)} ر.ي', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold))])]))),
      const SizedBox(height: 16),
      SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _processing ? null : _checkout, icon: _processing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.lock_outline), label: Text(_processing ? _t('جارٍ الدفع...') : _t('الدفع من محفظة صحتك')), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
    ]));
  }
}
