import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sehatak/core/services/health_tracking_service.dart';
import 'package:sehatak/core/services/steps/steps_service.dart';
import 'package:sehatak/presentation/widgets/futuristic/glass_card.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_app_bar.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_background.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_line_chart.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_period_selector.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_stat_card.dart';
import 'package:sehatak/presentation/widgets/futuristic/holographic_number.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});
  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  final StepsService _stepsService = StepsService.instance;
  StreamSubscription<StepsSnapshot>? _subscription;
  int _steps = 0;
  int _calories = 0;
  double _distanceKm = 0;
  List<double> _history = const [];

  @override
  void initState() {
    super.initState();
    _subscription = _stepsService.updates.listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _steps = snapshot.steps;
        _calories = snapshot.calories;
        _distanceKm = snapshot.distance / 1000;
      });
    });
    _load();
  }

  Future<void> _load() async {
    await _stepsService.startTracking();
    if (!mounted) return;
    setState(() => _steps = _stepsService.currentSteps);
    final rows = await HealthTrackingService.history('steps', days: 30);
    if (!mounted) return;
    setState(() {
      _history = rows
          .map((row) => (row['value'] as num?)?.toDouble() ?? 0)
          .where((value) => value > 0)
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_steps / 10000).clamp(0.0, 1.0).toDouble();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: const FuturisticAppBar(title: 'عداد الخطوات'),
      body: FuturisticBackground(
        glowColor: const Color(0xFF00E5A0),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              glowColor: const Color(0xFF00E5A0),
              child: Column(
                children: [
                  HolographicNumber(
                    value: _steps.toString(),
                    unit: 'خطوة اليوم',
                    color: const Color(0xFF00E5A0),
                    fontSize: 64,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress, minHeight: 8),
                  const SizedBox(height: 8),
                  Text(
                    (_steps / 10000 * 100).round().toString() + '% من هدف 10,000',
                    style: TextStyle(color: Colors.white.withOpacity(.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FuturisticStatCard(
                    icon: Icons.route,
                    label: 'المسافة',
                    value: _distanceKm.toStringAsFixed(2) + ' كم',
                    color: const Color(0xFF00E5A0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FuturisticStatCard(
                    icon: Icons.local_fire_department,
                    label: 'السعرات',
                    value: _calories.toString(),
                    color: const Color(0xFFFF9F43),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تاريخ الخطوات',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  _history.length > 1
                      ? FuturisticLineChart(
                          values: _history,
                          color: const Color(0xFF00E5A0),
                        )
                      : const SizedBox(
                          height: 130,
                          child: Center(
                            child: Text(
                              'ستظهر القراءات بعد التتبع',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FuturisticPeriodSelector(
              selected: 0,
              onChanged: (_) {},
              color: const Color(0xFF00E5A0),
            ),
          ],
        ),
      ),
    );
  }
}
