import 'package:flutter/material.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> firstAidTips = [
    {
      'title': 'الجروح والنزيف',
      'description': 'اضغط على الجرح بقطعة قماش نظيفة، ارفع الجزء المصاب فوق مستوى القلب',
      'icon': '🩹',
    },
    {
      'title': 'الحروق',
      'description': 'ضع المنطقة المحروقة تحت ماء بارد جارٍ لمدة 10-15 دقيقة',
      'icon': '🔥',
    },
    {
      'title': 'الكسور',
      'description': 'ثبت العضو المصاب، لا تحاول تحريكه، اتصل بالإسعاف',
      'icon': '🦴',
    },
    {
      'title': 'الاختناق',
      'description': 'استخدم مناورة هيمليك: ضع قبضة يدك فوق السرة وادفع للداخل وللأعلى',
      'icon': '🫁',
    },
    {
      'title': 'التسمم',
      'description': 'اتصل بالطوارئ فوراً، لا تحاول إحداث التقيؤ إلا بإرشاد طبي',
      'icon': '☠️',
    },
    {
      'title': 'الصدمة الكهربائية',
      'description': 'افصل التيار، لا تلمس المصاب بيديك العاريتين، اتصل بالطوارئ',
      'icon': '⚡',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإسعافات الأولية'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: firstAidTips.length,
          itemBuilder: (context, index) {
            final tip = firstAidTips[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: Text(
                  tip['icon']!,
                  style: const TextStyle(fontSize: 30),
                ),
                title: Text(
                  tip['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tip['description']!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
