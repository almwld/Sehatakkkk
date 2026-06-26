import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ExercisePlanScreen extends StatefulWidget {
  const ExercisePlanScreen({super.key});

  @override
  State<ExercisePlanScreen> createState() => _ExercisePlanScreenState();
}

class _ExercisePlanScreenState extends State<ExercisePlanScreen> {
  int _selectedLevel = 0;
  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم'];

  final List<Map<String, dynamic>> _exercises = [
    {'name': 'تمارين الإحماء', 'time': '5 دقائق', 'calories': 30, 'icon': Icons.directions_walk, 'color': AppColors.info},
    {'name': 'تمارين الكارديو', 'time': '20 دقيقة', 'calories': 150, 'icon': Icons.run_circle, 'color': AppColors.primary},
    {'name': 'تمارين القوة', 'time': '15 دقيقة', 'calories': 120, 'icon': Icons.fitness_center, 'color': AppColors.success},
    {'name': 'تمارين الإطالة', 'time': '10 دقائق', 'calories': 40, 'icon': Icons.accessibility_new, 'color': AppColors.purple},
    {'name': 'تمارين البطن', 'time': '10 دقائق', 'calories': 80, 'icon': Icons.fitness_center, 'color': AppColors.warning},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطة التمارين', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة مؤقت التمارين قريباً'), backgroundColor: AppColors.info),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('مستوى التمرين', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
            const Text('تمارين اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._exercises.map((exercise) => _buildExerciseCard(exercise)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🚀 بدء التمرين...'), backgroundColor: AppColors.primary),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('بدء التمرين', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final color = exercise['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: Icon(exercise['icon'], color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('⏱ ${exercise['time']}', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
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
              const Text('سعرة', style: TextStyle(fontSize: 9, color: AppColors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
