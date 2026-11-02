import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/models/child_model.dart';
import 'package:sehatak/core/services/child_service.dart';

class ChildSectionScreen extends StatelessWidget {
  final String childId;
  final String section;
  const ChildSectionScreen({super.key, required this.childId, required this.section});

  static const titles = <String,String>{
    'growth':'النمو والتطور','vaccines':'التطعيمات','nutrition':'التغذية','sleep':'النوم',
    'dental':'صحة الفم والأسنان','checkups':'الفحوصات الدورية','vision':'النظر والسمع',
    'activity':'النشاط واللعب','mental':'الصحة النفسية','firstaid':'الإسعافات الأولية',
  };

  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t(context, titles[section] ?? 'صحة الطفل')), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: StreamBuilder<ChildModel?>(
        stream: ChildService.instance.streamChild(childId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('${_t(context, 'تعذر تحميل الملف:')} ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final child = snapshot.data;
          if (child == null) return Center(child: Text(_t(context, 'لم يُعثر على ملف الطفل')));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(child: ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.12), child: Text(child.name.isEmpty ? 'ط' : child.name.substring(0,1))),
                title: Text(child.name), subtitle: Text(child.ageLabel),
              )),
              const SizedBox(height: 12),
              ..._content(child, context),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _content(ChildModel child, BuildContext context) {
    final age = child.ageInMonths;
    String text;
    switch (section) {
      case 'nutrition': text = _t(context, 'قدّم غذاءً متنوعاً ومناسباً للعمر. تجنب العسل قبل عمر سنة وانتبه لمخاطر الاختناق.'); break;
      case 'sleep': text = '${_t(context, 'النوم الموصى به يعتمد على العمر: ')}${age < 3 ? '14–17' : age < 12 ? '12–16' : age < 36 ? '11–14' : '10–13'} ${_t(context, 'ساعة خلال 24 ساعة.')}'; break;
      case 'dental': text = _t(context, 'ابدأ العناية بالفم مبكراً واستخدم معجون فلورايد بكمية مناسبة للعمر وفق إرشادات طبيب الأسنان.'); break;
      case 'vaccines': text = _t(context, 'تابع بطاقة التطعيم وجدول وزارة الصحة؛ الجرعات والمواعيد تختلف حسب البرنامج الوطني وحالة الطفل.'); break;
      case 'growth': text = 'الوزن: '+(child.weight?.toStringAsFixed(1) ?? '-')+' كجم\nالطول: '+(child.height?.toStringAsFixed(1) ?? '-')+' سم\nمحيط الرأس: '+(child.headCircumference?.toStringAsFixed(1) ?? '-')+' سم'; break;
      case 'checkups': text = _t(context, 'تابع النمو والتغذية والتطور والسمع والنظر وصحة الفم ضمن الزيارات الوقائية المناسبة للعمر.'); break;
      case 'vision': text = _t(context, 'راجع الطبيب عند وجود مشكلة مستمرة في الرؤية أو السمع أو صعوبة تتبع الأشياء أو الاستجابة للأصوات.'); break;
      case 'activity': text = _t(context, 'شجّع الحركة واللعب والتفاعل المناسب للعمر وتحت إشراف آمن.'); break;
      case 'mental': text = _t(context, 'روتين واضح واستماع واحتواء ولعب وتواصل يومي يدعم الصحة النفسية.'); break;
      case 'firstaid': text = _t(context, 'في صعوبة التنفس أو فقدان الوعي أو نزيف شديد اطلب الطوارئ فوراً. إسعافات الاختناق والحروق تختلف حسب العمر وشدة الحالة.'); break;
      default: text = _t(context, 'محتوى القسم غير متوفر.');
    }
    return [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(text, style: const TextStyle(height: 1.7)))),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Text(_t(context, 'المعلومات للتثقيف والمتابعة ولا تغني عن تقييم طبيب الأطفال عند الحاجة.'), style: TextStyle(color: Colors.grey)))),
    ];
  }
}
