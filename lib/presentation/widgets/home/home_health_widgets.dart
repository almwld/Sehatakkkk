import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/bloc/home/home_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class HomeHealthWidgets extends StatelessWidget {
  final HomeState state;
  final bool isDark;
  final ValueChanged<String> onNavigate;

  const HomeHealthWidgets(
      {super.key,
      required this.state,
      required this.isDark,
      required this.onNavigate});

  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  @override
  Widget build(BuildContext context) {
    final vitals = <Map<String, dynamic>>[
      {'label': 'ضغط الدم', 'display': 'غير متوفر', 'color': const Color(0xFF0A8F83), 'icon': 'assets/images/tracking/blood_pressure.webp'},
      {'label': 'سكر الدم', 'display': 'غير متوفر', 'color': const Color(0xFF12AFA0), 'icon': 'assets/images/tracking/blood_sugar.webp'},
      {'label': 'اللياقة', 'display': 'غير متوفر', 'color': const Color(0xFF20B2AA), 'icon': 'assets/images/tracking/fitness.webp'},
      {'label': 'الوزن', 'display': 'غير متوفر', 'color': const Color(0xFF159A9C), 'icon': 'assets/images/tracking/weight_tracking.webp'},
      {'label': 'التغذية', 'display': 'غير متوفر', 'color': const Color(0xFF2BB7A9), 'icon': 'assets/images/tracking/nutrition.webp'},
      {'label': 'الصحة النفسية', 'display': 'غير متوفر', 'color': const Color(0xFF3AAFA9), 'icon': 'assets/images/tracking/mental_health.webp'},
    ];
    final score = state.healthScore.round().clamp(0, 100);
    return Column(children: [
      _header(context, 'ملخصك الصحي'),
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
                        ? _t(context, 'أضف قياساتك الصحية لاحتساب المؤشر.')
                        : _t(context, 'تابع نشاطك ونومك ومؤشراتك الحيوية باستمرار.'),
                    style: TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]))),
          ]),
        ),
      ),
      const SizedBox(height: 10),
      _header(context, 'المؤشرات الحيوية'),
      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _healthMetricsFuture(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? const <String, dynamic>{};
          final unified = [
            {
              'label': 'السعرات',
              'display': state.calories > 0 ? '${_number(state.calories)} kcal' : 'غير متوفر',
              'color': AppColors.primary,
              'icon': 'assets/images/tracking/calories.png',
              'progress': (state.calories / 2000).clamp(0.0, 1.0).toDouble(),
            },
            {
              'label': 'الخطوات',
              'display': state.steps > 0 ? '${_number(state.steps)} خطوة' : 'غير متوفر',
              'color': Colors.green,
              'icon': 'assets/icons/health/step_tracking.webp',
              'progress': (state.steps / 10000).clamp(0.0, 1.0).toDouble(),
            },
            {
              'label': 'النوم',
              'display': state.sleep > 0 ? '${_number(state.sleep)} ساعة' : 'غير متوفر',
              'color': Colors.purple,
              'icon': 'assets/icons/health/sleep/sleep_tracking.webp',
              'progress': (state.sleep / 8).clamp(0.0, 1.0).toDouble(),
            },
            {
              'label': 'النبض',
              'display': state.heartRate > 0 ? '${_number(state.heartRate)} bpm' : 'غير متوفر',
              'color': Colors.red,
              'icon': 'assets/icons/health/heart_rate.webp',
              'progress': state.heartRate > 0 ? 1.0 : 0.0,
            },
            {...vitals[0], 'display': data['systolic'] != null && data['diastolic'] != null ? '${data['systolic']}/${data['diastolic']}' : 'غير متوفر'},
            {...vitals[1], 'display': data['blood_sugar'] != null ? '${data['blood_sugar']}' : 'غير متوفر'},
            {...vitals[2], 'display': data['steps'] != null ? '${data['steps']} خطوة' : 'غير متوفر'},
            {...vitals[3], 'display': data['weight'] != null ? '${data['weight']} كجم' : 'غير متوفر'},
            ...vitals.sublist(4),
          ];
          return SizedBox(height: 154, child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: unified.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => Transform.scale(
              scale: 0.95,
              child: _vital(context, unified[i], data),
            ),
          ));
        },
      ),
    ]);
  }

  Widget _header(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(children: [
        Expanded(
            child: Text(_t(context, title),
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF212121)))),
        TextButton(
            onPressed: () => onNavigate(AppRouter.dashboard),
            child: Text(_t(context, 'عرض الكل'),
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)))
      ]));

  String? _trackerRoute(String name) {
    switch (name) {
      case 'ضغط الدم': return AppRouter.bloodPressure;
      case 'سكر الدم': return AppRouter.glucoseTracker;
      case 'اللياقة': return AppRouter.stepTracker;
      case 'الوزن': return AppRouter.weightTracker;
      case 'التغذية': return AppRouter.dietPlan;
      case 'الصحة النفسية': return AppRouter.mentalHealth;
      case 'السعرات': return AppRouter.nutrition;
      case 'الخطوات': return AppRouter.stepTracker;
      case 'النوم': return AppRouter.sleepTracker;
      case 'النبض': return AppRouter.heartRate;
      default: return null;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _healthMetricsFuture() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Future.error('not_authenticated');
    return FirebaseFirestore.instance.collection('health_metrics').doc(uid).get();
  }

  double _vitalProgress(Map<String, dynamic> item, Map<String, dynamic> data) {
    final suppliedProgress = item['progress'];
    if (suppliedProgress is num) {
      return suppliedProgress.toDouble().clamp(0.0, 1.0);
    }
    final label = item['label'] as String;
    num? number(String key) => data[key] is num ? data[key] as num : null;
    switch (label) {
      case 'ضغط الدم':
        final s = number('systolic');
        final d = number('diastolic');
        if (s == null || d == null) return 0;
        // Visual completion only: the ring indicates that a blood-pressure reading exists.
        return 1;
      case 'سكر الدم':
        return number('blood_sugar') == null ? 0 : 1;
      case 'اللياقة':
        final steps = number('steps');
        return steps == null ? 0 : (steps / 10000).clamp(0.0, 1.0).toDouble();
      case 'الوزن':
        return number('weight') == null ? 0 : 1;
      case 'التغذية':
        final calories = number('calories');
        final water = number('water');
        if (calories != null) return (calories / 2000).clamp(0.0, 1.0).toDouble();
        if (water != null) return (water / 2.0).clamp(0.0, 1.0).toDouble();
        return 0;
      case 'الصحة النفسية':
        final mood = number('moodScore');
        return mood == null ? 0 : (mood / 10).clamp(0.0, 1.0).toDouble();
      default:
        return 0;
    }
  }

  Widget _vital(BuildContext context, Map<String, dynamic> item, Map<String, dynamic> data) {
    final color = item['color'] as Color;
    final progress = _vitalProgress(item, data);
    return SizedBox(
      width: 126,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            final route = _trackerRoute(item['label'] as String);
            onNavigate(route ?? AppRouter.dashboard);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_t(context, item['label'] as String),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[300] : Colors.grey[700])),
                  const SizedBox(width: 6),
                  Text(_t(context, item['display'] as String),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: color)),
                ],
              ),
              const SizedBox(height: 5),
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
                  ],
                ),
              ),
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
