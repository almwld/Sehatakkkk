import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HomeStats extends StatefulWidget {
  final bool isDark;

  const HomeStats({super.key, required this.isDark});

  @override
  State<HomeStats> createState() => _HomeStatsState();
}

class _HomeStatsState extends State<HomeStats> {
  double _calories = 0;
  double _steps = 0;
  double _sleep = 0;
  double _heart = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _calories = 2450;
          _steps = 8542;
          _sleep = 7.5;
          _heart = 72;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsData = [
      {'icon': Icons.local_fire_department, 'value': _calories, 'label': 'سعرة حرارية', 'color': AppColors.primary, 'format': 'int'},
      {'icon': Icons.directions_walk, 'value': _steps, 'label': 'خطوة', 'color': AppColors.primary, 'format': 'int'},
      {'icon': Icons.bedtime, 'value': _sleep, 'label': 'ساعات النوم', 'color': AppColors.primary, 'format': 'double'},
      {'icon': Icons.favorite, 'value': _heart, 'label': 'نبضة/دقيقة', 'color': AppColors.primary, 'format': 'int'},
    ];

    return Row(
      children: statsData.map((stat) {
        final color = stat['color'] as Color;
        final value = stat['value'] as double;
        final isInt = stat['format'] == 'int';
        
        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              final displayVal = isInt ? val.toInt().toString() : val.toStringAsFixed(1);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(stat['icon'] as IconData, color: color, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      displayVal,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    Text(
                      stat['label'] as String,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
