import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});
  @override State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String _mood = 'جيد';
  final Set<String> _factors = {};
  final _note = TextEditingController();
  final moods = const ['ممتاز', 'جيد', 'متوسط', 'منخفض', 'متعب'];
  final factors = const ['النوم', 'العمل', 'الدراسة', 'العائلة', 'النشاط', 'الألم'];

  @override void dispose() { _note.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تتبع المزاج'), backgroundColor: AppColors.purple, foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('كيف تشعر اليوم؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: moods.map((m) => ChoiceChip(label: Text(m), selected: _mood == m, onSelected: (_) => setState(() => _mood = m))).toList()),
      const SizedBox(height: 24),
      const Text('ما الذي قد يؤثر في مزاجك؟', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: factors.map((f) => FilterChip(
          label: Text(f),
          selected: _factors.contains(f),
          onSelected: (v) => setState(() {
            if (v) {
              _factors.add(f);
            } else {
              _factors.remove(f);
            }
          }),
        )).toList(),
      ),
      const SizedBox(height: 20),
      TextField(controller: _note, maxLines: 4, decoration: const InputDecoration(labelText: 'ملاحظات اليوم', hintText: 'اكتب ما تريد تذكره...', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل حالتك لهذا اليوم'))), child: const Text('حفظ الحالة')),
      const SizedBox(height: 20),
      const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('التتبع يساعدك على ملاحظة الأنماط مع الوقت، لكنه ليس أداة لتشخيص الاكتئاب أو أي اضطراب نفسي.'))),
    ]),
  );
}
