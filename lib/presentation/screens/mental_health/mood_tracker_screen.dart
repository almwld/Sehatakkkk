import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});
  @override State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  String _mood = 'جيد';
  final Set<String> _factors = {};
  final _note = TextEditingController();
  final moods = const ['ممتاز', 'جيد', 'متوسط', 'منخفض', 'متعب'];
  final factors = const ['النوم', 'العمل', 'الدراسة', 'العائلة', 'النشاط', 'الألم'];
  bool _saving = false;

  Future<void> _saveMood() async {
    if (_saving) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ToastService.showError(_t(context, 'يرجى تسجيل الدخول أولاً')); return; }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('mood_entries').add({
        'mood': _mood, 'factors': _factors.toList(), 'note': _note.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { _note.clear(); ToastService.showSuccess(_t(context, 'تم حفظ حالة المزاج')); }
    } catch (e) { if (mounted) ToastService.showError(_t(context, 'تعذر حفظ حالة المزاج')); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  @override void dispose() { _note.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_t(context, 'تتبع المزاج')), backgroundColor: AppColors.purple, foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(_t(context, 'كيف تشعر اليوم؟'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: moods.map((m) => ChoiceChip(label: Text(_t(context, m)), selected: _mood == m, onSelected: (_) => setState(() => _mood = m))).toList()),
      const SizedBox(height: 24),
      Text(_t(context, 'ما الذي قد يؤثر في مزاجك؟'), style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: factors.map((f) => FilterChip(
          label: Text(_t(context, f)),
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
      TextField(controller: _note, maxLines: 4, decoration: InputDecoration(labelText: _t(context, 'ملاحظات اليوم'), hintText: _t(context, 'اكتب ما تريد تذكره...'), border: const OutlineInputBorder())),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: _saving ? null : _saveMood, child: Text(_t(context, _saving ? 'جاري الحفظ...' : 'حفظ الحالة'))),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_t(context, 'التتبع يساعدك على ملاحظة الأنماط مع الوقت، لكنه ليس أداة لتشخيص الاكتئاب أو أي اضطراب نفسي.')))),
    ]),
  );
}
