import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _steps = 0;
  int _todaySteps = 0;
  double _calories = 0;
  double _distance = 0;
  bool _isCounting = false;
  double _lastAcceleration = 0;
  double _threshold = 12.0;
  int _stepCount = 0;
  List<int> _stepHistory = [];
  String _currentDate = '';
  DateTime _startTime = DateTime.now();
  int _elapsedSeconds = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now().toString().split(' ')[0];
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('step_date') ?? '';
    final savedSteps = prefs.getInt('step_count') ?? 0;

    if (savedDate == _currentDate) {
      _todaySteps = savedSteps;
      _steps = savedSteps;
    } else {
      _todaySteps = 0;
      _steps = 0;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('step_date', _currentDate);
    await prefs.setInt('step_count', _todaySteps);
  }

  void _startCounting() {
    setState(() {
      _isCounting = true;
      _startTime = DateTime.now();
      _stepCount = 0;
      _calories = 0;
      _distance = 0;
      _stepHistory.clear();
    });

    // ✅ استخدام مستشعر التسارع لحساب الخطوات
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_isCounting) return;

      final acceleration = event.x.abs() + event.y.abs() + event.z.abs();
      final currentAcceleration = acceleration / 9.81;

      if (currentAcceleration > _threshold && _lastAcceleration <= _threshold) {
        setState(() {
          _stepCount++;
          _todaySteps++;
          _steps++;
          _calories = (_steps * 0.04).toDouble();
          _distance = (_steps * 0.0008).toDouble();
          _stepHistory.add(_steps);
          if (_stepHistory.length > 60) _stepHistory.removeAt(0);
        });
        _saveSteps();
      }
      _lastAcceleration = currentAcceleration;
    });

    // ✅ تحديث الوقت المنقضي
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isCounting) return false;
      setState(() {
        _elapsedSeconds++;
      });
      return true;
    });
  }

  void _stopCounting() {
    setState(() => _isCounting = false);
    _saveSteps();
  }

  void _resetSteps() {
    setState(() {
      _todaySteps = 0;
      _steps = 0;
      _calories = 0;
      _distance = 0;
      _stepHistory.clear();
      _elapsedSeconds = 0;
    });
    _saveSteps();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('عداد الخطوات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('سجل اليوم: $_todaySteps خطوة'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ عداد الخطوات
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ الرقم الكبير
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF1A2540) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_steps.toString()}',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'خطوة',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isCounting ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCounting ? Icons.circle : Icons.stop_circle,
                                    color: _isCounting ? Colors.green : Colors.grey,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isCounting ? 'جارٍ العد...' : 'متوقف',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isCounting ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ✅ الإحصائيات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('السعرات', _calories.toStringAsFixed(0), 'ك.كالوري', isDark),
                      _buildStatItem('المسافة', _distance.toStringAsFixed(2), 'كم', isDark),
                      _buildStatItem('الوقت', _formatTime(_elapsedSeconds), '', isDark),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // ✅ الأزرار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isCounting ? _stopCounting : _startCounting,
                        icon: Icon(_isCounting ? Icons.pause : Icons.play_arrow),
                        label: Text(_isCounting ? 'إيقاف' : 'بدء العد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCounting ? Colors.red : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _resetSteps,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة تعيين'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ✅ شريط التقدم
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: (_todaySteps / 10000).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$_todaySteps / 10,000 خطوة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '10,000',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
      ],
    );
  }
}
