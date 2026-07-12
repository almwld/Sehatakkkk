import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['باقات', 'استشارات', 'عروض', 'حسابي'];

  final List<Map<String, dynamic>> _plans = [
    {'id': 'free', 'name': 'مجانية', 'price': 0, 'color': Colors.grey.shade400, 'icon': '🆓', 'features': ['استشارات محدودة', 'مواعيد أساسية', 'دعم فني']},
    {'id': 'silver', 'name': 'فضية', 'price': 2499, 'color': Colors.grey.shade600, 'icon': '🥈', 'features': ['استشارات غير محدودة', 'مواعيد متقدمة', 'دعم فني 24/7', 'خصم 10% على الصيدلية']},
    {'id': 'gold', 'name': 'ذهبية', 'price': 4999, 'color': const Color(0xFFD4AF37), 'icon': '🥇', 'features': ['استشارات غير محدودة', 'مواعيد متقدمة', 'دعم فني 24/7', 'خصم 20% على الصيدلية', 'تحاليل مجانية']},
    {'id': 'platinum', 'name': 'بلاتينية', 'price': 9999, 'color': const Color(0xFFE5E4E2), 'icon': '💎', 'features': ['جميع مزايا الذهبية', 'استشارات منزلية', 'طبيب خاص', 'خصم 30% على الصيدلية']},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاشتراكات'), bottom: TabBar(tabs: _tabs.map((tab) => Tab(text: tab)).toList(), onTap: (index) => setState(() => _selectedTab = index))),
      body: _selectedTab == 0 ? _buildPlansTab() : Center(child: Text(_tabs[_selectedTab], style: const TextStyle(fontSize: 18))),
    );
  }

  Widget _buildPlansTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        final isFree = plan['price'] == 0;
        final color = plan['color'] as Color;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: color == const Color(0xFFD4AF37) ? BorderSide(color: color, width: 2) : BorderSide.none),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(plan['icon'], style: const TextStyle(fontSize: 28)), const SizedBox(width: 12), Expanded(child: Text(plan['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))), if (!isFree) Text('${plan['price']} ر.ي/شهر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)) else const Text('مجاناً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green))]),
                const SizedBox(height: 12),
                ...(plan['features'] as List<String>).map((feature) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Icon(Icons.check_circle, color: color == const Color(0xFFD4AF37) ? AppColors.primary : color, size: 18), const SizedBox(width: 8), Text(feature)]))),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: isFree ? Colors.grey : AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)), child: Text(isFree ? 'الاشتراك الحالي' : 'اشترك الآن', style: const TextStyle(color: Colors.white)))),
              ],
            ),
          ),
        );
      },
    );
  }
}
