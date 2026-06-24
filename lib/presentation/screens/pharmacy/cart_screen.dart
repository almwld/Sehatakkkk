import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _items = [
    {'id': 1, 'name': 'باراسيتامول 500mg', 'qty': 2, 'price': 500, 'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200'},
    {'id': 2, 'name': 'فيتامين د 1000IU', 'qty': 1, 'price': 1200, 'image': 'https://images.unsplash.com/photo-1577174881658-0f30ed549adc?w=200'},
    {'id': 3, 'name': 'أوميغا 3', 'qty': 1, 'price': 4000, 'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=200'},
  ];

  final List<Map<String, String>> _delivery = [
    {'name': 'تسهيل', 'time': '30 دقيقة', 'price': '300'},
    {'name': 'توصيل', 'time': '2 ساعة', 'price': '500'},
    {'name': 'اطلبني', 'time': '1 يوم', 'price': '200'},
    {'name': 'ناس السريع', 'time': '3 أيام', 'price': '100'},
  ];

  final List<Map<String, dynamic>> _payment = [
    {'id': 'floosk', 'name': 'فلوسك', 'icon': 'assets/icons/payment/floosak_icon.png', 'color': const Color(0xFF1976D2)},
    {'id': 'jawali', 'name': 'جوالي', 'icon': 'assets/icons/payment/Jawali_icon.png', 'color': const Color(0xFF00796B)},
    {'id': 'jeeb', 'name': 'جيب', 'icon': 'assets/icons/payment/جيب_icon.png', 'color': const Color(0xFF7B1FA2)},
    {'id': 'easy', 'name': 'إيزي كاش', 'icon': 'assets/icons/payment/ايزي_icon.png', 'color': const Color(0xFFE65100)},
    {'id': 'cash', 'name': 'كاش', 'icon': 'assets/icons/payment/كاش_icon.png', 'color': const Color(0xFF2E7D32)},
  ];

  int _selDelivery = 0;
  String _selPayment = 'cash';
  String _address = 'صنعاء - شارع الستين';
  bool _ordered = false;

  void _updateQty(int id, int d) {
    setState(() {
      final i = _items.indexWhere((x) => x['id'] == id);
      if (i != -1) { _items[i]['qty'] = (_items[i]['qty'] as int) + d; if (_items[i]['qty'] <= 0) _items.removeAt(i); }
    });
  }

  int get _sub => _items.fold(0, (s, i) => s + (i['qty'] as int) * (i['price'] as int));
  int get _del => int.parse(_delivery[_selDelivery]['price']!);
  int get _tot => _sub + _del;

  @override
  Widget build(BuildContext c) {
    if (_ordered) return _ok();
    return Scaffold(body: Stack(children: [Column(children: [
      _hdr(), Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('المنتجات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        ..._items.map((i) => _item(i)),
        const SizedBox(height: 16), _addr(), const SizedBox(height: 16),
        const Text('شركة التوصيل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        ..._delivery.asMap().entries.map((e) => _delOpt(e.key, e.value)),
        const SizedBox(height: 16),
        const Text('طريقة الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        _payRow(), const SizedBox(height: 120),
      ])),
    ]), _bar()]));
  }

  Widget _ok() => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, size: 56, color: AppColors.success)),
    const SizedBox(height: 20), const Text('تم تأكيد طلبك!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    const Text('طلبيتك قيد المعالجة', style: TextStyle(fontSize: 15, color: AppColors.grey)),
    Text('${_tot.toString()} ريال', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
    ElevatedButton(onPressed: () { setState(() => _ordered = false); Navigator.pop(context); }, child: const Text('العودة')),
  ])));

  Widget _hdr() => Container(padding: const EdgeInsets.fromLTRB(16, 50, 16, 16), decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))), child: Row(children: [GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.chevron_left, color: Colors.white))), const SizedBox(width: 12), const Text('سلة المشتريات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), const Spacer(), Text('${_items.length} منتج', style: const TextStyle(fontSize: 13, color: Colors.white70))]));

  Widget _item(Map<String, dynamic> i) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [
    ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)), child: Image.network(i['image'], width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 90, height: 90, color: AppColors.lightGrey, child: const Icon(Icons.medication, color: AppColors.primary)))),
    Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(i['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Text('${(i['price'] * i['qty']).toString()} ريال', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          GestureDetector(onTap: () => _updateQty(i['id'], 1), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, size: 16, color: AppColors.primary))),
          const SizedBox(width: 12), Text('${i['qty']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(width: 12),
          GestureDetector(onTap: () => _updateQty(i['id'], -1), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.remove, size: 16, color: AppColors.primary))),
        ]),
        GestureDetector(onTap: () => _updateQty(i['id'], -999), child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20)),
      ]),
    ]))),
  ]));

  Widget _addr() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.location_on, color: AppColors.primary, size: 20), const SizedBox(width: 10), Expanded(child: TextField(controller: TextEditingController(text: _address), onChanged: (v) => _address = v, textAlign: TextAlign.right, decoration: const InputDecoration(border: InputBorder.none), style: const TextStyle(fontSize: 13)))]));

  Widget _delOpt(int idx, Map<String, String> co) {
    final sel = _selDelivery == idx;
    return GestureDetector(onTap: () => setState(() => _selDelivery = idx), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: sel ? AppColors.primary.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? AppColors.primary : Colors.transparent, width: 1.5)), child: Row(children: [Icon(Icons.local_shipping, size: 20, color: sel ? AppColors.primary : AppColors.grey), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(co['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: sel ? AppColors.primary : null)), Text('خلال ${co['time']}', style: const TextStyle(fontSize: 12, color: AppColors.grey))])), const SizedBox(width: 10), Text('${co['price']} ريال', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: sel ? AppColors.primary : AppColors.darkGrey))])));
  }

  Widget _payRow() => SizedBox(height: 90, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _payment.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
    final p = _payment[i]; final sel = _selPayment == p['id'];
    return GestureDetector(onTap: () => setState(() => _selPayment = p['id']), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: sel ? (p['color'] as Color).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? (p['color'] as Color) : AppColors.lightGrey, width: 1.5)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(p['icon'], width: 36, height: 36, errorBuilder: (_, __, ___) => Icon(Icons.payment, color: p['color'], size: 30)),
      const SizedBox(height: 5), Text(p['name'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: sel ? (p['color'] as Color) : AppColors.darkGrey)),
    ])));
  }));

  Widget _bar() => Positioned(bottom: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -4))]), child: SafeArea(child: Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontSize: 14, color: AppColors.grey)), Text('${_tot.toString()} ريال', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary))]),
    const SizedBox(height: 12), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _ordered = true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('تأكيد الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
  ]))));
}
