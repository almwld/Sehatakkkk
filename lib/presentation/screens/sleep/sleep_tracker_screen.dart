import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/sleep/sleep_model.dart';
import 'package:sehatak/core/services/sleep/sleep_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});
  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> with SingleTickerProviderStateMixin {
  final SleepService _sleepService = SleepService.instance;
  bool _isTracking = false, _isLoading = true;
  SleepRecord? _todayRecord;
  List<SleepRecord> _weeklyRecords = [];
  Map<String, dynamic> _stats = {};
  late AnimationController _animationController;
  late Animation<double> _animation;
  StreamSubscription<SleepSnapshot>? _subscription;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _subscription = _sleepService.updates.listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _isTracking = snapshot.isTracking;
        _elapsedSeconds = snapshot.elapsedSeconds;
      });
    });
    _initialize();
  }

  Future<void> _initialize() async {
    await _sleepService.restoreTracking();
    await _loadData();
    if (!mounted) return;
    setState(() {
      _isTracking = _sleepService.isTracking;
      final start = _sleepService.sleepStartTime;
      _elapsedSeconds = start == null ? 0 : DateTime.now().difference(start).inSeconds;
    });
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    final today = await _sleepService.getTodaySleepRecord();
    final weekly = await _sleepService.getWeeklySleepRecords();
    final stats = await _sleepService.getSleepStats();
    if (!mounted) return;
    setState(() {
      _todayRecord = today;
      _weeklyRecords = weekly;
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _startTracking() async {
    await _sleepService.startSleepTracking();
    if (!mounted) return;
    ToastService.showSuccess(context, 'بدأ تتبع النوم وسيستمر حتى مغادرة هذه الشاشة');
  }

  Future<void> _stopTracking() async {
    final record = await _sleepService.stopSleepTracking();
    if (!mounted) return;
    if (record != null) {
      ToastService.showSuccess(context, 'تم حفظ سجل النوم بنجاح');
      await _loadData();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'تتبع النوم', backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildTrackingCard(isDark),
          const SizedBox(height: 20),
          _buildTodayCard(isDark),
          const SizedBox(height: 20),
          _buildWeeklyStats(isDark),
          const SizedBox(height: 20),
          _buildSleepChart(isDark),
        ]),
      ),
    );
  }

  Widget _buildTrackingCard(bool isDark) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: .95 + (_animation.value * .05),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Text('وقت النوم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 16),
            Text(_formatDuration(_elapsedSeconds), style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _isTracking ? _stopTracking : _startTracking,
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
              label: Text(_isTracking ? 'إيقاف التتبع' : 'بدء التتبع'),
              style: ElevatedButton.styleFrom(backgroundColor: _isTracking ? Colors.redAccent : AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _buildTodayCard(bool isDark) {
    final record = _todayRecord;
    return _buildCard(isDark, 'سجل اليوم', record == null
        ? 'لا يوجد سجل نوم اليوم'
        : 'مدة النوم: ' + (record.durationMinutes ~/ 60).toString() + ' ساعة و' + record.durationMinutes.remainder(60).toString() + ' دقيقة');
  }

  Widget _buildWeeklyStats(bool isDark) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('إحصائيات الأسبوع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildStatItem('المتوسط', _formatStat(_stats['avgDuration']), isDark)),
          Expanded(child: _buildStatItem('الكفاءة', (_stats['avgEfficiency'] ?? 0).toStringAsFixed(0) + '%', isDark)),
          Expanded(child: _buildStatItem('الإجمالي', _formatStat(_stats['totalHours']), isDark)),
          Expanded(child: _buildStatItem('الأفضل', _formatStat(_stats['bestDay']), isDark)),
        ]),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) => Column(children: [
    Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
    const SizedBox(height: 4),
    Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
  ]);

  Widget _buildSleepChart(bool isDark) => Container(
    width: double.infinity, height: 260, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('النوم خلال الأسبوع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 12),
      Expanded(child: _weeklyRecords.isEmpty ? const Center(child: Text('لا توجد بيانات كافية')) : BarChart(BarChartData(
        barGroups: _weeklyRecords.asMap().entries.map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [BarChartRodData(toY: entry.value.durationMinutes.toDouble(), width: 14, color: AppColors.primary)],
        )).toList(),
      ))),
    ]),
  );

  Widget _buildCard(bool isDark, String title, String content) => Container(
    width: double.infinity, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 10),
      Text(content, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
    ]),
  );

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600, m = (seconds % 3600) ~/ 60, s = seconds % 60;
    return h.toString().padLeft(2, '0') + ':' + m.toString().padLeft(2, '0') + ':' + s.toString().padLeft(2, '0');
  }

  String _formatStat(dynamic value) {
    if (value == null) return '0';
    if (value is num) return value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
    return value.toString();
  }
}
