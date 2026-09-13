import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class StepsTrackingScreen extends StatefulWidget {
  const StepsTrackingScreen({super.key});

  @override
  State<StepsTrackingScreen> createState() => _StepsTrackingScreenState();
}

class _StepsTrackingScreenState extends State<StepsTrackingScreen> {
  StreamSubscription<StepCount>? _stepsSubscription;
  int _steps = 0;
  int _baseline = 0;
  bool _available = false;
  String? _error;
  static const _baselineKey = 'steps_baseline_date';
  static const _baselineValueKey = 'steps_baseline_value';

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _dateKey(DateTime.now());
      final savedDate = prefs.getString(_baselineKey);
      final savedBaseline = prefs.getInt(_baselineValueKey);
      _baseline = savedDate == today ? (savedBaseline ?? 0) : 0;
      if (savedDate != today) {
        await prefs.setString(_baselineKey, today);
        await prefs.setInt(_baselineValueKey, 0);
      }
      _stepsSubscription = Pedometer.stepCountStream.listen(_onStepCount, onError: _onError);
    } catch (e) {
      if (mounted) setState(() => _error = 'تعذر الوصول إلى حساس الخطوات في هذا الجهاز.');
    }
  }

  void _onStepCount(StepCount event) async {
    if (_baseline == 0) {
      _baseline = event.steps;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_baselineValueKey, _baseline);
    }
    if (!mounted) return;
    setState(() {
      _available = true;
      _steps = (event.steps - _baseline).clamp(0, 999999);
      _error = null;
    });
  }

  void _onError(dynamic _) {
    if (mounted) setState(() { _available = false; _error = 'حساس الخطوات غير متاح حالياً.'; });
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  void dispose() {
    _stepsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_steps / 8000).clamp(0.0, 1.0);
    final km = _steps * 0.00075;
    final calories = _steps * 0.04;
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع الخطوات')), 
      body: RefreshIndicator(
        onRefresh: () async { setState(() {}); await Future<void>.delayed(const Duration(milliseconds: 250)); },
        child: ListView(padding: const EdgeInsets.all(18), children: [
          _hero(progress),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _metric('المسافة', '${km.toStringAsFixed(2)} كم', Icons.route_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _metric('السعرات', '${calories.toStringAsFixed(0)} kcal', Icons.local_fire_department_rounded)),
          ]),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            const Icon(Icons.flag_rounded, color: AppColors.primary), const SizedBox(width: 12),
            const Expanded(child: Text('هدف اليوم', style: TextStyle(fontWeight: FontWeight.w800))),
            Text('8,000 خطوة', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
          ]))),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 12),
          Text(_available ? 'يتم تحديث الخطوات من حساس الحركة في الجهاز.' : 'في انتظار بيانات حساس الحركة…', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _hero(double progress) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(26)),
    child: Column(children: [
      const Text('خطوات اليوم', style: TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 12),
      SizedBox(width: 190, height: 190, child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(value: progress, strokeWidth: 12, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white)),
        Column(mainAxisSize: MainAxisSize.min, children: [Text('$_steps', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)), const Text('خطوة', style: TextStyle(color: Colors.white70))]),
      ])),
      const SizedBox(height: 10),
      Text('${(progress * 100).round()}% من هدفك اليومي', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _metric(String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Icon(icon, color: AppColors.primary), const SizedBox(height: 8), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 3), Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12))])));
}
