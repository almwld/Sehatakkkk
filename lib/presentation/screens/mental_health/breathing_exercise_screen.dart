import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});
  @override State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  Timer? _timer;
  int _seconds = 60;
  bool _running = false;
  String _phase = 'استعد';

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() { _running = false; _phase = 'متوقف مؤقتاً'; });
      return;
    }
    setState(() { _running = true; _phase = 'شهيق ببطء'; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds <= 1) {
        _timer?.cancel();
        setState(() { _seconds = 60; _running = false; _phase = 'اكتملت الجلسة'; });
        return;
      }
      setState(() {
        _seconds--;
        final elapsed = 60 - _seconds;
        _phase = elapsed % 8 < 4 ? 'شهيق ببطء' : 'زفير ببطء';
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() { _seconds = 60; _running = false; _phase = 'استعد'; });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_t(context, 'تمارين التنفس والاسترخاء')), backgroundColor: AppColors.success, foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Card(child: Padding(padding: const EdgeInsets.all(15), child: Text(_t(context, 'جلسة قصيرة للتنفس الهادئ. اجلس في وضع مريح واترك التنفس طبيعياً دون إجبار.'), style: TextStyle(height: 1.5)))),
      const SizedBox(height: 28),
      Text(_t(context, _phase), textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Center(child: AnimatedContainer(duration: const Duration(seconds: 3), curve: Curves.easeInOut, width: _running ? 190 : 140, height: _running ? 190 : 140, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(.12), border: Border.all(color: AppColors.success, width: 2)), child: Center(child: Text('${_seconds}s', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))))),
      const SizedBox(height: 28),
      Text(_t(context, 'نمط الجلسة: 4 ثوانٍ شهيق ثم 4 ثوانٍ زفير. أوقف التمرين إذا شعرت بدوخة أو ضيق نفس.'), textAlign: TextAlign.center, style: TextStyle(height: 1.45)),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _toggle, child: Text(_t(context, _running ? 'إيقاف مؤقت' : 'بدء التمرين')))),
      const SizedBox(height: 8),
      TextButton(onPressed: _reset, child: Text(_t(context, 'إعادة الجلسة'))),
    ]),
  );
}
