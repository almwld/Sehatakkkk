import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class PhysiotherapyScreen extends StatelessWidget {
  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);
  const PhysiotherapyScreen({super.key});

  final List<Map<String, dynamic>> _services = const [
    {'name': 'علاج آلام الظهر', 'price': '250', 'sessions': '6 جلسات', 'color': AppColors.warning, 'desc': 'تمارين لتقوية عضلات الظهر'},
    {'name': 'علاج آلام الرقبة', 'price': '200', 'sessions': '5 جلسات', 'color': AppColors.info, 'desc': 'تخفيف آلام الرقبة والكتف'},
    {'name': 'علاج خشونة الركبة', 'price': '300', 'sessions': '8 جلسات', 'color': AppColors.error, 'desc': 'تقوية عضلات الركبة'},
    {'name': 'تأهيل إصابات رياضية', 'price': '350', 'sessions': '10 جلسات', 'color': AppColors.success, 'desc': 'برنامج تأهيلي للرياضيين'},
    {'name': 'علاج الشلل النصفي', 'price': '400', 'sessions': '12 جلسة', 'color': AppColors.purple, 'desc': 'تأهيل حركي بعد الجلطات'},
    {'name': 'تدليك استرخائي', 'price': '150', 'sessions': 'جلسة', 'color': AppColors.teal, 'desc': 'تدليك عضلي لتخفيف التوتر'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text(_t(context, 'العلاج الطبيعي'), style: const TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(16)), child: Column(children: [const Icon(Icons.accessibility_new, color: Colors.white, size: 48), const SizedBox(height: 8), Text(_t(context, 'علاج طبيعي في منزلك'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(_t(context, 'جلسات مخصصة مع أفضل الأخصائيين'), style: const TextStyle(color: Colors.white70, fontSize: 12))])),
        const SizedBox(height: 16),
        for (final s in _services) Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: (s['color'] as Color).withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.fitness_center, color: s['color'], size: 22)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_t(context, s['name'] as String), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(_t(context, s['desc'] as String), style: const TextStyle(fontSize: 10, color: AppColors.grey))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(AppStrings.of(context).formatCurrency(num.tryParse(s['price'] as String) ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)), Text(_t(context, s['sessions'] as String), style: const TextStyle(fontSize: 9, color: AppColors.grey)), const SizedBox(height: 6), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), minimumSize: Size.zero), child: Text(_t(context, 'احجز'), style: const TextStyle(fontSize: 10)))])])),
      ])),
    );
  }
}
