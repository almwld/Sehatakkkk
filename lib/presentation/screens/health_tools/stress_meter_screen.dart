import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class StressMeterScreen extends StatefulWidget {
  const StressMeterScreen({super.key});

  @override
  State<StressMeterScreen> createState() => _StressMeterScreenState();
}

class _StressMeterScreenState extends State<StressMeterScreen> {
  double _stressLevel = 0;
  String _getStressText() {
    if (_stressLevel <= 2) return 'منخفض 😊';
    if (_stressLevel <= 4) return 'متوسط 😐';
    if (_stressLevel <= 6) return 'مرتفع 😰';
    return 'شديد جداً 😱';
  }

  Color _getStressColor() {
    if (_stressLevel <= 2) return AppColors.success;
    if (_stressLevel <= 4) return AppColors.warning;
    if (_stressLevel <= 6) return Colors.orange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مقياس التوتر'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'كيف تشعر اليوم؟',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getStressColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStressColor(), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _getStressText(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getStressColor(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _stressLevel,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: _getStressColor(),
                    label: _stressLevel.round().toString(),
                    onChanged: (value) {
                      setState(() => _stressLevel = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('مرتاح', style: TextStyle(color: AppColors.grey)),
                      Text(
                        '${_stressLevel.round()}/10',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text('متوتر', style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تسجيل مستوى التوتر: ${_stressLevel.round()}/10'),
                      backgroundColor: _getStressColor(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تسجيل النتيجة',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
