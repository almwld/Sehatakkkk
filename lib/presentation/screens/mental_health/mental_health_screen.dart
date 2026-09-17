import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/mental_health/mood_tracker_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/breathing_exercise_screen.dart';
import 'package:sehatak/presentation/screens/mental_health/mental_health_assessment_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';

class MentalHealthScreen extends StatelessWidget {
  const MentalHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF11101A) : const Color(0xFFF8F6FC),
      appBar: AppBar(title: const Text('الصحة النفسية'), backgroundColor: AppColors.purple, foregroundColor: Colors.white, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _hero(),
        const SizedBox(height: 18),
        const Text('الخدمات والأدوات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _service(context, 'التقييم النفسي الأولي', 'استبيان توعوي قصير مع ملخص للنتيجة', Icons.psychology_rounded, const MentalHealthAssessmentScreen()),
        _service(context, 'تتبع المزاج', 'سجل المزاج والعوامل المرتبطة به يومياً', Icons.mood_rounded, const MoodTrackerScreen()),
        _service(context, 'التنفس والاسترخاء', 'جلسة تنفس موجهة مع مؤقت', Icons.air_rounded, const BreathingExerciseScreen()),
        _service(context, 'دعم وإرشاد', 'الوصول إلى الأطباء والمختصين المتاحين', Icons.support_agent_rounded, const DoctorsListScreen()),
        const SizedBox(height: 18),
        const Text('العناية اليومية', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _tipCard('النوم', 'حافظ على مواعيد نوم واستيقاظ منتظمة قدر الإمكان، وقلل المنبهات قرب وقت النوم.'),
        _tipCard('الحركة والتواصل', 'نشاط بدني مناسب وتواصل داعم مع أشخاص تثق بهم قد يساعدان على تحسين الرفاه النفسي.'),
        _tipCard('إدارة الضغط', 'قسّم المهام الكبيرة، خذ فواصل قصيرة، واستخدم تمارين التنفس عند الشعور بالتوتر.'),
        _tipCard('متى تطلب المساعدة؟', 'إذا استمرت الأعراض أو أثرت في النوم أو العمل أو الدراسة أو العلاقات، تحدث مع مختص.'),
        const SizedBox(height: 8),
        const Card(child: Padding(padding: EdgeInsets.all(15), child: Text('تنبيه مهم: الأدوات والتقييمات للتوعية والمتابعة الذاتية وليست تشخيصاً أو بديلاً عن العلاج. عند وجود خطر فوري على النفس أو الآخرين، اطلب المساعدة الطارئة المحلية فوراً.', style: TextStyle(height: 1.5)))),
      ]),
    );
  }

  Widget _hero() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('مساحة آمنة للعناية بنفسك', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 7), Text('توعية، متابعة يومية، تمارين استرخاء، وإمكانية الوصول إلى مختص عند الحاجة.', style: TextStyle(color: Colors.white70, height: 1.5))]));

  Widget _service(BuildContext context, String title, String subtitle, IconData icon, Widget screen) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.purple.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.purple)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen))));

  Widget _tipCard(String title, String body) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 9), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(body, style: const TextStyle(height: 1.45))])));
}
