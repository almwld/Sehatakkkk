import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/diet_plan/diet_plan_screen.dart';
import 'package:sehatak/presentation/screens/health_tools/calorie_calculator_screen.dart';

class NutritionHealthScreen extends StatefulWidget {
  const NutritionHealthScreen({super.key});
  @override State<NutritionHealthScreen> createState() => _NutritionHealthScreenState();
}

class _NutritionHealthScreenState extends State<NutritionHealthScreen> {
  double _water = 4;
  String _goal = 'توازن غذائي';
  final goals = const ['توازن غذائي', 'إدارة الوزن', 'بناء اللياقة'];

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5FBF8),
    appBar: AppBar(title: const Text('التغذية الصحية'), backgroundColor: AppColors.success, foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('غذاء متوازن لصحة أفضل', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 7), Text('خطوات عملية لاختيار وجبات متنوعة ومتابعة الماء والاحتياجات الغذائية.', style: TextStyle(color: Colors.white70, height: 1.5))])),
      const SizedBox(height: 18),
      const Text('هدفك الغذائي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Wrap(spacing: 8, children: goals.map((g) => ChoiceChip(label: Text(g), selected: _goal == g, onSelected: (_) => setState(() => _goal = g))).toList()),
      const SizedBox(height: 18),
      const Text('خدمات التغذية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      _item(context, 'الخطة الغذائية', 'وجبات منظمة حسب الهدف', Icons.restaurant_menu_rounded, const DietPlanScreen()),
      _item(context, 'حاسبة السعرات', 'سجل الأطعمة واحسب مجموع السعرات', Icons.calculate_rounded, const CalorieCalculatorScreen()),
      _item(context, 'المغذيات الأساسية', 'تعرف على البروتين والألياف والفيتامينات والمعادن', Icons.grass_rounded, null),
      _item(context, 'التغذية في المراحل الخاصة', 'إرشادات عامة للأطفال والحمل والرضاعة وكبار السن', Icons.family_restroom_rounded, null),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('متابعة شرب الماء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 8), Text('${_water.toInt()} أكواب مسجلة'), Slider(value: _water, min: 0, max: 12, divisions: 12, activeColor: AppColors.success, onChanged: (v) => setState(() => _water = v)), const Text('احتياج السوائل يختلف حسب العمر والنشاط والطقس والحالة الصحية؛ لا تستخدم رقماً ثابتاً كتشخيص أو وصفة شخصية.')]))),
      const SizedBox(height: 14),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('أساسيات الوجبة المتوازنة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 10), Text('• نوّع مصادر الخضروات والفواكه والحبوب الكاملة والبقوليات والبروتينات.'), Text('• اختر مصادر دهون صحية وقلل الأطعمة شديدة التصنيع والملح والسكريات المضافة.'), Text('• اجعل الكمية مناسبة لاحتياجك، وتجنب الحميات القاسية دون إشراف متخصص.'), Text('• عند وجود مرض مزمن أو حمل أو احتياج غذائي خاص، ناقش الخطة مع مختص.')])))
    ]),
  );

  Widget _item(BuildContext context, String title, String subtitle, IconData icon, Widget? screen) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 9), child: ListTile(leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.success.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.success)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15), onTap: screen == null ? () => _showInfo(context, title) : () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen))));

  void _showInfo(BuildContext context, String title) => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), child: Text('$title\n\nتعرّف على هذا الموضوع وفق احتياجاتك الفردية، واستعن بمختص تغذية عند وجود حالة صحية أو احتياج غذائي خاص.', style: const TextStyle(fontSize: 16, height: 1.5))));
}