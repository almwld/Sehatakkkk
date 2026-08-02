import 'package:cloud_firestore/cloud_firestore.dart';

class StepRecord {
  final String id;
  final String userId;
  final DateTime date;
  final int steps;
  final double distance;      // المسافة بالمتر
  final int calories;         // السعرات المحروقة
  final int activeMinutes;    // الدقائق النشطة
  final double? avgSpeed;     // متوسط السرعة
  final int? maxSteps;        // أقصى خطوات في الدقيقة
  final List<int>? hourlySteps; // الخطوات لكل ساعة
  final DateTime createdAt;

  StepRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
    required this.activeMinutes,
    this.avgSpeed,
    this.maxSteps,
    this.hourlySteps,
    required this.createdAt,
  });

  double get distanceKm => distance / 1000;
  double get stepsPerMinute => activeMinutes > 0 ? steps / activeMinutes : 0;
  
  String get stepsFormatted {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}K';
    }
    return steps.toString();
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'date': date.toIso8601String(),
    'steps': steps,
    'distance': distance,
    'calories': calories,
    'activeMinutes': activeMinutes,
    'avgSpeed': avgSpeed,
    'maxSteps': maxSteps,
    'hourlySteps': hourlySteps,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StepRecord.fromFirestore(Map<String, dynamic> data, String id) => StepRecord(
    id: id,
    userId: data['userId'] ?? '',
    date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
    steps: data['steps'] ?? 0,
    distance: data['distance']?.toDouble() ?? 0,
    calories: data['calories'] ?? 0,
    activeMinutes: data['activeMinutes'] ?? 0,
    avgSpeed: data['avgSpeed']?.toDouble(),
    maxSteps: data['maxSteps'],
    hourlySteps: data['hourlySteps'] != null ? List<int>.from(data['hourlySteps']) : null,
    createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
  );
}

class StepsSummary {
  final DateTime date;
  final int steps;
  final double distance;
  final int calories;
  final int activeMinutes;

  StepsSummary({
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
    required this.activeMinutes,
  });

  double get distanceKm => distance / 1000;
}
