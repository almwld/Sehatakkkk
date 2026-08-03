import 'package:flutter/material.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _steps = 0;
  final int _targetSteps = 10000;
  bool _isCounting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد الخطوات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة المشي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isCounting ? Icons.directions_walk : Icons.directions_walk_outlined,
                size: 80,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 30),
            
            // عدد الخطوات
            Text(
              '$_steps',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'من $_targetSteps خطوة',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            // شريط التقدم
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _steps / _targetSteps,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${((_steps / _targetSteps) * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            
            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_steps > 0) _steps--;
                    });
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('ناقص'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _steps++;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('زائد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // زر إعادة تعيين
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _steps = 0;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('إعادة تعيين'),
            ),
          ],
        ),
      ),
    );
  }
}
