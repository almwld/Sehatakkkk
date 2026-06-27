import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/payment/subscription_payment_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _selectedPlan = 2;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'plan_basic',
      'name': 'الباقة المجانية',
      'icon': 'assets/icons/plans/free.svg',
      'price': 0,
      'period': 'للأبد',
      'color': AppColors.grey,
      'features': [
        '✅ 3 استشارات مجانية شهرياً',
        '✅ سجل صحي إلكتروني',
        '✅ تذكير بالمواعيد',
        '✅ تصفح الأدوية والأسعار',
      ],
      'isPopular': false,
    },
    {
      'id': 'plan_silver',
      'name': 'الباقة الفضية',
      'icon': 'assets/icons/plans/silver.svg',
      'price': 3000,
      'period': 'شهرياً',
      'color': AppColors.info,
      'features': [
        '✅ 10 استشارات شهرياً',
        '✅ خصم 20% على الأدوية',
        '✅ تحليل منزلي مجاني شهرياً',
        '✅ متابعة دورية مع طبيب',
        '✅ تقارير صحية شهرية',
        '✅ سجل صحي متقدم',
      ],
      'isPopular': false,
    },
    {
      'id': 'plan_gold',
      'name': 'الباقة الذهبية',
      'icon': 'assets/icons/plans/gold.svg',
      'price': 4900,
      'period': 'شهرياً',
      'color': AppColors.amber,
      'features': [
        '✅ استشارات غير محدودة 24/7',
        '✅ خصم 35% على جميع الأدوية',
        '✅ تحاليل منزلية مجانية',
        '✅ أولوية في الحجز',
        '✅ طبيب شخصي مخصص',
        '✅ تقارير صحية أسبوعية',
        '✅ فيديوهات تثقيفية حصرية',
        '✅ دعم فني VIP',
      ],
      'isPopular': true,
      'discount': 'وفر 40% سنوياً - 35,000 ر.ي فقط',
    },
    {
      'id': 'plan_family',
      'name': 'باقة العائلة',
      'icon': 'assets/icons/plans/family.svg',
      'price': 7500,
      'period': 'شهرياً',
      'color': AppColors.purple,
      'features': [
        '✅ كل مميزات الذهبية',
        '✅ حتى 5 أفراد من العائلة',
        '✅ استشارات أطفال مجانية',
        '✅ متابعة حمل وولادة',
        '✅ تطعيمات مجانية للأطفال',
        '✅ طبيب عائلة مخصص',
        '✅ خصم 50% على الأدوية',
        '✅ تقارير عائلية شاملة',
      ],
      'isPopular': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  // ✅ تمرير البيانات المطلوبة فقط (بدون planId)
  void _openPayment(String planName, String planPrice, String planIcon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionPaymentScreen(
          planName: planName,
          planPrice: planPrice,
          planEmoji: planIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الباقات والاشتراكات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'الباقات'),
            Tab(text: 'الاستشارات'),
            Tab(text: 'العروض'),
            Tab(text: 'حسابي'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildPlansTab(),
          _buildConsultationsTab(),
          _buildOffersTab(),
          _buildMyAccountTab(),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('اختر الباقة المناسبة لك', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('وفر أكثر مع الباقات السنوية - خصم يصل إلى 40%', style: TextStyle(color: AppColors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        ..._plans.map((plan) => _planCard(plan)),
      ]),
    );
  }

  Widget _planCard(Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == _plans.indexOf(plan);
    final color = plan['color'] as Color;
    final price = plan['price'] as int;
    final isFree = price == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? color : Colors.transparent, width: isSelected ? 2 : 0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (plan['isPopular'] == true)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(20)),
            child: const Text('🌟 الأكثر شيوعاً', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        Row(children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: SvgPicture.asset(plan['icon'], colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(plan['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            if (plan['discount'] != null) Text(plan['discount'], style: const TextStyle(fontSize: 10, color: AppColors.success)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(isFree ? 'مجاني' : '${price.toStringAsFixed(0)} ر.ي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(plan['period'], style: const TextStyle(fontSize: 10, color: AppColors.grey)),
          ]),
        ]),
        const Divider(height: 20),
        ...plan['features'].map<Widget>((f) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(f, style: TextStyle(fontSize: 12, color: f.startsWith('✅') ? AppColors.success : AppColors.grey)),
        )),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: isSelected ? null : () => _openPayment(plan['name'], price.toString(), plan['icon']),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? color : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isSelected ? 'باقتك الحالية' : 'اشترك الآن', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildConsultationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('أسعار الاستشارات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('اختر نوع الاستشارة المناسبة', style: TextStyle(color: AppColors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        _consultCard('assets/icons/consultations/text.svg', 'استشارة نصية', 'تواصل مع الطبيب عبر الرسائل النصية', '1,500', AppColors.info),
        _consultCard('assets/icons/consultations/audio.svg', 'استشارة صوتية', 'مكالمة صوتية مباشرة', '3,000', AppColors.success),
        _consultCard('assets/icons/consultations/video.svg', 'استشارة مرئية', 'مكالمة فيديو مباشرة', '5,000', AppColors.primary),
        _consultCard('assets/icons/consultations/emergency.svg', 'استشارة طارئة', 'استشارة فورية للحالات الطارئة', '8,000', AppColors.error),
        _consultCard('assets/icons/consultations/home_visit.svg', 'زيارة منزلية', 'زيارة طبيب إلى منزلك', '10,000', AppColors.purple),
        _consultCard('assets/icons/consultations/checkup.svg', 'كشف عام', 'فحص طبي شامل', '4,000', AppColors.teal),
      ]),
    );
  }

  Widget _consultCard(String iconPath, String title, String desc, String price, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: SvgPicture.asset(iconPath, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$price ر.ي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () => _openPayment(title, price, iconPath),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(70, 28),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: const TextStyle(fontSize: 11),
            ).copyWith(elevation: MaterialStateProperty.all(0)),
            child: const Text('احجز'),
          ),
        ]),
      ]),
    );
  }

  Widget _buildOffersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('عروض حصرية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('لفترة محدودة - سارع بالحجز', style: TextStyle(color: AppColors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        _offerCard('assets/icons/offers/discount.svg', 'خصم 50% على الباقة الذهبية', 'للثلاثة أشهر الأولى', '4,900', '2,450', AppColors.amber, 'ينتهي خلال 7 أيام'),
        _offerCard('assets/icons/offers/family_offer.svg', 'باقة العائلة + استشارات مجانية', 'شهر مجاناً عند الاشتراك السنوي', '7,500', '0', AppColors.purple, 'العرض محدود'),
        _offerCard('assets/icons/offers/health_check.svg', 'فحص شامل مجاني', 'مع أي باقة سنوية - تحاليل + كشف', '15,000', 'مجاناً', AppColors.success, 'لأول 100 مشترك'),
      ]),
    );
  }

  Widget _offerCard(String iconPath, String title, String desc, String oldPrice, String newPrice, Color color, String badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.05), color.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: SvgPicture.asset(iconPath, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(badge, style: TextStyle(fontSize: 9, color: color)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        const SizedBox(height: 10),
        Row(children: [
          Text(oldPrice, style: const TextStyle(fontSize: 13, color: AppColors.grey, decoration: TextDecoration.lineThrough)),
          const SizedBox(width: 8),
          Text(newPrice, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _openPayment(title, newPrice, iconPath),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('استفد الآن'),
          ),
        ]),
      ]),
    );
  }

  Widget _buildMyAccountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('اشتراكي الحالي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.amber, Color(0xFFFF8F00)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            SvgPicture.asset('assets/icons/plans/gold.svg', width: 50, height: 50, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            const SizedBox(height: 8),
            const Text('الباقة الذهبية', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('سارية حتى 6 يونيو 2026', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text('الدفع التالي: 6 يونيو - 4,900 ر.ي', style: TextStyle(color: Colors.white, fontSize: 12)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('طرق الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _payMethod('assets/icons/payment/floosak_icon.png', 'فلوسك', '**** 4582'),
        _payMethod('assets/icons/payment/كاش_icon.png', 'كاش', '**** 7891'),
        _payMethod('assets/icons/payment/Jawali_icon.png', 'جوالي', '**** 3456'),
        const SizedBox(height: 20),
        const Text('إدارة الاشتراك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(leading: const Icon(Icons.upgrade, color: AppColors.primary), title: const Text('ترقية الباقة'), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () => _tab.animateTo(0)),
        ListTile(leading: const Icon(Icons.pause_circle, color: AppColors.warning), title: const Text('تجميد الاشتراك'), subtitle: const Text('حتى 3 أشهر'), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () {}),
        ListTile(leading: const Icon(Icons.cancel, color: AppColors.error), title: const Text('إلغاء الاشتراك'), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () {}),
      ]),
    );
  }

  Widget _payMethod(String iconPath, String name, String number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Row(children: [
        Image.asset(iconPath, width: 28, height: 28, errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_wallet)),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(number, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      ]),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }
}
