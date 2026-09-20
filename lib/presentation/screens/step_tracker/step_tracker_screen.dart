import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sehatak/core/services/steps/steps_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});
  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  final StepsService _service = StepsService.instance;
  StreamSubscription<StepsSnapshot>? _subscription;
  Timer? _refreshTimer;
  int _steps = 0, _calories = 0;
  double _distance = 0;
  bool _tracking = false, _loading = true;

  @override
  void initState() {
    super.initState();
    _subscription = _service.updates.listen((data) {
      if (!mounted) return;
      setState(() {
        _steps = data.steps;
        _calories = data.calories;
        _distance = data.distance / 1000;
        _tracking = _service.isTracking;
      });
    });
    _initialize();
  }

  Future<void> _initialize() async {
    final started = await _service.startTracking();
    if (!mounted) return;
    setState(() {
      _tracking = started || _service.isTracking;
      _steps = _service.currentSteps;
      _loading = false;
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _tracking = _service.isTracking);
    });
  }

  Future<void> _toggle() async {
    if (_service.isTracking) {
      await _service.stopTracking();
    } else {
      final ok = await _service.startTracking();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى السماح بإذن النشاط والحركة لتتبع الخطوات')),
        );
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final progress = (_steps / 10000).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع الخطوات')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (mounted) setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text(_steps.toString(), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
                  const Text('خطوة اليوم'),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(value: progress, minHeight: 10),
                  const SizedBox(height: 8),
                  Text((_steps / 10000 * 100).round().toString() + '% من هدف 10,000'),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: _toggle,
                    icon: Icon(_tracking ? Icons.stop : Icons.play_arrow),
                    label: Text(_tracking ? 'إيقاف التتبع' : 'بدء التتبع'),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _stat('المسافة', _distance.toStringAsFixed(2) + ' كم')),
              Expanded(child: _stat('السعرات', _calories.toString())),
            ]),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_tracking
                    ? 'التتبع يعمل من خدمة واحدة مشتركة. يمكنك مغادرة هذه الشاشة والعودة إليها دون فقدان الجلسة.'
                    : 'التتبع متوقف. يمكنك تشغيله بعد منح إذن النشاط والحركة.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String value) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(title),
      ]),
    ),
  );
}
