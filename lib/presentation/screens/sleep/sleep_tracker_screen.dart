import 'dart:async';
import 'dart:math' as math;
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
          const SizedBox(height: 18),
          _buildSleepAnalytics(isDark),
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

  Widget _buildSleepAnalytics(bool isDark) {
    final record = _todayRecord;
    final avg = (_stats['avgDuration'] as num?)?.toDouble() ?? 0;
    final efficiency = (_stats['avgEfficiency'] as num?)?.toDouble() ?? 0;
    return Column(children: [
      _chartCard(isDark, 'مدة النوم خلال الأسبوع', 'مقارنة مدة النوم ليلةً بعد ليلة', _buildDurationChart(isDark)),
      const SizedBox(height: 16),
      _chartCard(isDark, 'مراحل النوم', 'توزيع النوم العميق والخفيف وREM واليقظة', record == null ? _emptyChart() : _buildStagesChart(record, isDark)),
      const SizedBox(height: 16),
      _chartCard(isDark, 'الخريطة الحركية للنوم', 'تسلسل مراحل النوم من وقت النوم حتى الاستيقاظ', record == null ? _emptyChart() : _buildSleepTimeline(record, isDark)),
      const SizedBox(height: 16),
      _buildSleepAnalysisCard(record, avg, efficiency, isDark),
    ]);
  }

  Widget _chartCard(bool isDark, String title, String subtitle, Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(Icons.analytics_outlined, size: 20, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)))]),
      const SizedBox(height: 4),
      Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
      const SizedBox(height: 12), child,
    ]),
  );

  Widget _emptyChart() => const SizedBox(height: 150, child: Center(child: Text('لا توجد بيانات كافية بعد')));

  Widget _buildDurationChart(bool isDark) {
    if (_weeklyRecords.isEmpty) return _emptyChart();
    final maxMinutes = math.max(540, _weeklyRecords.map((r) => r.durationMinutes).fold<int>(0, math.max) + 60).toDouble();
    return SizedBox(height: 230, child: BarChart(BarChartData(
      minY: 0, maxY: maxMinutes,
      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 120),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 120, getTitlesWidget: (v, m) => Text((v / 60).round().toString() + 'س', style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black45)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 25, getTitlesWidget: (v, m) { final i = v.toInt(); if (i < 0 || i >= _weeklyRecords.length) return const SizedBox.shrink(); return Text(_dayLabel(_weeklyRecords[i].date), style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54)); })),
      ),
      barGroups: _weeklyRecords.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.durationMinutes.toDouble(), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(7)), color: AppColors.primary.withOpacity(.72))])).toList(),
    )));
  }

  Widget _buildStagesChart(SleepRecord r, bool isDark) {
    final data = [['عميق', r.deepSleepMinutes, const Color(0xFF4C5FD5)], ['خفيف', r.lightSleepMinutes, const Color(0xFF55A7D9)], ['REM', r.remSleepMinutes, const Color(0xFF8A63D2)], ['يقظة', r.awakeMinutes, const Color(0xFFF0A45D)]];
    final total = math.max(1, data.fold<int>(0, (s, x) => s + (x[1] as int)));
    return Column(children: [
      SizedBox(height: 200, child: PieChart(PieChartData(centerSpaceRadius: 50, sectionsSpace: 3, sections: data.map((x) { final minutes = x[1] as int; final pct = minutes / total * 100; return PieChartSectionData(value: minutes.toDouble(), title: pct < 8 ? '' : pct.toStringAsFixed(0) + '%', color: x[2] as Color, radius: 66, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)); }).toList()))),
      Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 8, children: data.map((x) { final minutes = x[1] as int; final pct = minutes / total * 100; return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: x[2] as Color, shape: BoxShape.circle)), const SizedBox(width: 5), Text(x[0].toString() + ': ' + minutes.toString() + ' د • ' + pct.toStringAsFixed(0) + '%', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54))]); }).toList()),
    ]);
  }

  Widget _buildSleepTimeline(SleepRecord r, bool isDark) {
    final data = [['عميق', r.deepSleepMinutes, const Color(0xFF4C5FD5)], ['خفيف', r.lightSleepMinutes, const Color(0xFF55A7D9)], ['REM', r.remSleepMinutes, const Color(0xFF8A63D2)], ['يقظة', r.awakeMinutes, const Color(0xFFF0A45D)]].where((x) => (x[1] as int) > 0).toList();
    final total = math.max(1, data.fold<int>(0, (s, x) => s + (x[1] as int)));
    return AnimatedBuilder(animation: _animationController, builder: (context, _) => Column(children: [
      Row(children: [Text(_formatTime(r.bedtime), style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text(_formatTime(r.wakeTime), style: const TextStyle(fontWeight: FontWeight.bold))]),
      const SizedBox(height: 10),
      ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(height: 48, child: Row(children: data.map((x) { final minutes = x[1] as int; final flex = math.max(1, (minutes / total * 1000 * _animation.value).round()); return Expanded(flex: flex, child: Container(color: x[2] as Color, alignment: Alignment.center, child: minutes >= 30 ? Text(x[0].toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)) : null)); }).toList()))),
      const SizedBox(height: 10),
      Align(alignment: AlignmentDirectional.centerStart, child: Text('المدة: ' + r.durationFormatted + ' • الكفاءة: ' + r.sleepEfficiency.toStringAsFixed(0) + '%', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54))),
    ]));
  }

  Widget _buildSleepAnalysisCard(SleepRecord? r, double avg, double efficiency, bool isDark) {
    final message = r == null ? 'سجّل ليلة كاملة أولاً للحصول على تحليل مبني على بيانات نومك.' : r.durationMinutes < 420 ? 'مدة النوم المسجلة أقل من 7 ساعات. راقب هذا الاتجاه عبر عدة ليالٍ وحافظ على روتين نوم منتظم.' : r.sleepEfficiency >= 85 ? 'الكفاءة المسجلة جيدة. استمر على روتين ثابت وراقب توزيع المراحل مع مرور الأيام.' : 'هناك مساحة لتحسين انتظام النوم. راقب وقت الاستغراق والاستيقاظ وتكرار فترات اليقظة.';
    return Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: isDark ? AppColors.primary.withOpacity(.12) : AppColors.primary.withOpacity(.07), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.primary.withOpacity(.15))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.auto_awesome, color: AppColors.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('تحليل النوم', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 6), Text(message, style: TextStyle(height: 1.55, color: isDark ? Colors.white70 : Colors.black54)), if (avg > 0 || efficiency > 0) ...[const SizedBox(height: 8), Text('المتوسط الأسبوعي: ' + _formatStat(avg) + ' • الكفاءة: ' + efficiency.toStringAsFixed(0) + '%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))]]))]));
  }

  String _dayLabel(DateTime date) {
    const days = ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س'];
    return days[date.weekday % 7];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return hour.toString() + ':' + minute + ' ' + (date.hour >= 12 ? 'م' : 'ص');
  }

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
