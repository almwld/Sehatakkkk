import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PregnancyFollowUpScreen extends StatefulWidget {
  const PregnancyFollowUpScreen({super.key});
  @override State<PregnancyFollowUpScreen> createState() => _PregnancyFollowUpScreenState();
}

class _PregnancyFollowUpScreenState extends State<PregnancyFollowUpScreen> {
  int _week = 12;

  static const _contacts = [
    'حتى 12 أسبوعاً: بداية المتابعة وتأكيد الحمل وتقييم التاريخ الصحي والفحوصات المناسبة.',
    '20 أسبوعاً: متابعة نمو الجنين وتقييم الحمل والفحص المناسب حسب خطة الطبيبة.',
    '26 أسبوعاً: متابعة الأم والجنين ومراجعة نتائج الفحوصات والتغذية والأعراض.',
    '30 أسبوعاً: متابعة الضغط والوزن ونمو الجنين والاستعداد للثلث الأخير.',
    '34 أسبوعاً: مراجعة خطة الولادة والاستعداد للطوارئ والرضاعة.',
    '36 أسبوعاً: متابعة أقرب للولادة وتقييم وضع الجنين حسب الحالة.',
    '38 أسبوعاً: متابعة علامات المخاض وخطة الولادة والمتابعة حسب تقييم الفريق الطبي.',
    '40 أسبوعاً: تقييم الحمل وخطة المتابعة أو الولادة حسب حالة الأم والجنين.',
  ];

  static const _tests = [
    'تحاليل الدم والبول الأساسية وفق تقييم مقدم الرعاية.',
    'قياس ضغط الدم والوزن في زيارات المتابعة.',
    'فحص سكر الحمل عادةً في منتصف الحمل وفق الخطة الطبية.',
    'فحوصات العدوى مثل التهاب الكبد B والزهري وفيروس نقص المناعة وفق الإرشادات المحلية.',
    'تصوير بالموجات فوق الصوتية لتقدير عمر الحمل أو تقييم الجنين وفق التوقيت والخطة الطبية.',
    'متابعة نمو الجنين وحركته في النصف الثاني من الحمل حسب عمر الحمل والتقييم السريري.',
  ];

  static const _tips = [
    'ابدئي المتابعة مبكراً بعد معرفة الحمل ولا تتركي الزيارات الدورية.',
    'اتبعي خطة التغذية والمكملات التي يحددها مقدم الرعاية، ولا تبدئي دواءً أو مكملًا جديداً دون استشارته.',
    'احرصي على النشاط البدني المناسب للحمل إذا لم توجد موانع طبية، وخذي قسطاً كافياً من الراحة.',
    'تجنبي التدخين والكحول والمواد الضارة، وراجعي الأدوية الحالية مع الطبيب أو الصيدلي.',
    'جهزي خطة للولادة والنقل والطوارئ ومكان الرعاية قبل نهاية الحمل.',
    'بعد الولادة، تستمر الرعاية للأم والطفل وتشمل الرضاعة والصحة النفسية وتنظيم الأسرة والمتابعة الطبية.',
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const coral = Color(0xFFD46A7E);
    const plum = Color(0xFF8F5B8A);
    final bg = dark ? const Color(0xFF1A1117) : const Color(0xFFFFF8FA);
    final progress = (_week / 40).clamp(0.0, 1.0);
    final due = DateTime.now().add(Duration(days: ((40 - _week) * 7)));
    return Theme(
      data: Theme.of(context).copyWith(scaffoldBackgroundColor: bg, colorScheme: Theme.of(context).colorScheme.copyWith(primary: coral, secondary: plum)),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('رعاية الحوامل', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: coral, foregroundColor: Colors.white, elevation: 0),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 30), children: [
          _hero(progress, due),
          const SizedBox(height: 12),
          _weekSelector(),
          const SizedBox(height: 18),
          _title('الرعاية الدورية للحمل'),
          const SizedBox(height: 8),
          ..._contacts.map((s) => _card(Icons.event_available_rounded, s)),
          const SizedBox(height: 12),
          _title('الفحوصات والمتابعة'),
          const SizedBox(height: 8),
          ..._tests.map((s) => _card(Icons.science_rounded, s)),
          const SizedBox(height: 12),
          _title('نصائح الحمل'),
          const SizedBox(height: 8),
          ..._tips.map((s) => _card(Icons.lightbulb_outline_rounded, s)),
          const SizedBox(height: 12),
          _dangerSigns(context),
          const SizedBox(height: 12),
          _scopeNote(),
        ]),
      ),
    );
  }

  Widget _hero(double progress, DateTime due) => Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD46A7E), Color(0xFF8F5B8A)]), borderRadius: BorderRadius.all(Radius.circular(26))), child: Column(children: [Row(children: [const CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.pregnant_woman_rounded, color: Colors.white, size: 33)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('متابعة الحمل من البداية حتى الولادة', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text('الأسبوع $_week من 40', style: const TextStyle(color: Colors.white70, fontSize: 12))]))]), const SizedBox(height: 16), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))), const SizedBox(height: 8), Align(alignment: Alignment.centerRight, child: Text('موعد تقديري: ${due.day}/${due.month}/${due.year}', style: const TextStyle(color: Colors.white70, fontSize: 11)))]));

  Widget _weekSelector() => Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [const Expanded(child: Text('حددي أسبوع الحمل للاطلاع على مراحل المتابعة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))), IconButton(onPressed: _week > 1 ? () => setState(() => _week--) : null, icon: const Icon(Icons.remove_circle_outline_rounded)), Text('$_week', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), IconButton(onPressed: _week < 40 ? () => setState(() => _week++) : null, icon: const Icon(Icons.add_circle_outline_rounded))]));

  Widget _card(IconData icon, String text) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(13), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFFD46A7E)), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.5)))])));

  Widget _dangerSigns(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFD46A7E).withOpacity(.09), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFD46A7E).withOpacity(.22))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('متى تطلبين رعاية عاجلة؟', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), SizedBox(height: 7), Text('نزيف مهبلي شديد، ألم شديد أو مستمر، ضيق تنفس شديد، فقدان الوعي، صداع شديد مع اضطراب الرؤية، أو نقص ملحوظ في حركة الجنين بعد أن أصبحت الحركة منتظمة: تواصلي مع الرعاية الطبية العاجلة أو الطوارئ وفق حالتك.', style: TextStyle(fontSize: 12, height: 1.55))]));

  Widget _scopeNote() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF8F5B8A).withOpacity(.07), borderRadius: BorderRadius.circular(16)), child: const Text('هذه الشاشة مخصصة للحمل والنساء والتوليد فقط، ولا تخلط بياناتها مع شاشة صحة الطفل أو شاشة صحة المرأة العامة. جدول الزيارات والفحوصات قد يتغير حسب حالة الأم والجنين وإرشادات البلد والطبيب.', style: TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w600)));

  Widget _title(String text) => Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800));
}