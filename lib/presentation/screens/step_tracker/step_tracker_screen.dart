// ============================================================
// 📁 lib/presentation/screens/step_tracker/step_tracker_screen.dart
// 🚶 شاشة تتبع الخطوات والمشي
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:intl/intl.dart';
import '../../../services/step_tracker_service.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  final StepTrackerService _service = StepTrackerService();
  StreamSubscription<int>? _stepSubscription;
  Timer? _updateTimer;

  // ✅ بيانات الخطوات
  int _steps = 0;
  double _distance = 0.0;
  int _calories = 0;
  int _stepGoal = 10000;
  double _progress = 0.0;
  double _speed = 0.0;

  // ✅ إحصائيات
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _weeklyData = [];
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _initializeTracker();
  }

  Future<void> _initializeTracker() async {
    // ✅ بدء تتبع الخطوات
    await _service.startStepTracking();

    // ✅ الاستماع لتحديثات الخطوات
    _stepSubscription = _service.stepStream.listen((steps) {
      setState(() {
        _steps = steps;
        _updateProgress();
      });
    });

    // ✅ تحميل البيانات
    await _loadData();

    // ✅ بدء التحديث الدوري
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateData();
    });

    setState(() {
      _isTracking = true;
    });
  }

  Future<void> _loadData() async {
    final stats = await _service.getStatistics();
    final weekly = await _service.getWeeklySteps();

    setState(() {
      _stats = stats;
      _steps = stats['today_steps'] ?? 0;
      _distance = stats['today_distance'] ?? 0.0;
      _calories = stats['today_calories'] ?? 0;
      _stepGoal = stats['step_goal'] ?? 10000;
      _speed = _service.speed;
      _weeklyData = weekly;
      _updateProgress();
    });
  }

  void _updateData() {
    setState(() {
      _steps = _service.todaySteps;
      _distance = _service.distance;
      _calories = _service.calories;
      _speed = _service.speed;
      _updateProgress();
    });
  }

  void _updateProgress() {
    _progress = _stepGoal > 0 ? (_steps / _stepGoal).clamp(0.0, 1.0) : 0.0;
  }

  // ============================================================
  📊 الرسم البياني الأسبوعي
  // ============================================================

  Widget _buildWeeklyChart() {
    if (_weeklyData.isEmpty) {
      return const Center(child: Text('لا توجد بيانات كافية'));
    }

    List<String> days = ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    List<FlSpot> spots = [];

    for (int i = 0; i < _weeklyData.length && i < 7; i++) {
      var data = _weeklyData[i];
      int steps = data['steps'] as int;
      spots.add(FlSpot(i.toDouble(), steps.toDouble()));
    }

    double maxY = spots.isEmpty ? 1000 : spots.map((s) => s.y).reduce(max) * 1.2;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 9),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Text(days[index], style: const TextStyle(fontSize: 9));
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue.shade700,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: maxY,
        ),
      ),
    );
  }

  // ============================================================
  📊 بطاقة الإحصائيات
  // ============================================================

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  📈 مؤشر التقدم
  // ============================================================

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_steps خطوة',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'من $_stepGoal خطوة',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _progress >= 1.0 ? Colors.green.shade50 : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _progress >= 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StepProgressIndicator(
            totalSteps: _stepGoal,
            currentStep: _steps,
            size: 20,
            roundedEdges: const Radius.circular(10),
            selectedColor: _progress >= 1.0 ? Colors.green : Colors.blue,
            unselectedColor: Colors.grey.shade200,
            padding: 4,
          ),
          if (_progress >= 1.0)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '🎉 مبروك! لقد حققت هدفك اليومي!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  📱 بناء الواجهة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚶 تتبع الخطوات'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showStatsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // 📈 مؤشر التقدم
            // ============================================================
            _buildProgressIndicator(),

            const SizedBox(height: 16),

            // ============================================================
            // 📊 الإحصائيات السريعة
            // ============================================================
            Row(
              children: [
                _buildStatCard(
                  'المسافة',
                  '${_distance.toStringAsFixed(2)} كم',
                  Icons.straighten,
                  Colors.purple,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'السعرات',
                  '$_calories',
                  Icons.local_fire_department,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'السرعة',
                  '${_speed.toStringAsFixed(1)} كم/س',
                  Icons.speed,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ============================================================
            // 📊 الرسم البياني الأسبوعي
            // ============================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 تقدم الخطوات الأسبوعي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildWeeklyChart(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // 💡 نصائح
            // ============================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚶 نصائح للمشي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• استهدف 10000 خطوة يومياً', style: TextStyle(fontSize: 12)),
                  Text('• امشِ 30 دقيقة يومياً على الأقل', style: TextStyle(fontSize: 12)),
                  Text('• استخدم الدرج بدلاً من المصعد', style: TextStyle(fontSize: 12)),
                  Text('• امشِ أثناء التحدث في الهاتف', style: TextStyle(fontSize: 12)),
                  Text('• احمل هاتفك معك دوماً للتتبع', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  📊 عرض الإحصائيات
  // ============================================================

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 إحصائيات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('متوسط أسبوعي: ${(_stats['weekly_avg'] as double?)?.toStringAsFixed(0) ?? 0} خطوة'),
            Text('إجمالي الأسبوع: ${_stats['weekly_total'] ?? 0} خطوة'),
            Text('أفضل يوم: ${_stats['best_day_steps'] ?? 0} خطوة (${_stats['best_day'] ?? '--'})'),
            const Divider(),
            Text('اليوم: $_steps خطوة'),
            Text('المسافة: ${_distance.toStringAsFixed(2)} كم'),
            Text('السعرات: $_calories سعرة'),
            Text('الهدف: $_stepGoal خطوة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _updateTimer?.cancel();
    _service.stopTracking();
    super.dispose();
  }
}
