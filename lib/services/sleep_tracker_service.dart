import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SleepTrackerService {
  static final SleepTrackerService _instance = SleepTrackerService._internal();
  factory SleepTrackerService() => _instance;
  SleepTrackerService._internal();

  Database? _database;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<AccelerometerEvent>? _acc;
  StreamSubscription<GyroscopeEvent>? _gyro;
  final List<double> _movement = <double>[];
  final List<double> _gyroData = <double>[];
  DateTime? _start;
  bool _tracking = false;
  int _snoreCount = 0;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(join(await getDatabasesPath(), 'sleep_tracker.db'), version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE sleep_sessions(id INTEGER PRIMARY KEY AUTOINCREMENT,start_time INTEGER,end_time INTEGER,duration REAL,quality REAL,movement_count INTEGER,audio_level REAL,sleep_score REAL,deep_sleep REAL,light_sleep REAL,rem_sleep REAL,awake_count INTEGER,snore_count INTEGER,side_sleep INTEGER,back_sleep INTEGER,stomach_sleep INTEGER,timestamp INTEGER)');
      });
    return _database!;
  }

  bool get isTracking => _tracking;
  int get snoreCount => _snoreCount;

  Future<void> startTracking() async {
    if (_tracking) return;
    _movement.clear();
    _gyroData.clear();
    _snoreCount = 0;
    _start = DateTime.now();
    _tracking = true;
    _acc = accelerometerEvents.listen((e) => _movement.add(sqrt(e.x * e.x + e.y * e.y + e.z * e.z)));
    _gyro = gyroscopeEvents.listen((e) => _gyroData.add(e.x.abs() + e.y.abs() + e.z.abs()));
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000, sampleRate: 16000, numChannels: 1), path: '${dir.path}/sleep_${DateTime.now().millisecondsSinceEpoch}.m4a');
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> stopTracking() async {
    if (!_tracking) return {'duration': 0.0, 'quality': 0.0, 'snore': 0, 'dataAvailable': false};
    await _acc?.cancel();
    await _gyro?.cancel();
    _acc = null; _gyro = null;
    String? audioPath;
    try { audioPath = await _recorder.stop(); } catch (_) {}
    if (audioPath != null) await _analyzeAudio(audioPath);
    _tracking = false;
    final end = DateTime.now();
    final durationHours = _start == null ? 0.0 : end.difference(_start!).inSeconds / 3600.0;
    final quality = _calculateQuality();
    final db = await database;
    await db.insert('sleep_sessions', {
      'start_time': _start?.millisecondsSinceEpoch,
      'end_time': end.millisecondsSinceEpoch,
      'duration': durationHours,
      'quality': quality,
      'movement_count': _movement.length,
      'audio_level': _snoreCount.toDouble(),
      'sleep_score': quality,
      'deep_sleep': null, 'light_sleep': null, 'rem_sleep': null,
      'awake_count': null, 'snore_count': _snoreCount,
      'side_sleep': null, 'back_sleep': null, 'stomach_sleep': null,
      'timestamp': end.millisecondsSinceEpoch,
    });
    _start = null;
    return {'duration': durationHours, 'quality': quality, 'snore': _snoreCount, 'dataAvailable': true};
  }

  double _calculateQuality() {
    if (_movement.isEmpty) return 0.0;
    final mean = _movement.reduce((a, b) => a + b) / _movement.length;
    final variance = _movement.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / _movement.length;
    final stability = (1.0 - min(1.0, sqrt(variance) / 3.0)).clamp(0.0, 1.0);
    return (stability * 10).clamp(0.0, 10.0).toDouble();
  }

  Future<void> _analyzeAudio(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      if (bytes.length < 4096) return;
      // لا نحسب الشخير من bytes الخام؛ ملفات AAC مضغوطة ولا تمثل amplitude الصوتية مباشرة.
      // إبقاء القيمة صفرًا أفضل من إنتاج تشخيص/عدد شخير وهمي.
      _snoreCount = 0;
    } catch (_) {}
  }

  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    final rows = await db.query('sleep_sessions', orderBy: 'timestamp DESC');
    final qualities = rows.map((r) => (r['quality'] as num?)?.toDouble() ?? 0.0).toList();
    return {'total_sessions': rows.length, 'best_quality': qualities.isEmpty ? 0.0 : qualities.reduce(max)};
  }

  Future<List<Map<String, dynamic>>> getWeekData() async {
    final db = await database;
    final from = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final rows = await db.query('sleep_sessions', where: 'timestamp >= ?', whereArgs: [from], orderBy: 'timestamp ASC');
    return rows.map((r) => {'day': DateTime.fromMillisecondsSinceEpoch((r['timestamp'] as num).toInt()).weekday.toString(), 'hours': (r['duration'] as num?)?.toDouble() ?? 0.0, 'quality': (r['quality'] as num?)?.toDouble() ?? 0.0, 'snore': (r['snore_count'] as num?)?.toInt() ?? 0}).toList();
  }

  Future<void> clearData() async { final db = await database; await db.delete('sleep_sessions'); }
  Future<void> dispose() async { await _acc?.cancel(); await _gyro?.cancel(); if (_tracking) { try { await _recorder.stop(); } catch (_) {} } }
}
