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
    ('الفطور', 'بيض أو لبن + حبوب كاملة + خضار أو فاكهة', 'نوّع المكونات واضبط الكمية حسب احتياجك'),
    ('الغداء', 'بروتين مناسب + حبوب أو نشويات + خضار', 'اجعل الخضار والبقوليات جزءاً متكرراً من الوجبات'),
    ('العشاء', 'بروتين مناسب + خضار + مصدر حبوب مناسب', 'لا تحتاج وجبة موحدة للجميع؛ راعِ احتياجك'),
    ('وجبة خفيفة', 'فاكهة أو مكسرات غير مملحة أو لبن', 'اختر خيارات أقل في السكر المضاف والملح'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5FBF8),
    appBar: AppBar(title: const Text('التغذية الصحية'), backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('التغذية الصحية', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 7), Text('إرشادات عملية لبناء وجبات متنوعة ومتوازنة، مع أدوات تساعدك على متابعة احتياجك.', style: TextStyle(color: Colors.white70, height: 1.5))])),
      const SizedBox(height: 18),
      const Text('هدفك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: goals.map((g) => ChoiceChip(label: Text(g), selected: _goal == g, onSelected: (_) => setState(() => _goal = g))).toList()),
      const SizedBox(height: 18),
      Row(children: [const Expanded(child: Text('الوجبات اليومية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalorieCalculatorScreen())), icon: const Icon(Icons.calculate_rounded, size: 18), label: const Text('حاسبة السعرات'))]),
      const SizedBox(height: 10),
      ...meals.map((m) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 9), child: ListTile(leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.success.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.restaurant_rounded, color: AppColors.success)), title: Text(m.$1, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${m.$2}\n${m.$3}'), isThreeLine: true))),
      const SizedBox(height: 8),
      _section('طبق متوازن', ['اجعل الخضروات والفواكه والحبوب الكاملة والبقوليات ومصادر البروتين ضمن تنوعك الغذائي.', 'اختر الدهون غير المشبعة قدر الإمكان، وقلل الملح والسكريات الحرة والمضافة.']),
      _section('الماء والسوائل', ['اجعل الماء خياراً أساسياً، وعدّل كمية السوائل وفق الجو والنشاط والحالة الصحية.', 'لا تعتمد على المشروبات السكرية لترطيبك اليومي.']),
      _section('العادات الذكية', ['اقرأ الملصق الغذائي عندما يكون متاحاً، وانتبه للسكر والملح والدهون المشبعة.', 'تجنب الحميات القاسية والمكملات غير الضرورية، ولا تستخدم مكملات علاجية دون إرشاد مناسب.', 'الحمل والرضاعة والأطفال والأمراض المزمنة تحتاج إرشاداً غذائياً خاصاً.']),
      _section('متى تحتاج مختصاً؟', ['فقدان أو زيادة وزن غير مقصودة، نقص غذائي مشتبه، اضطراب أكل، مرض مزمن، أو حاجة لخطة غذائية علاجية تستدعي تقييماً فردياً.']),
    ]),
  );

  Widget _section(String title, List<String> points) => Card(elevation: 0, margin: const EdgeInsets.only(top: 8), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(height: 9), ...points.map((p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.success), const SizedBox(width: 8), Expanded(child: Text(p, style: const TextStyle(height: 1.4)))])))])));
}
