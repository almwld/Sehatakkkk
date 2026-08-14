import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/sleep/sleep_model.dart';
import 'package:sehatak/core/services/sleep/sleep_service.dart';
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
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
        // ✅ تغيير المرحلة كل 5 دقائق
        if (_elapsedSeconds % 300 == 0) {
          _currentPhase = _phases[(_elapsedSeconds ~/ 300) % _phases.length];
        }
      });
    });
  }

  Future<void> _stopTracking() async {
    _updateTimer?.cancel();
    final record = await _sleepService.stopSleepTracking();
    setState(() {
      _isTracking = false;
    });
    
    if (record != null) {
      setState(() {
        _todayRecord = record;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم حفظ سجل النوم بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: '😴 تتبع النوم',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ حالة التتبع
                  _buildTrackingStatus(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ إحصائيات سريعة
                  _buildQuickStats(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ رسم بياني للنوم
                  _buildSleepChart(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ تفاصيل النوم اليوم
                  if (_todayRecord != null) _buildTodayDetails(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ سجل النوم الأسبوعي
                  _buildWeeklyRecords(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildTrackingStatus(bool isDark) {
    if (_isTracking) {
      final hours = _elapsedSeconds ~/ 3600;
      final minutes = (_elapsedSeconds % 3600) ~/ 60;
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.indigo, Colors.purple],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.bedtime, color: Colors.white, size: 48),
            const SizedBox(height: 8),
            const Text(
              '⏳ جاري تتبع النوم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🔄 $_currentPhase',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _stopTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '⏹️ إيقاف التتبع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_todayRecord != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _todayRecord!.qualityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _todayRecord!.qualityIcon,
                color: _todayRecord!.qualityColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نوم ${_todayRecord!.qualityText}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'مدة النوم: ${_todayRecord!.durationFormatted}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _startTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('تتبع'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.indigo],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.bedtime, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          const Text(
            '😴 وقت النوم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'اضغط على "بدء التتبع" لتسجيل نومك',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startTracking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '▶️ بدء التتبع',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: [
        _buildStatItem(
          '⏱️ المتوسط',
          '${_stats['avgDuration'] ?? 0} د',
          isDark,
        ),
        _buildStatItem(
          '📊 الكفاءة',
          '${(_stats['avgEfficiency'] ?? 0).toStringAsFixed(0)}%',
          isDark,
        ),
        _buildStatItem(
          '🕐 الإجمالي',
          '${(_stats['totalHours'] ?? 0).toStringAsFixed(1)} س',
          isDark,
        ),
        _buildStatItem(
          '🏆 الأفضل',
          _stats['bestDay'] ?? '-',
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepChart(bool isDark) {
    if (_weeklyRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'لا توجد بيانات كافية',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 سجل النوم الأسبوعي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600,
                barGroups: _weeklyRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: record.durationMinutes.toDouble(),
                        color: record.qualityColor,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _weeklyRecords.length) return const SizedBox();
                        final record = _weeklyRecords[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${record.date.day}/${record.date.month}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value ~/ 60)}h',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 60,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayDetails(bool isDark) {
    final record = _todayRecord!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                '📋 تفاصيل النوم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  '😴 النوم العميق',
                  '${record.deepSleepMinutes} د',
                  Colors.indigo,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  '😌 النوم الخفيف',
                  '${record.lightSleepMinutes} د',
                  Colors.blue,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  '💭 نوم الريم',
                  '${record.remSleepMinutes} د',
                  Colors.purple,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  '👀 مستيقظ',
                  '${record.awakeMinutes} د',
                  Colors.orange,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (record.heartRate != null)
            _buildDetailItem(
              '❤️ معدل النبض',
              '${record.heartRate!.toStringAsFixed(0)} نبضة/دقيقة',
              Colors.red,
              isDark,
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: record.qualityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(record.qualityIcon, color: record.qualityColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.notes ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecords(bool isDark) {
    if (_weeklyRecords.isEmpty) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 سجل النوم',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 16),
          ..._weeklyRecords.take(5).map((record) {
            return ListTile(
              leading: Icon(
                record.qualityIcon,
                color: record.qualityColor,
              ),
              title: Text(
                '${record.date.day}/${record.date.month}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                '${record.durationFormatted} • ${record.qualityText}',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: record.qualityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${record.sleepEfficiency.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: record.qualityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
