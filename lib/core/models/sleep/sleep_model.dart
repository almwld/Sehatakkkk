import 'package:cloud_firestore/cloud_firestore.dart';

enum SleepQuality {
  excellent,   // ممتاز
  good,        // جيد
  fair,        // مقبول
  poor,        // سيئ
}

class SleepRecord {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime bedtime;      // وقت النوم
  final DateTime wakeTime;     // وقت الاستيقاظ
  final int durationMinutes;   // مدة النوم بالدقائق
  final int deepSleepMinutes;  // النوم العميق
  final int lightSleepMinutes; // النوم الخفيف
  final int remSleepMinutes;   // نوم الريم
  final int awakeMinutes;      // وقت الاستيقاظ أثناء النوم
  final SleepQuality quality;
  final double? heartRate;     // متوسط معدل النبض
  final int? steps;            // عدد الخطوات قبل النوم
  final String? notes;
  final DateTime createdAt;

  SleepRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.durationMinutes,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
    required this.remSleepMinutes,
    required this.awakeMinutes,
    required this.quality,
    this.heartRate,
    this.steps,
    this.notes,
    required this.createdAt,
  });

  double get sleepEfficiency {
    final totalSleep = deepSleepMinutes + lightSleepMinutes + remSleepMinutes;
    return totalSleep / durationMinutes * 100;
  }

  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get qualityText {
    switch (quality) {
      case SleepQuality.excellent: return 'ممتاز';
      case SleepQuality.good: return 'جيد';
      case SleepQuality.fair: return 'مقبول';
      case SleepQuality.poor: return 'سيئ';
    }
  }

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

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'date': date.toIso8601String(),
    'bedtime': bedtime.toIso8601String(),
    'wakeTime': wakeTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'deepSleepMinutes': deepSleepMinutes,
    'lightSleepMinutes': lightSleepMinutes,
    'remSleepMinutes': remSleepMinutes,
    'awakeMinutes': awakeMinutes,
    'quality': quality.toString().split('.').last,
    'heartRate': heartRate,
    'steps': steps,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SleepRecord.fromFirestore(Map<String, dynamic> data, String id) => SleepRecord(
    id: id,
    userId: data['userId'] ?? '',
    date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
    bedtime: DateTime.parse(data['bedtime'] ?? DateTime.now().toIso8601String()),
    wakeTime: DateTime.parse(data['wakeTime'] ?? DateTime.now().toIso8601String()),
    durationMinutes: data['durationMinutes'] ?? 0,
    deepSleepMinutes: data['deepSleepMinutes'] ?? 0,
    lightSleepMinutes: data['lightSleepMinutes'] ?? 0,
    remSleepMinutes: data['remSleepMinutes'] ?? 0,
    awakeMinutes: data['awakeMinutes'] ?? 0,
    quality: _parseQuality(data['quality'] ?? 'good'),
    heartRate: data['heartRate']?.toDouble(),
    steps: data['steps'],
    notes: data['notes'],
    createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
  );

  static SleepQuality _parseQuality(String value) {
    switch (value) {
      case 'excellent': return SleepQuality.excellent;
      case 'good': return SleepQuality.good;
      case 'fair': return SleepQuality.fair;
      case 'poor': return SleepQuality.poor;
      default: return SleepQuality.good;
    }
  }
}

class SleepSummary {
  final DateTime date;
  final int totalMinutes;
  final int deepMinutes;
  final int lightMinutes;
  final int remMinutes;
  final int awakeMinutes;
  final double efficiency;

  SleepSummary({
    required this.date,
    required this.totalMinutes,
    required this.deepMinutes,
    required this.lightMinutes,
    required this.remMinutes,
    required this.awakeMinutes,
    required this.efficiency,
  });

  String get totalFormatted {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
