import 'package:flutter/material.dart';

class WomensHealthScreen extends StatelessWidget {
  const WomensHealthScreen({super.key});

  static const _rose = Color(0xFFB85C8A);
  static const _lavender = Color(0xFF8B7AB8);

  static const _services = [
    ['صحة الدورة الشهرية', 'تسجيل الدورة والأعراض والتذكيرات الصحية', Icons.calendar_month_rounded],
    ['الصحة الإنجابية', 'استشارات ومعلومات عن الخصوبة وتنظيم الأسرة قبل الحمل', Icons.favorite_border_rounded],
    ['صحة الثدي', 'التوعية بالتغيرات التي تستدعي التقييم الطبي والفحص المناسب', Icons.health_and_safety_rounded],
    ['صحة عنق الرحم', 'التوعية بفحوصات الكشف حسب العمر والبرنامج المحلي', Icons.fact_check_rounded],
    ['صحة العظام', 'التغذية والنشاط والعوامل التي تدعم صحة العظام', Icons.accessibility_new_rounded],
    ['الصحة النفسية', 'متابعة المزاج والقلق والضغط النفسي وطلب الدعم', Icons.psychology_rounded],
    ['التغذية والوزن', 'إرشادات عامة للتغذية المتوازنة والنشاط الصحي', Icons.restaurant_rounded],
    ['صحة المسالك البولية', 'التوعية بالأعراض الشائعة ومتى يلزم الفحص الطبي', Icons.water_drop_rounded],
    ['الجلدية والشعر', 'العناية اليومية ومتابعة التغيرات المستمرة', Icons.face_rounded],
    ['استشارة نساء وولادة', 'الوصول إلى طبيبة أو اختصاصي عند الحاجة', Icons.medical_services_rounded],
  ];

  static const _screenings = [
    'قياس ضغط الدم والوزن ومراجعة عوامل الخطورة ضمن الرعاية الروتينية.',
    'فحص سرطان عنق الرحم وفق إرشادات بلدك وعُمرك وتاريخك الصحي.',
    'تقييم الثدي عند ظهور كتلة أو تغير مستمر أو إفراز غير معتاد، مع الالتزام ببرامج الفحص المحلية.',
    'فحوصات السكري والدهون وفقر الدم أو غيرها عند تحديدها حسب العمر والأعراض وعوامل الخطورة.',
    'مراجعة صحة الأسنان والعينين والصحة النفسية والنوم ضمن الرعاية الوقائية حسب الحاجة.',
  ];

  static const _tips = [
    'احرصي على غذاء متنوع ونشاط بدني مناسب لحالتك الصحية، وتجنبي التدخين.',
    'راجعي الأدوية والمكملات مع المختص، خصوصًا عند التخطيط للحمل أو أثناء الرضاعة.',
    'سجلي الأعراض غير المعتادة ومدة استمرارها لتسهيل التقييم الطبي.',
    'اطلبي تقييمًا طبيًا عند نزيف غير معتاد، ألم شديد أو مستمر، كتلة جديدة، أو تغير صحي مقلق.',
    'استمرار الحزن أو القلق أو صعوبة أداء الحياة اليومية يستحق طلب الدعم.',
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF17121A) : const Color(0xFFFFF7FB);
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: _rose, secondary: _lavender),
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: const Text('صحة المرأة', style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: _rose,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            _hero(),
            const SizedBox(height: 16),
            _title('الخدمات الصحية'),
            const SizedBox(height: 8),
            ..._services.map((s) => _service(context, s)),
            const SizedBox(height: 12),
            _title('الفحوصات والمتابعة الدورية'),
            const SizedBox(height: 8),
            ..._screenings.map(_bullet),
            const SizedBox(height: 14),
            _title('نصائح لصحة المرأة'),
            const SizedBox(height: 8),
            ..._tips.map(_tip),
            const SizedBox(height: 12),
            _separationNote(),
          ],
        ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_rose, _lavender]),
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
        child: const Row(children: [
          CircleAvatar(radius: 31, backgroundColor: Colors.white24, child: Icon(Icons.female_rounded, color: Colors.white, size: 34)),
          SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('رعاية صحية متكاملة للمرأة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('الدورة والصحة الإنجابية والثدي وعنق الرحم والعظام والصحة النفسية والرعاية الوقائية.', style: TextStyle(color: Colors.white, fontSize: 12, height: 1.45)),
          ])),
        ]),
      );

  Widget _service(BuildContext context, List<dynamic> service) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: _rose.withOpacity(.10), borderRadius: BorderRadius.circular(13)),
            child: Icon(service[2] as IconData, color: _rose),
          ),
          title: Text(service[0] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          subtitle: Text(service[1] as String, style: const TextStyle(fontSize: 11, height: 1.35)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
          onTap: () => _info(context, service[0] as String, service[1] as String),
        ),
      );

  Widget _bullet(String text) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle_outline_rounded, color: _rose),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.5))),
          ]),
        ),
      );

  Widget _tip(String text) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_outline_rounded, color: _lavender),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.5))),
          ]),
        ),
      );

  Widget _title(String text) => Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800));

  Widget _separationNote() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _rose.withOpacity(.07), borderRadius: BorderRadius.circular(16)),
        child: const Text('هذه الشاشة مخصصة لصحة المرأة العامة والوقائية. رعاية الحمل والمتابعة الأسبوعية للحمل لها شاشة مستقلة.', style: TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w600)),
      );

  void _info(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text('$body\n\nالمحتوى توعوي ولا يستبدل التشخيص أو خطة الطبيبة.', style: const TextStyle(height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسنًا'))],
      ),
    );
  }
}
