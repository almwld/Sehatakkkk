import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _steps = 0;
  bool _isCounting = false;

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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_walk,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '$_steps',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'خطوة',
              style: TextStyle(
                fontSize: 20,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isCounting = !_isCounting;
                  if (_isCounting) {
                    // محاكاة زيادة الخطوات
                    Future.doWhile(() async {
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!_isCounting) return false;
                      setState(() => _steps++);
                      return true;
                    });
                  }
                });
              },
              icon: Icon(_isCounting ? Icons.pause : Icons.play_arrow),
              label: Text(_isCounting ? 'إيقاف' : 'بدء العد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _steps = 0;
                  _isCounting = false;
                });
              },
              child: const Text('إعادة تعيين'),
            ),
          ],
        ),
      ),
    );
  }
}
