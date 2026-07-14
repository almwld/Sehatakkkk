import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _steps = 0;
  bool _isCounting = false;
  double _lastAcceleration = 0;
  double _threshold = 12.0;
  List<double> _stepHistory = [];
  double _calories = 0;
  double _distance = 0;

  @override
  void initState() {
    super.initState();
    _loadStepData();
  }

  void _loadStepData() async {
    // تحميل البيانات المحفوظة
  }

  void _startCounting() {
    setState(() {
      _isCounting = true;
      _steps = 0;
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
          _steps++;
          _calories = _steps * 0.04;
          _distance = _steps * 0.0008;
          _stepHistory.add(_steps.toDouble());
          if (_stepHistory.length > 60) _stepHistory.removeAt(0);
        });
      }
      _lastAcceleration = currentAcceleration;
    });
  }

  void _stopCounting() {
    setState(() => _isCounting = false);
  }

  void _resetSteps() {
    setState(() {
      _steps = 0;
      _calories = 0;
      _distance = 0;
      _stepHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                const SnackBar(
                  content: Text('عرض سجل الخطوات'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ عداد الخطوات
            Container(
              width: 200,
              height: 200,
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
                  Icon(
                    Icons.directions_walk,
                    size: 40,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_steps',
                    style: TextStyle(
                      fontSize: 48,
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
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ✅ الإحصائيات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('السعرات', '${_calories.toStringAsFixed(0)}', 'كيلو كالوري', isDark),
                _buildStatItem('المسافة', '${_distance.toStringAsFixed(2)}', 'كم', isDark),
                _buildStatItem('الوقت', '00:00', 'دقيقة', isDark),
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

            // ✅ تقدم الخطوات
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                widthFactor: (_steps / 10000).clamp(0.0, 1.0),
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
                  '10,000 خطوة',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
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
