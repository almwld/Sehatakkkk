import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/health_tools/calorie_calculator_screen.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});
  @override State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  String _goal = 'توازن غذائي';
  final goals = const ['توازن غذائي', 'إدارة الوزن', 'بناء اللياقة'];
  final meals = const [
    ('الفطور', 'بيض أو لبن + حبوب كاملة + خضار/فاكهة', 'وجبة متنوعة ومشبعة'),
    ('الغداء', 'بروتين مناسب + حبوب/نشويات + خضار', 'اجعل الخضار جزءاً أساسياً من الوجبة'),
    ('العشاء', 'بروتين خفيف + خضار + مصدر حبوب مناسب', 'اضبط الكمية حسب احتياجك'),
    ('وجبة خفيفة', 'فاكهة أو مكسرات غير مملحة أو لبن', 'اختر خيارات أقل في السكر المضاف'),
  ];

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5FBF8),
    appBar: AppBar(title: const Text('التغذية الصحية'), backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('خطة غذائية متوازنة', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 7), Text('اختر هدفك ثم استخدم الاقتراحات كأساس مرن، وليس كخطة علاجية شخصية.', style: TextStyle(color: Colors.white70, height: 1.5))])),
      const SizedBox(height: 18),
      const Text('هدفك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Wrap(spacing: 8, children: goals.map((g) => ChoiceChip(label: Text(g), selected: _goal == g, onSelected: (_) => setState(() => _goal = g))).toList()),
      const SizedBox(height: 18),
      Row(children: [const Expanded(child: Text('وجبات مقترحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalorieCalculatorScreen())), icon: const Icon(Icons.calculate_rounded, size: 18), label: const Text('السعرات'))]),
      const SizedBox(height: 10),
      ...meals.map((m) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 9), child: ListTile(leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.success.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.restaurant_rounded, color: AppColors.success)), title: Text(m.$1, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${m.$2}\n${m.$3}'), isThreeLine: true))),
      const SizedBox(height: 12),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('أساسيات التغذية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), SizedBox(height: 10), Text('• نوّع الخضروات والفواكه والبقوليات والحبوب الكاملة ومصادر البروتين.'), Text('• اختر الدهون غير المشبعة قدر الإمكان وقلل الملح والسكريات المضافة.'), Text('• اجعل الماء خياراً أساسياً، مع مراعاة اختلاف احتياج السوائل بين الأشخاص.'), Text('• لا تتبع حمية قاسية أو تستخدم مكملات دون معرفة الحاجة والجرعة المناسبة.'), Text('• الحمل والرضاعة والأطفال والأمراض المزمنة تحتاج إرشاداً غذائياً مناسباً للحالة.')]))) ,
      const SizedBox(height: 12),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('متى تستشير مختصاً؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), SizedBox(height: 8), Text('عند فقدان أو زيادة وزن غير مقصودة، اضطراب أكل، نقص غذائي مشتبه، مرض مزمن، أو حاجة لخطة علاجية خاصة.')])))
    ]),
  );
}