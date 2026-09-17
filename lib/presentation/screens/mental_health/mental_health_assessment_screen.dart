import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MentalHealthAssessmentScreen extends StatefulWidget {
  const MentalHealthAssessmentScreen({super.key});
  @override State<MentalHealthAssessmentScreen> createState() => _MentalHealthAssessmentScreenState();
}

class _MentalHealthAssessmentScreenState extends State<MentalHealthAssessmentScreen> {
  int _index = 0, _score = 0;
  bool _done = false;
  final questions = const [
    'خلال الأيام الأخيرة، هل شعرت بتوتر أو قلق يعيق يومك؟',
    'هل واجهت صعوبة متكررة في النوم أو الاسترخاء؟',
    'هل فقدت الاهتمام بأشياء كنت تستمتع بها؟',
    'هل أثرت مشاعرك في العمل أو الدراسة أو علاقاتك؟',
    'هل شعرت بصعوبة في التعامل مع ضغوطك اليومية؟',
    'هل تشعر أنك تحتاج إلى دعم نفسي أو شخص تتحدث معه؟',
  ];
  final answers = const ['أبداً', 'أحياناً', 'غالباً', 'تقريباً كل يوم'];

  void _answer(int value) {
    if (_index == questions.length - 1) {
      setState(() { _score += value; _done = true; });
    } else {
      setState(() { _score += value; _index++; });
    }
  }
  void _reset() => setState(() { _index = 0; _score = 0; _done = false; });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('التقييم النفسي الأولي'), backgroundColor: AppColors.info, foregroundColor: Colors.white),
    body: Padding(padding: const EdgeInsets.all(20), child: _done ? _result() : ListView(children: [
      const Text('استبيان توعوي', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('أجب عن كل سؤال وفق ما ينطبق عليك خلال الفترة الأخيرة.'),
      const SizedBox(height: 18),
      LinearProgressIndicator(value: (_index + 1) / questions.length),
      const SizedBox(height: 22),
      Text('سؤال ${_index + 1} من ${questions.length}', style: const TextStyle(color: AppColors.grey)),
      const SizedBox(height: 12),
      Text(questions[_index], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5)),
      const SizedBox(height: 24),
      ...answers.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _answer(e.key), child: Text(e.value, style: const TextStyle(fontSize: 15))))),
      const SizedBox(height: 8),
      const Text('هذا الاستبيان لا يشخّص الاكتئاب أو القلق أو أي اضطراب نفسي.', style: TextStyle(fontSize: 12, color: AppColors.grey)),
    ])),
  );

  Widget _result() {
    final max = questions.length * 3;
    final level = _score <= max * .33 ? 'مؤشر منخفض في هذا الاستبيان' : _score <= max * .66 ? 'مؤشر متوسط في هذا الاستبيان' : 'مؤشر مرتفع في هذا الاستبيان';
    return ListView(children: [
      const SizedBox(height: 30),
      const Icon(Icons.psychology_alt_rounded, size: 72, color: AppColors.info),
      const SizedBox(height: 16),
      const Text('ملخص التقييم', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text('$_score من $max', textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(level, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 18),
      const Card(child: Padding(padding: EdgeInsets.all(15), child: Text('النتيجة مؤشر توعوي وليست تشخيصاً. إذا كانت الأعراض مستمرة أو تؤثر في حياتك، ناقشها مع مختص. عند وجود خطر فوري على النفس أو الآخرين، اطلب المساعدة الطارئة المحلية فوراً.', style: TextStyle(height: 1.5)))),
      const SizedBox(height: 18),
      ElevatedButton(onPressed: _reset, child: const Text('إعادة التقييم')),
    ]);
  }
}
