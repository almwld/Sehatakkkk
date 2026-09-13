import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  Timer? _timer;
  DateTime? _startedAt;
  Duration _lastDuration = Duration.zero;
  static const _startKey = 'sleep_tracking_start';
  static const _lastKey = 'sleep_tracking_last_minutes';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_startKey);
    final last = prefs.getInt(_lastKey) ?? 0;
    if (raw != null) {
      _startedAt = DateTime.tryParse(raw);
      if (_startedAt != null) _startTicker();
    }
    if (mounted) setState(() => _lastDuration = Duration(minutes: last));
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }

  Future<void> _start() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_startKey, now.toIso8601String());
    setState(() => _startedAt = now);
    _startTicker();
  }

  Future<void> _stop() async {
    final start = _startedAt;
    if (start == null) return;
    final duration = DateTime.now().difference(start);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_startKey);
    await prefs.setInt(_lastKey, duration.inMinutes);
    _timer?.cancel();
    setState(() { _startedAt = null; _lastDuration = duration; });
  }

  Duration get _currentDuration => _startedAt == null ? _lastDuration : DateTime.now().difference(_startedAt!);

  String _format(Duration d) => '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final active = _startedAt != null;
    final duration = _currentDuration;
    final hours = duration.inMinutes / 60;
    final quality = (hours / 8).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع النوم')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF18244A), borderRadius: BorderRadius.circular(26)), child: Column(children: [
          Icon(active ? Icons.bedtime_rounded : Icons.nights_stay_rounded, color: Colors.white, size: 58),
          const SizedBox(height: 12),
          Text(active ? 'جلسة النوم قيد التتبع' : 'سجّل نومك اليوم', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(_format(duration), style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
          Text(active ? 'بدأت ${_startedAt!.hour.toString().padLeft(2, '0')}:${_startedAt!.minute.toString().padLeft(2, '0')}' : 'آخر مدة نوم مسجلة', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: active ? _stop : _start, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)), child: Text(active ? 'إنهاء النوم وحفظ المدة' : 'بدء تتبع النوم'))),
        ])),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ملخص الليلة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 14),
          Row(children: [Expanded(child: _item('المدة', _format(duration))), Expanded(child: _item('الهدف', '08:00'))]),
          const SizedBox(height: 16), LinearProgressIndicator(value: quality, minHeight: 9, borderRadius: BorderRadius.circular(10), color: AppColors.primary),
          const SizedBox(height: 10), Text(quality >= .9 ? 'ممتاز، اقتربت من هدف النوم.' : 'الهدف الصحي المعتاد للبالغين نحو 7–9 ساعات.', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]))),
        const SizedBox(height: 12),
        const Text('ملاحظة: هذه الشاشة تسجل مدة جلسة النوم التي تبدأها وتُنهيها. لا تعتبر تشخيصاً طبياً ولا تقيس مراحل النوم تلقائياً.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
    );
  }

  Widget _item(String title, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20))]);
}
