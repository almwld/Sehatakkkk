import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/vitals_service.dart';

class LiveVitalsGrid extends StatelessWidget {
  final List<String> keys;
  final bool compact;
  const LiveVitalsGrid({super.key, required this.keys, this.compact = false});

  static const _labels = <String, String>{
    'bloodPressure': 'ضغط الدم',
    'glucose': 'سكر الدم',
    'heartRate': 'نبض القلب',
    'weight': 'الوزن',
    'bloodOxygen': 'الأكسجين',
    'temperature': 'درجة الحرارة',
  };
  static const _units = <String, String>{
    'bloodPressure': 'mmHg',
    'glucose': 'mg/dL',
    'heartRate': 'bpm',
    'weight': 'kg',
    'bloodOxygen': '%',
    'temperature': '°C',
  };
  static const _icons = <String, String>{
    'bloodPressure': 'assets/images/tracking/blood_pressure.webp',
    'glucose': 'assets/images/tracking/blood_sugar.webp',
    'heartRate': 'assets/images/tracking/heart_rate.png',
    'weight': 'assets/images/tracking/weight_tracking.webp',
    'bloodOxygen': 'assets/images/tracking/blood_oxygen.png',
    'temperature': 'assets/images/tracking/temperature.png',
  };

  String _display(String key, dynamic value) => value == null ? '--' : '$value';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: VitalsService.instance.watchCurrent(),
      builder: (context, snapshot) {
        final current = snapshot.data ?? const <String, dynamic>{};
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: compact ? 2 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: compact ? 1.25 : 1.05,
          ),
          itemCount: keys.length,
          itemBuilder: (_, index) {
            final key = keys[index];
            return _LiveVitalCard(
              keyName: key,
              label: _labels[key] ?? key,
              unit: _units[key] ?? '',
              value: _display(key, current[key]),
              icon: _icons[key],
              compact: compact,
            );
          },
        );
      },
    );
  }
}

class _LiveVitalCard extends StatelessWidget {
  final String keyName;
  final String label;
  final String unit;
  final String value;
  final String? icon;
  final bool compact;
  const _LiveVitalCard({required this.keyName, required this.label, required this.unit, required this.value, required this.icon, required this.compact});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: VitalsService.instance.watchHistory(keyName),
      builder: (context, snapshot) {
        final history = (snapshot.data ?? const <Map<String, dynamic>>[]).reversed.toList();
        final points = history.map((e) => e['value']).whereType<num>().map((e) => e.toDouble()).toList();
        final color = AppColors.primary;
        return Container(
          padding: EdgeInsets.all(compact ? 10 : 14),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (icon != null) Image.asset(icon!, width: compact ? 28 : 34, height: compact ? 28 : 34, errorBuilder: (_, __, ___) => Icon(Icons.monitor_heart_outlined, color: color)),
                const SizedBox(width: 8),
                Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
              ]),
              const SizedBox(height: 6),
              Text(value == '--' ? '--' : '$value${unit.isEmpty ? '' : ' $unit'}', style: TextStyle(fontSize: compact ? 16 : 19, fontWeight: FontWeight.w900, color: color)),
              if (!compact) ...[
                const SizedBox(height: 4),
                Text(points.length < 2 ? 'لا يوجد سجل كافٍ بعد' : 'آخر ${points.length} قراءة', style: TextStyle(fontSize: 9, color: dark ? Colors.white54 : Colors.black45)),
                const SizedBox(height: 4),
                SizedBox(height: 30, child: CustomPaint(painter: _MiniChartPainter(points, color), size: const Size(double.infinity, 30))),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _MiniChartPainter(this.values, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < .001 ? 1 : maxV - minV;
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _MiniChartPainter old) => old.values != values || old.color != color;
}
