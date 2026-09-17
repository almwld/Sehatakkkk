import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChildHealthScreen extends StatelessWidget {
  const ChildHealthScreen({super.key});

  static const _services = [
    ['النمو والتطور', 'متابعة الطول والوزن ومراحل التطور والمهارات', Icons.insights_rounded],
    ['التطعيمات', 'جدول التطعيمات والتذكير بالمواعيد حسب عمر الطفل', Icons.vaccines_rounded],
    ['التغذية', 'إرشادات الرضاعة والتغذية المتوازنة حسب المرحلة العمرية', Icons.restaurant_rounded],
    ['النوم', 'روتين النوم الصحي ومتابعة عادات النوم', Icons.bedtime_rounded],
    ['صحة الفم والأسنان', 'العناية بالأسنان واللثة ومواعيد طبيب الأسنان', Icons.health_and_safety_rounded],
    ['الفحوصات الدورية', 'متابعة الفحوصات الوقائية ومواعيد الطبيب', Icons.fact_check_rounded],
    ['النظر والسمع', 'مؤشرات تستدعي فحص النظر والسمع والمتابعة', Icons.visibility_rounded],
    ['النشاط واللعب', 'أفكار آمنة للحركة واللعب والتعلم حسب العمر', Icons.sports_soccer_rounded],
    ['الصحة النفسية', 'الأمان العاطفي والسلوك والتواصل مع الطفل', Icons.favorite_rounded],
    ['الإسعافات الأولية', 'إرشادات عامة للتعامل مع الحالات الطارئة حتى الوصول للرعاية', Icons.medical_services_rounded],
  ];

  static const _tips = [
    'قدّم للطفل غذاءً متنوعاً ومناسباً لعمره، واهتم بالماء والنظافة.',
    'تابع التطعيمات والفحوصات الوقائية ولا تنتظر ظهور أعراض لإجراء المتابعة الروتينية.',
    'وفّر بيئة آمنة للنوم واللعب، وأبعد الأدوية والمواد الخطرة عن متناول الطفل.',
    'شجّع القراءة والحديث واللعب والتفاعل؛ التعلم يبدأ من السنوات الأولى.',
    'راقب أي تغير مستمر في السلوك أو الحركة أو الكلام وناقشه مع طبيب الأطفال.',
    'عند وجود صعوبة تنفس أو فقدان وعي أو نزيف شديد، اطلب الطوارئ فوراً.',
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const sky = Color(0xFF38BDF8);
    const mint = Color(0xFF34D399);
    final bg = dark ? const Color(0xFF08131D) : const Color(0xFFF2FBFF);
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: sky, secondary: mint),
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: const Text('صحة الطفل', style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: sky,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            _hero(context),
            const SizedBox(height: 16),
            _sectionTitle('ملف الطفل'),
            const SizedBox(height: 8),
            _profileCard(context),
            const SizedBox(height: 18),
            _sectionTitle('الخدمات والمتابعة'),
            const SizedBox(height: 8),
            ..._services.map((s) => _serviceCard(context, s)),
            const SizedBox(height: 10),
            _sectionTitle('نصائح يومية للأهل'),
            const SizedBox(height: 8),
            ..._tips.map((tip) => _tipCard(context, tip)),
            const SizedBox(height: 12),
            _notice(context),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF34D399)]),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 31, backgroundColor: Colors.white24, child: Icon(Icons.child_care_rounded, color: Colors.white, size: 34)),
          SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('عناية متكاملة بطفلك', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('النمو والتطعيمات والتغذية والنوم والتعلم والسلامة في مكان واحد.', style: TextStyle(color: Colors.white, height: 1.45, fontSize: 12)),
          ])),
        ],
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.face_rounded, color: Color(0xFF0284C7), size: 30)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('أضف ملف طفلك', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)), SizedBox(height: 4), Text('العمر وتاريخ الميلاد والجنس والطول والوزن والتطعيمات.', style: TextStyle(fontSize: 11, height: 1.4))])),
          IconButton(onPressed: () => _message(context, 'يمكن ربط بيانات الطفل بملفه الصحي عند توفر نموذج الملف في الحساب.'), icon: const Icon(Icons.add_circle_outline_rounded)),
        ]),
      ),
    );
  }

  Widget _serviceCard(BuildContext context, List<dynamic> service) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
        leading: Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(.10), borderRadius: BorderRadius.circular(13)), child: Icon(service[2] as IconData, color: const Color(0xFF0284C7))),
        title: Text(service[0] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Text(service[1] as String, style: const TextStyle(fontSize: 11, height: 1.35)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
        onTap: () => _message(context, '${service[0]}\n\n${service[1]}\n\nالمعلومات داخل التطبيق للتثقيف والمتابعة ولا تغني عن تقييم طبيب الأطفال عند الحاجة.'),
      ),
    );
  }

  Widget _tipCard(BuildContext context, String tip) {
    return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(13), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF0284C7)), const SizedBox(width: 10), Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, height: 1.5)))])));
  }

  Widget _notice(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF38BDF8).withOpacity(.18))), child: const Text('هذه الشاشة مخصصة لصحة الطفل فقط. الحمل وصحة المرأة لهما شاشات مستقلة داخل صحة الأسرة.', style: TextStyle(fontSize: 11, height: 1.5, fontWeight: FontWeight.w600)));
  }

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800));

  void _message(BuildContext context, String text) => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('صحة الطفل'), content: Text(text, style: const TextStyle(height: 1.5)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))]));
}