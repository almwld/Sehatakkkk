import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MentalHealthAssessmentScreen extends StatefulWidget {
  const MentalHealthAssessmentScreen({super.key});
  @override State<MentalHealthAssessmentScreen> createState() => _MentalHealthAssessmentScreenState();
}

class _MentalHealthAssessmentScreenState extends State<MentalHealthAssessmentScreen> {
  int _index = 0;
  int _score = 0;
  bool _done = false;
  final questions = const [
    'خلال الأيام الأخيرة، هل شعرت بتوتر أو قلق يعيق يومك؟',
    'هل واجهت صعوبة متكررة في النوم أو الاسترخاء؟',
    'هل فقدت الاهتمام بأشياء كنت تستمتع بها؟',
    'هل أثرت مشاعرك في العمل أو الدراسة أو علاقاتك؟',
    'هل تشعر أنك تحتاج إلى دعم نفسي أو شخص تتحدث معه؟',
  ];
  void _answer(int value) { if (_index == questions.length - 1) setState(() { _score += value; _done = true; }); else setState(() { _score += value; _index++; }); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('التقييم النفسي الأولي'), backgroundColor: AppColors.info, foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(20), child: _done ? _result() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LinearProgressIndicator(value: (_index + 1) / questions.length), const SizedBox(height: 24),
      Text('سؤال ${_index + 1} من ${questions.length}', style: const TextStyle(color: AppColors.grey)), const SizedBox(height: 14),
      Text(questions[_index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5)), const SizedBox(height: 28),
      ...['أبداً', 'أحياناً', 'غالباً', 'تقريباً كل يوم'].asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _answer(e.key), child: Text(e.value, style: const TextStyle(fontSize: 15))))),
      const SizedBox(height: 12), const Text('هذا استبيان توعوي وليس تشخيصاً طبياً.', style: TextStyle(fontSize: 12, color: AppColors.grey)),
    ])),
  );
  Widget _result() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.psychology_alt_rounded, size: 72, color: AppColors.info), const SizedBox(height: 18), const Text('ملخص التقييم', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text('النتيجة $_score من ${questions.length * 3}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 16), const Text('إذا كانت الأعراض مستمرة أو تؤثر في حياتك، تحدث مع مختص نفسي. عند وجود خطر فوري على نفسك أو الآخرين، اطلب المساعدة الطارئة المحلية فوراً.', textAlign: TextAlign.center), const SizedBox(height: 24), ElevatedButton(onPressed: () => setState(() { _index = 0; _score = 0; _done = false; }), child: const Text('إعادة التقييم'))]));
}