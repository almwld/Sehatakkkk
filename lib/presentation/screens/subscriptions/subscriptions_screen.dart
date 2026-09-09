import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import '../payment/subscription_payment_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});
  @override State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}
class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _annual = false;
  final plans = const [
    ('الباقة المجانية', 'free', 0, 0, 'الأساسيات الصحية اليومية'),
    ('الباقة الفضية', 'silver', 3000, 30000, 'رعاية صحية منتظمة'),
    ('الباقة البرونزية', 'bronze', 3900, 39000, 'مزايا صحية متقدمة'),
    ('الباقة الذهبية', 'gold', 4900, 35000, 'الرعاية الصحية المتكاملة'),
    ('باقة العائلة', 'family', 7500, 75000, 'حتى 5 أفراد من العائلة'),
    ('الباقة الكريستالية', 'crystal', 12000, 120000, 'تجربة رعاية فائقة'),
  ];
  Future<void> _subscribe((String, String, int, int, String) plan) async {
    final price = _annual ? plan.$4 : plan.$3;
    if (price == 0) { ToastService.showInfo('أنت على الباقة المجانية حالياً.'); return; }
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => SubscriptionPaymentScreen(planName: plan.$1, planCode: plan.$2, price: price, annual: _annual, planEmoji: '⭐')));
    if (ok == true && mounted) ToastService.showSuccess('تم الاشتراك في ${plan.$1} بنجاح.');
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFF4F6F7), appBar: AppBar(title: const Text('الباقات والاشتراكات'), backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(14), children: [Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Text('اختر باقتك الصحية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), const SizedBox(height: 12), Row(children: [Expanded(child: ChoiceChip(label: const Text('شهرياً'), selected: !_annual, onSelected: (_) => setState(() => _annual = false))), Expanded(child: ChoiceChip(label: const Text('سنوياً'), selected: _annual, onSelected: (_) => setState(() => _annual = true)))]), const SizedBox(height: 12), ...plans.map(_card), const SizedBox(height: 20), const Text('الدفع من محفظة صحتك مع فاتورة إلكترونية.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11))]));
  Widget _card((String, String, int, int, String) p) { final price = _annual ? p.$4 : p.$3; return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.$1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(p.$5, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 10), Text(price == 0 ? 'مجاناً' : '$price ر.ي ${_annual ? 'سنوياً' : 'شهرياً'}', style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w900)), const SizedBox(height: 10), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _subscribe(p), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: Text(price == 0 ? 'ابدأ مجاناً' : 'اشترك الآن')))])));
  }
}
