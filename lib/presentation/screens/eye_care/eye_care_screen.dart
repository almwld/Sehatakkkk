import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/vision_test/vision_test_screen.dart';

class EyeCareScreen extends StatelessWidget {
  const EyeCareScreen({super.key});

  void _openDoctors(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorsListScreen()));
  }

  void _showInfo(BuildContext context, String title, List<String> points) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...points.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(point, style: const TextStyle(fontSize: 13, height: 1.45))),
                  ]),
                )),
            const SizedBox(height: 6),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); _openDoctors(context); }, icon: const Icon(Icons.person_search_rounded), label: const Text('البحث عن طبيب عيون'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF4F6F7),
      appBar: AppBar(title: const Text('صحة العين'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF3949AB), borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.visibility_rounded, color: Colors.white, size: 30)),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('رعاية العين', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text('اختبارات داخلية ومتابعة مع طبيب العيون عند الحاجة.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4))])),
            ]),
          ),
          const SizedBox(height: 18),
          Text('الاختبارات والخدمات', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _test(context, 'اختبار حدة البصر', 'اختبار النظر التفاعلي داخل التطبيق', Icons.visibility_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionTestScreen()))),
          _test(context, 'فحص تمييز الألوان', 'إرشادات وفحص أولي للأعراض', Icons.palette_outlined, () => _showInfo(context, 'فحص تمييز الألوان', ['اختبار تمييز الألوان يعطي مؤشراً أولياً ولا يغني عن فحص طبي متخصص.', 'إذا كانت صعوبة تمييز الألوان جديدة أو تؤثر على حياتك اليومية، احجز موعداً مع طبيب عيون.'])),
          _test(context, 'فحص جفاف العين', 'تقييم أولي للأعراض ونصائح العناية', Icons.water_drop_outlined, () => _showInfo(context, 'فحص جفاف العين', ['من الأعراض الشائعة الجفاف والحرقان والشعور بوجود جسم غريب أو زيادة الدموع.', 'الأعراض المستمرة أو المصحوبة بألم أو تغير في الرؤية تحتاج إلى تقييم طبي.'])),
          const SizedBox(height: 12),
          Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('العناية اليومية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _tip('قاعدة 20-20-20 عند استخدام الشاشات لفترات طويلة.'),
            _tip('احرص على الإضاءة المناسبة وخذ فواصل منتظمة.'),
            _tip('الفحص الطبي الدوري مهم خصوصاً عند وجود أعراض أو عوامل خطورة.'),
          ]))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _openDoctors(context), icon: const Icon(Icons.person_search_rounded), label: const Text('عرض أطباء العيون والحجز'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
        ],
      ),
    );
  }

  Widget _test(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.grey))])), const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary)])));
  }

  Widget _tip(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 18), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.35)))]));
}
