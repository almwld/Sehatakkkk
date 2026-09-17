import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/mental_health/mood_tracker_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/breathing_exercise_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_assessment_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';

class MentalHealthScreen extends StatelessWidget {
  const MentalHealthScreen({super.key});

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F6FC),
    appBar: AppBar(title: const Text('الصحة النفسية'), backgroundColor: AppColors.purple, foregroundColor: Colors.white, elevation: 0),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مساحة آمنة للعناية بنفسك', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 7), Text('أدوات للتوعية وتتبع المزاج والاسترخاء، مع إمكانية الوصول إلى مختص عند الحاجة.', style: TextStyle(color: Colors.white70, height: 1.5))])),
      const SizedBox(height: 20),
      const Text('الخدمات النفسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      _service(context, 'التقييم النفسي الأولي', 'أسئلة توعوية لفهم الأعراض ومتى تحتاج للدعم', Icons.psychology_rounded, const MentalHealthAssessmentScreen()),
      _service(context, 'تتبع المزاج', 'سجل مزاجك والعوامل المرتبطة به', Icons.mood_rounded, const MoodTrackerScreen()),
      _service(context, 'تمارين التنفس والاسترخاء', 'جلسة تنفس موجهة قصيرة', Icons.air_rounded, const BreathingExerciseScreen()),
      _service(context, 'استشارة مختص', 'الوصول إلى الأطباء والمختصين المتاحين', Icons.support_agent_rounded, const DoctorsListScreen()),
      const SizedBox(height: 18),
      const Text('عادات داعمة يومياً', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('النوم المنتظم', style: TextStyle(fontWeight: FontWeight.bold)), Text('حافظ على وقت نوم واستيقاظ متقارب قدر الإمكان.'), SizedBox(height: 12), Text('الحركة والتواصل', style: TextStyle(fontWeight: FontWeight.bold)), Text('نشاط بدني مناسب وتواصل اجتماعي داعم قد يساعدان على تحسين الرفاه النفسي.'), SizedBox(height: 12), Text('اطلب المساعدة', style: TextStyle(fontWeight: FontWeight.bold)), Text('الأعراض المستمرة أو المؤثرة في الحياة اليومية تستحق التحدث مع مختص.'))])),
      const SizedBox(height: 12),
      const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('ملاحظة: الأدوات والتقييمات هنا للتوعية والمتابعة الذاتية وليست بديلاً عن التشخيص أو العلاج الطبي. في الخطر الفوري على النفس أو الآخرين، اطلب المساعدة الطارئة المحلية.'))),
    ]),
  );

  Widget _service(BuildContext context, String title, String subtitle, IconData icon, Widget screen) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.purple.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.purple)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen))));
}