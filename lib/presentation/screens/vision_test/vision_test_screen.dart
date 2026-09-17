import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class VisionTestScreen extends StatefulWidget {
  const VisionTestScreen({super.key});
  @override State<VisionTestScreen> createState() => _VisionTestScreenState();
}

class _VisionTestScreenState extends State<VisionTestScreen> {
  final directions = const ['أعلى', 'يمين', 'أسفل', 'يسار'];
  final correct = const ['أعلى', 'يمين', 'أسفل', 'يسار', 'أعلى', 'يمين'];
  int _round = 0;
  int _score = 0;
  bool _finished = false;

  void _answer(String value) {
    if (value == correct[_round]) _score++;
    if (_round == correct.length - 1) { setState(() => _finished = true); } else { setState(() => _round++); }
  }

  void _reset() => setState(() { _round = 0; _score = 0; _finished = false; });

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('اختبار جودة النظر'), backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(16), child: _finished ? _result() : _test()),
  );

  Widget _test() {
    final size = 88.0 - (_round * 9);
    return ListView(children: [
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('اختبار تفاعلي أولي. اجلس على مسافة ثابتة ومريحة من الشاشة، لا تكبّر النص، واستخدم إضاءة جيدة. الاختبار لا يقيس حدة البصر الطبية بدقة ولا يغني عن فحص طبي.', style: TextStyle(height: 1.5)))),
      const SizedBox(height: 14),
      Text('المحاولة ${_round + 1} من ${correct.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), LinearProgressIndicator(value: (_round + 1) / correct.length),
      const SizedBox(height: 30),
      Center(child: SizedBox(width: 220, height: 180, child: Center(child: Transform.rotate(angle: _round % 4 * 1.5707963, child: Text('E', style: TextStyle(fontSize: size, fontWeight: FontWeight.bold))))),
      const Center(child: Text('إلى أي اتجاه تتجه الفتحـة؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      const SizedBox(height: 18),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5, children: directions.map((d) => OutlinedButton(onPressed: () => _answer(d), child: Text(d))).toList()),
    ]);
  }

  Widget _result() {
    final ratio = _score / correct.length;
    final label = ratio >= .85 ? 'أداء جيد في هذا الاختبار الأولي' : ratio >= .60 ? 'توجد أخطاء تستحق إعادة الاختبار أو فحص النظر' : 'يفضل إجراء فحص نظر لدى مختص';
    return Center(child: ListView(shrinkWrap: true, children: [const Icon(Icons.visibility_rounded, size: 72, color: Color(0xFF3949AB)), const SizedBox(height: 14), const Text('تقييم الاختبار', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text('$_score من ${correct.length}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)), const SizedBox(height: 18), const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('النتيجة مؤشر تفاعلي للتوعية وليست قياساً للحدة البصرية بوحدة سريرية. إذا كان لديك تشوش أو ازدواجية أو ألم أو فقد مفاجئ للرؤية، لا تعتمد على الاختبار واطلب تقييماً طبياً سريعاً.'))), const SizedBox(height: 18), ElevatedButton(onPressed: _reset, child: const Text('إعادة الاختبار'))]));
  }
}