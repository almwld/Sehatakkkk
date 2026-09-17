import 'dart:math';
import 'package:flutter/material.dart';

class VisionTestScreen extends StatefulWidget {
  const VisionTestScreen({super.key});
  @override State<VisionTestScreen> createState() => _VisionTestScreenState();
}

class _VisionTestScreenState extends State<VisionTestScreen> {
  final _rng = Random();
  final _directions = const ['أعلى', 'يمين', 'أسفل', 'يسار'];
  final _patterns = const [1, 2, 3, 0, 1, 2, 3, 0];
  int _round = 0, _score = 0, _rotation = 1;
  bool _finished = false;

  void _answer(String value) {
    if (value == _directions[_rotation]) _score++;
    if (_round == _patterns.length - 1) {
      setState(() => _finished = true);
    } else {
      setState(() { _round++; _rotation = (_patterns[_round] + _rng.nextInt(2)) % 4; });
    }
  }

  void _reset() => setState(() { _round = 0; _score = 0; _finished = false; _rotation = _patterns[0]; });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('اختبار جودة النظر'), backgroundColor: const Color(0xFF3949AB), foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(16), child: _finished ? _result() : _test()),
  );

  Widget _test() {
    final size = 92.0 - (_round * 8.0);
    return ListView(children: [
      const Card(child: Padding(padding: EdgeInsets.all(15), child: Text('اختبار تفاعلي أولي لتمييز اتجاه فتحة الحرف. اجلس بوضع مريح، حافظ على مسافة ثابتة من الشاشة، لا تكبّر العرض، واستخدم إضاءة جيدة. لا يغني الاختبار عن فحص حدة البصر بأدوات سريرية.', style: TextStyle(height: 1.5)))),
      const SizedBox(height: 14),
      Text('المحاولة ${_round + 1} من ${_patterns.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: (_round + 1) / _patterns.length),
      const SizedBox(height: 26),
      Center(
        child: SizedBox(
          width: 240,
          height: 190,
          child: Center(
            child: Transform.rotate(
              angle: _rotation * pi / 2,
              child: Text('E', style: TextStyle(fontSize: size, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      const Center(child: Text('إلى أي اتجاه تتجه فتحة الحرف؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      const SizedBox(height: 18),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5, children: _directions.map((d) => OutlinedButton(onPressed: () => _answer(d), child: Text(d))).toList()),
    ]);
  }

  Widget _result() {
    final ratio = _score / _patterns.length;
    final label = ratio >= .875 ? 'أداء جيد في هذا الاختبار الأولي' : ratio >= .625 ? 'توجد أخطاء؛ يُنصح بإعادة الاختبار أو إجراء فحص نظر' : 'يُفضّل إجراء فحص نظر لدى مختص';
    return ListView(shrinkWrap: true, children: [
      const SizedBox(height: 28),
      const Icon(Icons.visibility_rounded, size: 72, color: Color(0xFF3949AB)),
      const SizedBox(height: 14),
      const Text('تقييم جودة النظر', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text('$_score من ${_patterns.length}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 18),
      const Card(child: Padding(padding: EdgeInsets.all(15), child: Text('هذا تقييم أولي داخل التطبيق ولا يقيس حدة البصر بوحدة سريرية، ولا يحدد الحاجة إلى نظارة أو علاج. إذا كان لديك تشوش مستمر، ازدواجية، ألم، ومضات أو فقد مفاجئ للرؤية، اطلب تقييماً طبياً ولا تعتمد على الاختبار.', style: TextStyle(height: 1.5)))),
      const SizedBox(height: 18),
      ElevatedButton(onPressed: _reset, child: const Text('إعادة الاختبار')),
    ]);
  }
}
