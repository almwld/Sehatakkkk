// ============================================================
// 📁 lib/presentation/screens/exercise/exercise_plan_screen.dart
// 🏃 شاشة خطة التمارين - الإصدار النهائي
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class ExercisePlanScreen extends StatefulWidget {
  const ExercisePlanScreen({super.key});

  @override
  State<ExercisePlanScreen> createState() => _ExercisePlanScreenState();
}

class _ExercisePlanScreenState extends State<ExercisePlanScreen> {
  int _selectedLevel = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _running = false;
  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم'];

  final List<Map<String, dynamic>> _exercises = [
    {'name': 'تمارين الإحماء', 'time': '5 دقائق', 'calories': 30, 'icon': 'assets/images/tracking/walking.webp', 'color': AppColors.info},
    {'name': 'تمارين الكارديو', 'time': '20 دقيقة', 'calories': 150, 'icon': 'assets/images/tracking/running.png', 'color': AppColors.primary},
    {'name': 'تمارين القوة', 'time': '15 دقيقة', 'calories': 120, 'icon': 'assets/images/tracking/fitness.webp', 'color': AppColors.success},
    {'name': 'تمارين الإطالة', 'time': '10 دقائق', 'calories': 40, 'icon': 'assets/images/tracking/stretching.png', 'color': AppColors.purple},
    {'name': 'تمارين البطن', 'time': '10 دقائق', 'calories': 80, 'icon': 'assets/images/tracking/abs.png', 'color': AppColors.warning},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF6F8FA),
      appBar: CustomAppBar(
        title: 'خطة التمارين',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/tracking/timer.png',
              width: 24,
              height: 24,
              color: Colors.white,
              errorBuilder: (_, __, ___) => const Icon(Icons.timer),
            ),
            onPressed: _openTimer,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ اختيار المستوى
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'مستوى التمرين',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _levels.asMap().entries.map((entry) {
                      final index = entry.key;
                      final level = entry.value;
                      final selected = _selectedLevel == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLevel = index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              level,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected ? AppColors.primary : Colors.white,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // ✅ قائمة التمارين
            const Text(
              'تمارين اليوم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ..._exercises.map((exercise) => _buildExerciseCard(exercise, isDark)),
            const SizedBox(height: 20),
            
            // ✅ زر بدء التمرين
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openTimer,
                icon: Image.asset(
                  'assets/images/tracking/fitness.webp',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                  errorBuilder: (_, __, ___) => const Icon(Icons.play_arrow),
                ),
                label: const Text(
                  'بدء التمرين',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTimer() {
    final exercise = _exercises[_selectedLevel.clamp(0, _exercises.length - 1)];
    final match = RegExp(r'(\d+)').firstMatch(exercise['time'].toString());
    final minutes = int.tryParse(match?.group(1) ?? '5') ?? 5;
    _remainingSeconds = minutes * 60;
    _running = false;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          String fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
          void start() {
            if (_running) return;
            _running = true;
            _timer?.cancel();
            _timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (_remainingSeconds <= 1) { t.cancel(); _running = false; } else { _remainingSeconds--; }
              if (sheetContext.mounted) setSheetState(() {});
            });
            setSheetState(() {});
          }
          void pause() { _timer?.cancel(); _running = false; setSheetState(() {}); }
          return Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 28), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(exercise['name'].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20), Text(fmt(_remainingSeconds), style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18), Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton.filled(onPressed: _running ? pause : start, icon: Icon(_running ? Icons.pause : Icons.play_arrow), iconSize: 28),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: () { _timer?.cancel(); _running = false; _remainingSeconds = minutes * 60; setSheetState(() {}); }, child: const Text('إعادة')),
            ])
          ]));
        },
      ),
    ).whenComplete(() { _timer?.cancel(); _running = false; });
  }
  Widget _buildExerciseCard(Map<String, dynamic> exercise, bool isDark) {
    final color = exercise['color'] as Color;
    final icon = exercise['icon'] as String;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.fitness_center,
                  color: color,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '⏱ ${exercise['time']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${exercise['calories']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              const Text(
                'سعرة',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
