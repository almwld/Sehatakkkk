import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import '../payment/subscription_payment_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  static const String _currency = 'RYE';
  bool _annualBilling = false;
  int _selectedPlan = 0;

  final List<_Plan> _plans = const [
    _Plan('الباقة المجانية', 0, 0, Icons.volunteer_activism_rounded, 'الأساسيات الصحية اليومية بدون رسوم', ['3 استشارات مجانية شهرياً', 'سجل صحي إلكتروني', 'تذكير بالمواعيد', 'تصفح الأدوية والأسعار']),
    _Plan('الباقة الفضية', 3000, 30000, Icons.workspace_premium_rounded, 'رعاية صحية منتظمة بسعر مناسب', ['10 استشارات شهرياً', 'خصم 20% على الأدوية', 'تحليل منزلي مجاني شهرياً', 'متابعة دورية مع طبيب', 'تقارير صحية شهرية']),
    _Plan('الباقة البرونزية', 3900, 39000, Icons.shield_rounded, 'مزايا متقدمة لرعاية صحية أكثر شمولاً', ['20 استشارة شهرياً', 'خصم 25% على الأدوية', 'تحليل منزلي مجاني شهرياً', 'أولوية متوسطة في الحجز', 'تقارير صحية شهرية', 'متابعة صحية أساسية']),
    _Plan('الباقة الذهبية', 4900, 35000, Icons.auto_awesome_rounded, 'أفضل قيمة للرعاية الصحية المتكاملة', ['استشارات غير محدودة 24/7', 'خصم 35% على الأدوية', 'تحاليل منزلية مجانية', 'أولوية في الحجز', 'طبيب شخصي مخصص', 'تقارير صحية أسبوعية', 'دعم فني VIP'], popular: true),
    _Plan('باقة العائلة', 7500, 75000, Icons.family_restroom_rounded, 'رعاية متكاملة لك ولعائلتك حتى 5 أفراد', ['كل مميزات الباقة الذهبية', 'حتى 5 أفراد من العائلة', 'استشارات أطفال مجانية', 'متابعة الحمل والولادة', 'طبيب عائلة مخصص', 'خصم 50% على الأدوية']),
    _Plan('الباقة الكريستالية', 12000, 120000, Icons.diamond_rounded, 'تجربة رعاية صحية فائقة ومتكاملة', ['كل مميزات باقة العائلة', 'حتى 8 أفراد من العائلة', 'استشارات غير محدودة 24/7', 'طبيب شخصي وكبير أطباء مخصص', 'أولوية قصوى في الحجوزات', 'تحاليل منزلية متقدمة', 'خصم 60% على الأدوية', 'مدير رعاية صحية شخصي', 'دعم VIP على مدار الساعة', 'تقارير صحية متقدمة']),
  ];

  String _money(int value) => '$value $_currency';

  void _subscribe(_Plan plan) {
    if (plan.monthly == 0) {
      setState(() => _selectedPlan = _plans.indexOf(plan));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أنت على الباقة المجانية حالياً.')));
      return;
    }
    final price = _annualBilling ? plan.annual : plan.monthly;
    Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => SubscriptionPaymentScreen(planName: plan.name, planPrice: _money(price), planEmoji: _emoji(plan.icon)))).then((success) {
      if (success == true && mounted) {
        setState(() => _selectedPlan = _plans.indexOf(plan));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الاشتراك في ${plan.name} بنجاح.'), backgroundColor: AppColors.success));
      }
    });
  }

  String _emoji(IconData icon) {
    if (icon == Icons.diamond_rounded) return '💎';
    if (icon == Icons.family_restroom_rounded) return '👨‍👩‍👧‍👦';
    if (icon == Icons.auto_awesome_rounded) return '⭐';
    if (icon == Icons.shield_rounded) return '🛡️';
    if (icon == Icons.workspace_premium_rounded) return '🏅';
    return '🆓';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(title: const Text('الباقات والاشتراكات', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(14), children: [
        _header(),
        const SizedBox(height: 14),
        _billingToggle(),
        const SizedBox(height: 14),
        ...List.generate(_plans.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _card(_plans[i], i))),
        _trustNote(),
      ])),
    );
  }

  Widget _header() => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 34), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('اختر باقتك الصحية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('خطط صحية مصممة لاحتياجاتك وميزانيتك', style: TextStyle(fontSize: 12, color: AppColors.grey))]))]));

  Widget _billingToggle() => Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: _billingButton('شهرياً', false)), Expanded(child: _billingButton('سنوياً', true))]));

  Widget _billingButton(String text, bool annual) { final selected = _annualBilling == annual; return GestureDetector(onTap: () => setState(() => _annualBilling = annual), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.darkGrey, fontWeight: FontWeight.bold)))); }

  Widget _card(_Plan plan, int index) {
    final price = _annualBilling ? plan.annual : plan.monthly;
    final selected = _selectedPlan == index;
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected || plan.popular ? AppColors.primary : const Color(0xFFE1E6E8), width: selected || plan.popular ? 1.5 : 1)), child: Column(children: [
      if (plan.popular) Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 7), decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(17))), child: const Text('الأكثر اختياراً', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.09), borderRadius: BorderRadius.circular(14)), child: Icon(plan.icon, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(plan.description, style: const TextStyle(fontSize: 11, color: AppColors.grey))])), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_money(price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)), Text(_annualBilling ? 'سنوياً' : 'شهرياً', style: const TextStyle(fontSize: 10, color: AppColors.grey))])]),
        if (_annualBilling && plan.monthly > 0) Padding(padding: const EdgeInsets.only(top: 8), child: Text('ما يعادل ${_money((plan.annual / 12).round())} شهرياً', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold))),
        const Divider(height: 24),
        ...plan.features.map((f) => _feature(f)),
        const SizedBox(height: 8),
        SizedBox(height: 44, child: ElevatedButton(onPressed: selected && index == 0 ? null : () => _subscribe(plan), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(selected ? 'باقتك الحالية' : (price == 0 ? 'ابدأ مجاناً' : 'اشترك الآن'), style: const TextStyle(fontWeight: FontWeight.bold))))
      ])),
    ]));
  }

  Widget _feature(String text) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18), const SizedBox(width: 7), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.darkGrey)))]));

  Widget _trustNote() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.lock_outline_rounded, color: AppColors.primary), SizedBox(width: 8), Expanded(child: Text('الأسعار المعروضة بعملة RYE. الدفع يتم عبر محافظ إلكترونية يمنية مدعومة.', style: TextStyle(fontSize: 11, color: AppColors.grey)))]));
}

class _Plan {
  final String name;
  final int monthly;
  final int annual;
  final IconData icon;
  final String description;
  final List<String> features;
  final bool popular;

  const _Plan(this.name, this.monthly, this.annual, this.icon, this.description, this.features, {this.popular = false});
}
