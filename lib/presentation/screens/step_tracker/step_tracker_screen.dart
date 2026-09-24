import 'dart:async';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:sehatak/core/constants/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_steps / 10000).clamp(0.0, 1.0);
    final goalRemaining = math.max(0, 10000 - _steps);
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الخطوات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async { if (mounted) setState(() {}); },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _buildHero(isDark, progress),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _metricCard('المسافة', _distance.toStringAsFixed(2) + ' كم', Icons.route_outlined, isDark)),
              const SizedBox(width: 10),
              Expanded(child: _metricCard('السعرات', _calories.toString() + ' kcal', Icons.local_fire_department_outlined, isDark)),
            ]),
            const SizedBox(height: 16),
            _buildWeeklyChart(isDark),
            const SizedBox(height: 16),
            _buildActivityRing(isDark, progress, goalRemaining),
            const SizedBox(height: 16),
            _buildAnalysis(isDark, progress),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool isDark, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF172033) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(.12)),
      ),
      child: Column(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => SizedBox(
            width: 190, height: 190,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 170, height: 170,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 13,
                  backgroundColor: AppColors.primary.withOpacity(.10),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.directions_walk_rounded, size: 30, color: AppColors.primary),
                const SizedBox(height: 4),
                Text(_steps.toString(), style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
                Text('خطوة اليوم', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Text((progress * 100).round().toString() + '% من هدف 10,000 خطوة', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _toggle,
          icon: Icon(_tracking ? Icons.stop : Icons.play_arrow),
          label: Text(_tracking ? 'إيقاف التتبع' : 'بدء التتبع'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _tracking ? Colors.redAccent : AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        )),
      ]),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, bool isDark) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      Icon(icon, color: AppColors.primary),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 3),
      Text(title, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black45)),
    ]),
  );

  Widget _buildWeeklyChart(bool isDark) {
    final values = [0.46, 0.63, 0.71, 0.58, 0.82, 0.68, (_steps / 10000).clamp(0.0, 1.0)];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 17, 14, 18),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.show_chart_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('نشاط الخطوات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        ]),
        const SizedBox(height: 4),
        Text('مستوى النشاط اليومي بالنسبة لهدفك', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: BarChart(BarChartData(
            minY: 0, maxY: 1,
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: .25),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34, interval: .25, getTitlesWidget: (v, m) => Text((v * 100).round().toString() + '%', style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : Colors.black45)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 25, getTitlesWidget: (v, m) {
                const labels = ['أح','إث','ث','أر','خ','ج','س'];
                final i=v.toInt(); if(i<0||i>6) return const SizedBox.shrink();
                return Text(labels[i], style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54));
              })),
            ),
            barGroups: values.asMap().entries.map((e) => BarChartGroupData(x:e.key, barRods:[BarChartRodData(toY:e.value, width:20, borderRadius:const BorderRadius.vertical(top:Radius.circular(7)), color:e.key==6?AppColors.primary:AppColors.primary.withOpacity(.42))])).toList(),
          )),
        ),
      ]),
    );
  }

  Widget _buildActivityRing(bool isDark, double progress, int remaining) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('مؤشرات النشاط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _miniMetric('الهدف', '10,000', Icons.flag_outlined, isDark)),
        Expanded(child: _miniMetric('المتبقي', remaining.toString(), Icons.directions_walk, isDark)),
        Expanded(child: _miniMetric('الإنجاز', (progress*100).round().toString()+'%', Icons.insights_outlined, isDark)),
      ]),
    ]),
  );

  Widget _miniMetric(String title, String value, IconData icon, bool isDark) => Column(children: [
    Icon(icon, size: 20, color: AppColors.primary),
    const SizedBox(height: 6),
    Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
    const SizedBox(height: 3),
    Text(title, style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black45)),
  ]);

  Widget _buildAnalysis(bool isDark, double progress) {
    final text = _steps == 0
        ? 'ابدأ التتبع لعرض تحليل نشاطك اليومي.'
        : progress >= 1
            ? 'حققت هدف 10,000 خطوة اليوم. حافظ على الحركة المنتظمة خلال اليوم.'
            : _steps >= 7500
                ? 'نشاطك اليومي قريب من الهدف. تبقى ' + (10000 - _steps).toString() + ' خطوة تقريباً.'
                : 'النشاط المسجل ما زال دون الهدف اليومي. يمكنك زيادة الحركة تدريجياً خلال اليوم.';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary.withOpacity(.12) : AppColors.primary.withOpacity(.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(.15)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.auto_awesome, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('تحليل النشاط', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(height: 1.55, color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 8),
          Text('التتبع ' + (_tracking ? 'نشط الآن' : 'متوقف'), style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ])),
      ]),
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
