import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HomeHealthWidgets extends StatelessWidget {
  final HomeState state;
  final bool isDark;
  final ValueChanged<String> onNavigate;

  const HomeHealthWidgets(
      {super.key,
      required this.state,
      required this.isDark,
      required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final stats = <Map<String, dynamic>>[
      {
        'name': 'السعرات',
        'value': state.calories,
        'unit': 'kcal',
        'color': Colors.orange,
        'icon': 'assets/images/tracking/calories.png'
      },
      {
        'name': 'الخطوات',
        'value': state.steps,
        'unit': 'خطوة',
        'color': Colors.green,
        'icon': 'assets/images/tracking/steps.png'
      },
      {
        'name': 'النوم',
        'value': state.sleep,
        'unit': 'ساعة',
        'color': Colors.purple,
        'icon': 'assets/images/tracking/sleep.png'
      },
      {
        'name': 'النبض',
        'value': state.heartRate,
        'unit': 'bpm',
        'color': Colors.red,
        'icon': 'assets/images/tracking/heart_rate.png'
      },
    ];
    final vitals = <Map<String, dynamic>>[
      {
        'label': 'ضغط الدم',
        'value': 120.0,
        'max': 180.0,
        'color': Colors.red,
        'icon': 'assets/images/tracking/blood_pressure.png'
      },
      {
        'label': 'سكر الدم',
        'value': 98.0,
        'max': 200.0,
        'color': Colors.orange,
        'icon': 'assets/images/tracking/blood_sugar.png'
      },
      {
        'label': 'اللياقة',
        'value': 85.0,
        'max': 100.0,
        'color': Colors.green,
        'icon': 'assets/images/tracking/fitness.png'
      },
      {
        'label': 'الوزن',
        'value': 72.0,
        'max': 120.0,
        'color': Colors.purple,
        'icon': 'assets/images/tracking/weight_tracking.png'
      },
      {
        'label': 'التغذية',
        'value': 8.0,
        'max': 10.0,
        'color': Colors.teal,
        'icon': 'assets/images/tracking/nutrition.png'
      },
      {
        'label': 'الصحة النفسية',
        'value': 9.0,
        'max': 10.0,
        'color': Colors.indigo,
        'icon': 'assets/images/tracking/mental_health.png'
      },
    ];
    final score = state.healthScore.round().clamp(0, 100);
    return Column(children: [
      _header('ملخصك الصحي'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            SizedBox(
                width: 82,
                height: 82,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 7,
                      backgroundColor: AppColors.primary.withOpacity(.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary)),
                  Text('$score',
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87)),
                ])),
            const SizedBox(width: 14),
            Expanded(
                child: Text(
                    score == 0
                        ? 'أضف قياساتك الصحية لاحتساب المؤشر.'
                        : 'تابع نشاطك ونومك ومؤشراتك الحيوية باستمرار.',
                    style: TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]))),
          ]),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
          height: 92,
          child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: stats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _stat(stats[i]))),
      _header('المؤشرات الحيوية'),
      SizedBox(
          height: 154,
          child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: vitals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _vital(vitals[i]))),
    ]);
  }

  Widget _header(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(children: [
        Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF212121)))),
        TextButton(
            onPressed: () => onNavigate(AppRouter.dashboard),
            child: const Text('عرض الكل',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)))
      ]));

  Widget _stat(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final value = (item['value'] as num).toDouble();
    return SizedBox(
      width: 112,
      child: Material(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onNavigate(AppRouter.dashboard),
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(item['icon'] as String,
                  width: 23,
                  height: 23,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.insights_outlined, color: color, size: 22)),
              const SizedBox(height: 2),
              Text(_number(value),
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(item['name'] as String,
                  style: TextStyle(color: color.withOpacity(.8), fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vital(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    final progress =
        ((item['value'] as num).toDouble() / (item['max'] as num).toDouble())
            .clamp(0.0, 1.0);
    return SizedBox(
      width: 126,
      child: Material(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => onNavigate(AppRouter.dashboard),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                        size: const Size.square(76),
                        painter: _VitalPainter(progress, color)),
                    Image.asset(item['icon'] as String,
                        width: 25,
                        height: 25,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.favorite_outline,
                            color: color,
                            size: 25)),
                    Positioned(
                        bottom: 0,
                        child: Text('${(progress * 100).toInt()}%',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color))),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(item['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  static String _number(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _VitalPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _VitalPainter(this.progress, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 5;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(.15);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, math.pi * 2 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _VitalPainter old) =>
      old.progress != progress || old.color != color;
}
