import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/unified_cart_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  final _cart = UnifiedCartService.instance;
  final _address = TextEditingController();
  bool _delivery = true, _processing = false;
  static const double _deliveryFee = 500;
  @override void dispose() { _address.dispose(); super.dispose(); }
  Future<void> _checkout() async {
    if (_cart.items.isEmpty || _processing) return;
    if (_delivery && _address.text.trim().isEmpty) { ToastService.showWarning('أدخل عنوان التوصيل أولاً'); return; }
    setState(() => _processing = true);
    try {
      final result = await _cart.checkout(deliveryFee: _delivery ? _deliveryFee : 0, deliveryAddress: _delivery ? _address.text.trim() : null);
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('تم الدفع بنجاح'), content: Text('رقم الطلب: ${result['orderId']}\nالإجمالي: ${result['total']} ر.ي'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('متابعة'))]));
      setState(() {});
    } catch (e) { if (mounted) ToastService.showError('تعذر إتمام الدفع: $e'); } finally { if (mounted) setState(() => _processing = false); }
  }
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final delivery = _delivery ? _deliveryFee : 0.0;
    final total = _cart.subtotal + delivery;
    if (_cart.items.isEmpty) return Scaffold(appBar: AppBar(title: const Text('السلة'), backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: const Center(child: Text('السلة فارغة')));
    return Scaffold(appBar: AppBar(title: const Text('السلة الموحدة'), backgroundColor: AppColors.primary, foregroundColor: Colors.white), backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC), body: ListView(padding: const EdgeInsets.all(16), children: [
      ..._cart.items.map((item) => Card(child: ListTile(title: Text(item.name), subtitle: Text('${item.unitPrice.toStringAsFixed(0)} ر.ي × ${item.quantity}'), trailing: Wrap(spacing: 2, children: [IconButton(onPressed: () => setState(() => _cart.decrement(item.productId)), icon: const Icon(Icons.remove_circle_outline)), Text('${item.quantity}'), IconButton(onPressed: () => setState(() => _cart.increment(item.productId)), icon: const Icon(Icons.add_circle_outline)), IconButton(onPressed: () => setState(() => _cart.remove(item.productId)), icon: const Icon(Icons.delete_outline, color: Colors.red))])))),
      const SizedBox(height: 8),
      SwitchListTile(title: const Text('توصيل الطلب'), value: _delivery, onChanged: _processing ? null : (v) => setState(() => _delivery = v)),
      if (_delivery) TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'عنوان التوصيل', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined))),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المجموع'), Text('${_cart.subtotal.toStringAsFixed(0)} ر.ي')]), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('التوصيل'), Text('${delivery.toStringAsFixed(0)} ر.ي')]), const Divider(height: 24), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)), Text('${total.toStringAsFixed(0)} ر.ي', style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold))])]))),
      const SizedBox(height: 16),
      SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _processing ? null : _checkout, icon: _processing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.lock_outline), label: Text(_processing ? 'جارٍ الدفع...' : 'الدفع من محفظة صحتك'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
    ]));
  }
}
