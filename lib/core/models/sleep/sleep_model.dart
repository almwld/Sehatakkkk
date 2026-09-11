import 'package:flutter/material.dart';

enum SleepQuality { excellent, good, fair, poor }

class SleepRecord {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int durationMinutes;
  final int deepSleepMinutes;
  final int lightSleepMinutes;
  final int remSleepMinutes;
  final int awakeMinutes;
  final SleepQuality quality;
  final double? heartRate;
  final int? steps;
  final String? notes;
  final DateTime createdAt;

  SleepRecord({required this.id, required this.userId, required this.date, required this.bedtime, required this.wakeTime, required this.durationMinutes, required this.deepSleepMinutes, required this.lightSleepMinutes, required this.remSleepMinutes, required this.awakeMinutes, required this.quality, this.heartRate, this.steps, this.notes, required this.createdAt});

  double get sleepEfficiency {
    if (durationMinutes <= 0) return 0;
    final totalSleep = deepSleepMinutes + lightSleepMinutes + remSleepMinutes;
    return totalSleep / durationMinutes * 100;
  }

  String get durationFormatted => '${durationMinutes ~/ 60}h ${durationMinutes % 60}m';
  String get qualityText => const {'excellent': 'ممتاز', 'good': 'جيد', 'fair': 'مقبول', 'poor': 'سيئ'}[quality.name] ?? 'جيد';

  Color get qualityColor {
    switch (quality) {
      case SleepQuality.excellent: return Colors.green;
      case SleepQuality.good: return Colors.blue;
      case SleepQuality.fair: return Colors.orange;
      case SleepQuality.poor: return Colors.red;
    }
  }

  IconData get qualityIcon {
    switch (quality) {
      case SleepQuality.excellent: return Icons.emoji_events;
      case SleepQuality.good: return Icons.sentiment_satisfied;
      case SleepQuality.fair: return Icons.sentiment_neutral;
      case SleepQuality.poor: return Icons.sentiment_dissatisfied;
    }
  }

  Map<String, dynamic> toFirestore() => {'userId': userId, 'date': date.toIso8601String(), 'bedtime': bedtime.toIso8601String(), 'wakeTime': wakeTime.toIso8601String(), 'durationMinutes': durationMinutes, 'deepSleepMinutes': deepSleepMinutes, 'lightSleepMinutes': lightSleepMinutes, 'remSleepMinutes': remSleepMinutes, 'awakeMinutes': awakeMinutes, 'quality': quality.name, 'heartRate': heartRate, 'steps': steps, 'notes': notes, 'createdAt': createdAt.toIso8601String()};

  factory SleepRecord.fromFirestore(Map<String, dynamic> data, String id) => SleepRecord(id: id, userId: data['userId'] as String? ?? '', date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(), bedtime: DateTime.tryParse(data['bedtime'] as String? ?? '') ?? DateTime.now(), wakeTime: DateTime.tryParse(data['wakeTime'] as String? ?? '') ?? DateTime.now(), durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0, deepSleepMinutes: (data['deepSleepMinutes'] as num?)?.toInt() ?? 0, lightSleepMinutes: (data['lightSleepMinutes'] as num?)?.toInt() ?? 0, remSleepMinutes: (data['remSleepMinutes'] as num?)?.toInt() ?? 0, awakeMinutes: (data['awakeMinutes'] as num?)?.toInt() ?? 0, quality: _parseQuality(data['quality'] as String? ?? 'good'), heartRate: (data['heartRate'] as num?)?.toDouble(), steps: (data['steps'] as num?)?.toInt(), notes: data['notes'] as String?, createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now());

  static SleepQuality _parseQuality(String value) => SleepQuality.values.firstWhere((q) => q.name == value, orElse: () => SleepQuality.good);
}

class SleepSummary {
  final DateTime date;
  final int totalMinutes;
  final int deepMinutes;
  final int lightMinutes;
  final int remMinutes;
  final int awakeMinutes;
  final double efficiency;
  SleepSummary({required this.date, required this.totalMinutes, required this.deepMinutes, required this.lightMinutes, required this.remMinutes, required this.awakeMinutes, required this.efficiency});
  String get totalFormatted => '${totalMinutes ~/ 60}h ${totalMinutes % 60}m';
}
