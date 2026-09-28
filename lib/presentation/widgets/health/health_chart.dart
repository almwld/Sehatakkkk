import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthChart extends StatelessWidget {
  final String historyKey;
  final String valueKey;
  final String unit;
  final Color color;
  final int days;
  final double? minY;
  final double? maxY;

  const HealthChart({
    super.key,
    required this.historyKey,
    required this.valueKey,
    required this.unit,
    required this.color,
    this.days = 7,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('health_metrics').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data() ?? {};
        final history = Map<String, dynamic>.from(data[historyKey] as Map? ?? {});
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('لا توجد بيانات بعد', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }
        final points = _buildPoints(history);
        final maxVal = points.map((p) => p.y).fold<double>(0, (a, b) => a > b ? a : b);
        return LineChart(LineChartData(
          minY: minY ?? 0,
          maxY: maxY ?? (maxVal * 1.2),
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
            ),
          ],
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: _buildTitles(),
        ));
      },
    );
  }

  List<FlSpot> _buildPoints(Map<String, dynamic> history) {
    return List.generate(days, (i) {
      final date = DateTime.now().subtract(Duration(days: days - 1 - i));
      final key = _formatDate(date);
      final value = history[key];
      double v = 0.0;
      if (value is num) {
        v = value.toDouble();
      } else if (value is Map) {
        v = (value[valueKey] as num?)?.toDouble() ?? 0.0;
      }
      return FlSpot(i.toDouble(), v);
    });
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= days) return const SizedBox();
            final date = DateTime.now().subtract(Duration(days: days - 1 - i));
            return Text(DateFormat('E', 'ar').format(date), style: const TextStyle(fontSize: 10));
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
