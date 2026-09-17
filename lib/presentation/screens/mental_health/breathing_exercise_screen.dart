import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});
  @override State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  Timer? _timer;
  int _seconds = 60;
  bool _running = false;
  String _phase = 'استعد';

  void _toggle() {
    if (_running) { _timer?.cancel(); setState(() { _running = false; _phase = 'متوقف مؤقتاً'; }); return; }
    setState(() { _running = true; _phase = 'شهيق ببطء'; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds <= 1) { _timer?.cancel(); setState(() { _seconds = 60; _running = false; _phase = 'اكتملت الجلسة'; }); return; }
      setState(() { _seconds--; final elapsed = 60 - _seconds; _phase = elapsed % 8 < 4 ? 'شهيق ببطء' : 'زفير ببطء'; });
    });
  }
  @override void dispose() { _timer?.cancel(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تمارين التنفس'), backgroundColor: AppColors.success, foregroundColor: Colors.white),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(_phase, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      AnimatedContainer(duration: const Duration(seconds: 3), curve: Curves.easeInOut, width: _running ? 190 : 140, height: _running ? 190 : 140, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(.12), border: Border.all(color: AppColors.success, width: 2)), child: Center(child: Text('${_seconds}s', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 28),
      const Text('تنفس براحة وبوتيرة مريحة. أوقف التمرين إذا شعرت بدوخة أو ضيق نفس.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _toggle, child: Text(_running ? 'إيقاف مؤقت' : 'بدء التمرين'))),
    ]))),
  );
}