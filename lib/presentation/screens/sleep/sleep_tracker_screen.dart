import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/sleep/sleep_model.dart';
import 'package:sehatak/core/services/sleep/sleep_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> with SingleTickerProviderStateMixin {
  final SleepService _sleepService = SleepService();
  bool _isTracking = false;
  bool _isLoading = true;
  SleepRecord? _todayRecord;
  List<SleepRecord> _weeklyRecords = [];
  Map<String, dynamic> _stats = {};
  late AnimationController _animationController;
  late Animation<double> _animation;
  Timer? _updateTimer;
  int _elapsedSeconds = 0;
  String _currentPhase = 'نوم عميق';
  final List<String> _phases = ['نوم عميق', 'نوم خفيف', 'نوم ريم', 'مستيقظ'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _todayRecord = await _sleepService.getTodaySleepRecord();
    _weeklyRecords = await _sleepService.getWeeklySleepRecords();
    _stats = await _sleepService.getSleepStats();
    setState(() => _isLoading = false);
  }

  Future<void> _startTracking() async {
    await _sleepService.startSleepTracking();
    setState(() {
      _isTracking = true;
      _elapsedSeconds = 0;
    });
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds % 300 == 0) {
          _currentPhase = _phases[(_elapsedSeconds ~/ 300) % _phases.length];
        }
      });
    });
  }

  Future<void> _stopTracking() async {
    _updateTimer?.cancel();
    final record = await _sleepService.stopSleepTracking();
    setState(() => _isTracking = false);
    if (record != null) {
      setState(() => _todayRecord = record);
      ToastService.showSuccess(context, 'تم حفظ سجل النوم بنجاح');
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'تتبع النوم',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTrackingCard(isDark),
                  const SizedBox(height: 20),
                  _buildTodayCard(isDark),
                  const SizedBox(height: 20),
                  _buildWeeklyStats(isDark),
                  const SizedBox(height: 20),
                  _buildSleepChart(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildTrackingCard(bool isDark) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: 0.95 + (_animation.value * 0.05),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF172033) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Text('وقت النوم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 16),
              Text(_formatDuration(_elapsedSeconds), style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8),
              if (_isTracking) Text(_currentPhase, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTracking ? _stopTracking : _startTracking,
                  icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(_isTracking ? 'إيقاف التتبع' : 'بدء التتبع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.redAccent : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard(bool isDark) {
    final record = _todayRecord;
    return _buildCard(isDark, 'سجل اليوم', record == null ? 'لا يوجد سجل نوم اليوم' : 'مدة النوم: ${record.duration.inHours} ساعة و${record.duration.inMinutes.remainder(60)} دقيقة');
  }

  Widget _buildWeeklyStats(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إحصائيات الأسبوع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildStatItem('المتوسط', _formatStat(_stats['averageDuration']), isDark)),
            Expanded(child: _buildStatItem('الكفاءة', '${_stats['averageEfficiency'] ?? 0}%', isDark)),
            Expanded(child: _buildStatItem('الإجمالي', _formatStat(_stats['totalSleep']), isDark)),
            Expanded(child: _buildStatItem('الأفضل', _formatStat(_stats['bestDuration']), isDark)),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(children: [
      Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
    ]);
  }

  Widget _buildSleepChart(bool isDark) {
    return Container(
      width: double.infinity,
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('النوم خلال الأسبوع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 12),
        Expanded(child: _weeklyRecords.isEmpty ? const Center(child: Text('لا توجد بيانات كافية')) : BarChart(BarChartData(barGroups: _weeklyRecords.asMap().entries.map((entry) => BarChartGroupData(x: entry.key, barRods: [BarChartRodData(toY: entry.value.duration.inMinutes.toDouble(), width: 14, color: AppColors.primary)])).toList()))),
      ]),
    );
  }

  Widget _buildCard(bool isDark, String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF172033) : Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 10),
        Text(content, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
      ]),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatStat(dynamic value) {
    if (value == null) return '0';
    if (value is Duration) return '${value.inHours}س';
    return value.toString();
  }
}
