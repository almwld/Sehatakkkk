import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/steps/steps_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sehatak/core/models/steps/steps_model.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> with SingleTickerProviderStateMixin {
  final StepsService _stepsService = StepsService();
  
  bool _isTracking = false;
  bool _isLoading = true;
  int _currentSteps = 0;
  int _todaySteps = 0;
  int _calories = 0;
  double _distance = 0;
  int _activeMinutes = 0;
  List<StepRecord> _weeklyRecords = [];
  Map<String, dynamic> _stats = {};
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _todaySteps = await _stepsService.getTodaySteps();
    _weeklyRecords = await _stepsService.getWeeklySteps();
    _stats = await _stepsService.getStepsStats();
    
    setState(() => _isLoading = false);
  }

  Future<void> _startTracking() async {
    try {
      await _stepsService.startTracking();
      setState(() {
        _isTracking = true;
        _todaySteps = 0;
        _currentSteps = 0;
        _calories = 0;
        _distance = 0;
        _activeMinutes = 0;
      });
      
      // ✅ تحديث كل ثانية
      Future.doWhile(() async {
        if (!_isTracking) return false;
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            // ✅ سيتم تحديث البيانات من المستشعرات
          });
        }
        return true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopTracking() async {
    await _stepsService.stopTracking();
    setState(() {
      _isTracking = false;
    });
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم حفظ البيانات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: '🚶 عداد الخطوات',
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
                  // ✅ عداد الخطوات الرئيسي
                  _buildStepCounter(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ إحصائيات سريعة
                  _buildQuickStats(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ رسم بياني للخطوات
                  _buildStepsChart(isDark),
                  const SizedBox(height: 16),
                  
                  // ✅ سجل الخطوات الأسبوعي
                  _buildWeeklyRecords(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildStepCounter(bool isDark) {
    final progress = _todaySteps > 0 ? (_todaySteps / 10000).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2A9D8F)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🚶 الخطوات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isTracking)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '⏳ تتبع',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final displaySteps = (_todaySteps * _animation.value).toInt();
              return Text(
                displaySteps.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'الهدف: 10,000 خطوة',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          // ✅ أزرار التحكم
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isTracking ? null : _startTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.grey : Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isTracking ? 'جاري التتبع...' : '▶️ بدء التتبع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isTracking ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isTracking ? _stopTracking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.red : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '⏹️ إيقاف',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
      childAspectRatio: 1.2,
      children: [
        _buildStatItem(
          '🔥 السعرات',
          '${_stats['totalCalories'] ?? 0}',
          Colors.orange,
          isDark,
        ),
        _buildStatItem(
          '📏 المسافة',
          '${(_stats['totalDistance'] ?? 0).toStringAsFixed(1)} كم',
          Colors.blue,
          isDark,
        ),
        _buildStatItem(
          '📊 المتوسط',
          '${_stats['avgSteps'] ?? 0}',
          Colors.green,
          isDark,
        ),
        _buildStatItem(
          '🏆 الأفضل',
          _stats['bestDay'] ?? '-',
          Colors.amber,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
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

  Widget _buildStepsChart(bool isDark) {
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
            '📊 سجل الخطوات الأسبوعي',
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
                maxY: 12000,
                barGroups: _weeklyRecords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  final color = record.steps >= 10000 ? Colors.green : Colors.blue;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: record.steps.toDouble(),
                        color: color,
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
                          '${(value ~/ 1000)}K',
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
                  horizontalInterval: 2000,
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              const Text('تحقيق الهدف', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              const Text('دون الهدف', style: TextStyle(fontSize: 11)),
            ],
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
            '📋 سجل الخطوات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 16),
          ..._weeklyRecords.take(5).map((record) {
            final isGoal = record.steps >= 10000;
            return ListTile(
              leading: Icon(
                isGoal ? Icons.emoji_events : Icons.directions_walk,
                color: isGoal ? Colors.amber : AppColors.primary,
              ),
              title: Text(
                '${record.date.day}/${record.date.month}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                '${record.steps} خطوة • ${record.distanceKm.toStringAsFixed(1)} كم',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isGoal ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${record.calories} سعر',
                  style: TextStyle(
                    color: isGoal ? Colors.green : Colors.grey,
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
