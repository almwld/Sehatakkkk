import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/step_tracker_service.dart';
import '../../../services/background_service.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  final StepTrackerService _service = StepTrackerService();
  StreamSubscription<int>? _stepsSubscription;
  Timer? _pollTimer;

  int _steps = 0;
  double _distance = 0;
  double _calories = 0;
  double _speed = 0;
  int _stepGoal = 10000;
  bool _isTracking = false;
  bool _loading = true;
  List<Map<String, dynamic>> _weeklyData = const [];

  @override
  void initState() {
    super.initState();
    _stepsSubscription = _service.stepStream.listen((steps) {
      if (!mounted) return;
      setState(() {
        _steps = steps;
        _distance = _service.distance;
        _calories = _service.calories;
        _speed = _service.speed;
      });
    });
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final permissionGranted = await _service.requestPermissions();
      if (!permissionGranted) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      await _service.loadToday();
      await BackgroundService.initialize();
      final started = await BackgroundService.startStepTracking();
      await _reload();
      _startPolling();
      if (!mounted) return;
      setState(() {
        _isTracking = started;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Step tracking initialization error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _service.loadToday();
      await _reload();
    });
  }

  Future<void> _reload() async {
    final stats = await _service.getStatistics();
    final weekly = await _service.getWeeklySteps();
    if (!mounted) return;
    setState(() {
      _steps = (stats['today_steps'] as num?)?.toInt() ?? 0;
      _distance = (stats['today_distance'] as num?)?.toDouble() ?? 0;
      _calories = (stats['today_calories'] as num?)?.toDouble() ?? 0;
      _stepGoal = (stats['step_goal'] as num?)?.toInt() ?? 10000;
      _speed = _service.speed;
      _weeklyData = weekly;
    });
  }

  double get _progress => _stepGoal > 0 ? (_steps / _stepGoal).clamp(0.0, 1.0) : 0;

  Widget _progressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$_steps خطوة', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Text('من $_stepGoal خطوة', style: TextStyle(color: Colors.grey.shade600)),
            ]),
            SizedBox(width: 72, height: 72, child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(value: _progress, strokeWidth: 8),
              Center(child: Text('${(_progress * 100).round()}%')),
            ])),
          ]),
          const SizedBox(height: 18),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _progress, minHeight: 12)),
          if (_progress >= 1)
            const Padding(padding: EdgeInsets.only(top: 10), child: Text('تم تحقيق الهدف اليومي', style: TextStyle(fontWeight: FontWeight.bold))),
        ]),
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon) {
    return Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Icon(icon, size: 24),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ]))));
  }

  Widget _weeklyChart() {
    if (_weeklyData.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('لا توجد بيانات محفوظة بعد')));
    final spots = <FlSpot>[];
    for (var i = 0; i < _weeklyData.length && i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), (_weeklyData[i]['steps'] as num?)?.toDouble() ?? 0));
    }
    final maxValue = spots.map((e) => e.y).fold<double>(1000, (a, b) => a > b ? a : b);
    final maxY = maxValue <= 0 ? 1000 : maxValue * 1.2;
    return SizedBox(height: 210, child: LineChart(LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: const FlGridData(show: true),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (value, meta) {
          final index = value.round();
          if (index < 0 || index >= _weeklyData.length || index >= 7) return const SizedBox.shrink();
          final parsed = DateTime.tryParse(_weeklyData[index]['date']?.toString() ?? '');
          return Padding(padding: const EdgeInsets.only(top: 6), child: Text(parsed == null ? '' : DateFormat('E', 'ar').format(parsed), style: const TextStyle(fontSize: 10)));
        })),
      ),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true))],
    )));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('تتبع الخطوات'), actions: [IconButton(onPressed: _reload, icon: const Icon(Icons.refresh))]),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _progressCard(),
          const SizedBox(height: 10),
          Row(children: [
            _stat('المسافة', '${_distance.toStringAsFixed(2)} كم', Icons.straighten),
            _stat('السعرات*', '${_calories.round()}', Icons.local_fire_department),
            _stat('السرعة', '${_speed.toStringAsFixed(1)} كم/س', Icons.speed),
          ]),
          const SizedBox(height: 10),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('النشاط خلال آخر 7 أيام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _weeklyChart(),
          ]))),
          const SizedBox(height: 10),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_isTracking
              ? 'التتبع يعمل في الخلفية عبر خدمة Android. يمكنك إغلاق الشاشة وسيستمر حفظ الخطوات.'
              : 'تعذر تشغيل خدمة التتبع في الخلفية. تحقق من أذونات النشاط ثم أعد المحاولة.'))),
          const SizedBox(height: 8),
          const Text('* المسافة والسعرات تقديريتان وتعتمدان على متوسط طول الخطوة ومعامل طاقة ثابت.', style: TextStyle(fontSize: 11)),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _stepsSubscription?.cancel();
    super.dispose();
  }
}
