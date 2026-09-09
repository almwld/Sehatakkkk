import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// قياس معدل النبض بصرياً من تغيرات الإضاءة في إصبع موضوع على الكاميرا.
///
/// هذا قياس تقديري للاستخدام العام وليس جهازاً طبياً. لا يتم اشتقاق SpO₂
/// من BPM أو من أي قيمة افتراضية.
class HeartRateService {
  static final HeartRateService _instance = HeartRateService._internal();
  factory HeartRateService() => _instance;
  HeartRateService._internal();

  Database? _database;
  CameraController? _cameraController;

  bool _isMeasuring = false;
  bool _isInitialized = false;
  bool _processingFrame = false;
  int _currentBPM = 0;
  double _signalQuality = 0;
  double _averageBPM = 0;
  DateTime? _startTime;

  final List<double> _rawSignal = <double>[];
  final List<double> _filteredSignal = <double>[];
  final List<DateTime> _sampleTimes = <DateTime>[];
  final List<DateTime> _peakTimes = <DateTime>[];
  final List<double> _bpmHistory = <double>[];

  final StreamController<int> _bpmController = StreamController<int>.broadcast();
  final StreamController<double> _signalController = StreamController<double>.broadcast();
  final StreamController<double> _oxygenController = StreamController<double>.broadcast();
  final StreamController<List<double>> _waveformController = StreamController<List<double>>.broadcast();
  final StreamController<int> _statusController = StreamController<int>.broadcast();

  Stream<int> get bpmStream => _bpmController.stream;
  Stream<double> get signalStream => _signalController.stream;
  /// محفوظ للتوافق مع الواجهات القديمة؛ لا يتم إصدار قيمة SpO₂ مصطنعة.
  Stream<double> get oxygenStream => _oxygenController.stream;
  Stream<List<double>> get waveformStream => _waveformController.stream;
  Stream<int> get statusStream => _statusController.stream;

  bool get isMeasuring => _isMeasuring;
  bool get isInitialized => _isInitialized;
  int get currentBPM => _currentBPM;
  double get signalQuality => _signalQuality;
  double get averageBPM => _averageBPM;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = join(await getDatabasesPath(), 'heart_rate.db');
    _database = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE heart_rate_measurements(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bpm INTEGER NOT NULL,
            oxygen REAL,
            signal_quality REAL NOT NULL,
            avg_bpm REAL NOT NULL,
            duration INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE heart_rate_measurements ADD COLUMN avg_bpm REAL');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE heart_rate_measurements ADD COLUMN duration INTEGER');
          } catch (_) {}
        }
      },
    );
    return _database!;
  }

  Future<void> initializeCamera() async {
    if (_isInitialized && _cameraController?.value.isInitialized == true) return;

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      throw Exception('يلزم السماح بالكاميرا لقياس النبض');
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('لا توجد كاميرا متاحة على الجهاز');

    final camera = cameras.firstWhere(
      (item) => item.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    await _cameraController?.dispose();
    _cameraController = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    try {
      await _cameraController!.setFlashMode(FlashMode.torch);
    } catch (_) {
      // بعض الأجهزة لا تسمح بتشغيل الفلاش مع الكاميرا بهذه الطريقة.
    }
    try {
      await _cameraController!.setExposureMode(ExposureMode.locked);
    } catch (_) {}
    try {
      await _cameraController!.setFocusMode(FocusMode.locked);
    } catch (_) {}

    _isInitialized = true;
  }

  Future<void> startMeasurement() async {
    if (!_isInitialized || _cameraController?.value.isInitialized != true) {
      await initializeCamera();
    }
    if (_isMeasuring) return;

    _isMeasuring = true;
    _processingFrame = false;
    _currentBPM = 0;
    _averageBPM = 0;
    _signalQuality = 0;
    _rawSignal.clear();
    _filteredSignal.clear();
    _sampleTimes.clear();
    _peakTimes.clear();
    _bpmHistory.clear();
    _startTime = DateTime.now();
    _statusController.add(1);

    try {
      await _cameraController!.startImageStream(_processImage);
    } catch (e) {
      _isMeasuring = false;
      _statusController.add(0);
      rethrow;
    }
  }

  Future<void> stopMeasurement() async {
    if (!_isMeasuring && !(_cameraController?.value.isStreamingImages ?? false)) return;

    _isMeasuring = false;
    try {
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController!.stopImageStream();
      }
    } catch (_) {}

    try {
      if (_cameraController?.value.isInitialized == true) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (_) {}

    if (_currentBPM > 0) await _saveMeasurement();
    _statusController.add(0);
  }

  void _processImage(CameraImage image) {
    if (!_isMeasuring || _processingFrame) return;
    _processingFrame = true;
    try {
      final red = _calculateRedChannelFromYuv(image);
      if (red == null || !red.isFinite || red <= 0) return;

      final now = DateTime.now();
      _rawSignal.add(red);
      _sampleTimes.add(now);
      if (_rawSignal.length > 240) {
        _rawSignal.removeAt(0);
        _sampleTimes.removeAt(0);
      }

      final filtered = _bandPassSample();
      if (filtered == null) return;
      _filteredSignal.add(filtered);
      if (_filteredSignal.length > 240) _filteredSignal.removeAt(0);

      _signalQuality = _calculateSignalQuality();
      _signalController.add(_signalQuality);
      _waveformController.add(List<double>.from(_filteredSignal.takeLast(120)));

      if (_filteredSignal.length >= 60 && _signalQuality >= 0.35) {
        _detectPeaksAndCalculateBpm();
      } else if (_filteredSignal.length >= 60) {
        _statusController.add(1);
      }
    } catch (e) {
      debugPrint('HeartRate frame error: $e');
    } finally {
      _processingFrame = false;
    }
  }

  /// استخراج متوسط القناة الحمراء مباشرة من YUV لتجنب تحويل الصورة كاملة إلى RGB.
  double? _calculateRedChannelFromYuv(CameraImage image) {
    if (image.planes.length < 3) return null;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final width = image.width;
    final height = image.height;
    final left = width ~/ 4;
    final right = width * 3 ~/ 4;
    final top = height ~/ 4;
    final bottom = height * 3 ~/ 4;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    double total = 0;
    int count = 0;
    for (var y = top; y < bottom; y += 2) {
      final yRow = y * yPlane.bytesPerRow;
      final uvRow = (y ~/ 2) * uPlane.bytesPerRow;
      for (var x = left; x < right; x += 2) {
        final yIndex = yRow + x;
        final uvIndex = uvRow + (x ~/ 2) * uvPixelStride;
        if (yIndex >= yPlane.bytes.length || uvIndex >= uPlane.bytes.length || uvIndex >= vPlane.bytes.length) continue;
        final yValue = yPlane.bytes[yIndex] & 0xff;
        final uValue = uPlane.bytes[uvIndex] & 0xff;
        final vValue = vPlane.bytes[uvIndex] & 0xff;
        final red = yValue + 1.402 * (vValue - 128);
        total += red.clamp(0, 255);
        count++;
      }
    }
    return count == 0 ? null : total / count;
  }

  double? _bandPassSample() {
    if (_rawSignal.length < 9) return null;
    final windowStart = max(0, _rawSignal.length - 31);
    final recent = _rawSignal.sublist(windowStart);
    final mean = recent.reduce((a, b) => a + b) / recent.length;
    if (mean <= 0) return null;

    // إزالة DC ثم تطبيع السعة، مع متوسط متحرك صغير لتقليل ضجيج الإطارات.
    final normalized = (_rawSignal.last - mean) / mean;
    final smoothStart = max(0, _rawSignal.length - 5);
    var smooth = 0.0;
    var n = 0;
    for (var i = smoothStart; i < _rawSignal.length; i++) {
      smooth += (_rawSignal[i] - mean) / mean;
      n++;
    }
    return n == 0 ? normalized : smooth / n;
  }

  double _calculateSignalQuality() {
    if (_filteredSignal.length < 30) return 0;
    final recent = _filteredSignal.sublist(max(0, _filteredSignal.length - 60));
    final mean = recent.reduce((a, b) => a + b) / recent.length;
    var variance = 0.0;
    for (final value in recent) {
      variance += pow(value - mean, 2).toDouble();
    }
    final std = sqrt(variance / recent.length);
    if (!std.isFinite || std <= 0) return 0;

    final amplitude = recent.reduce(max) - recent.reduce(min);
    if (amplitude <= 0) return 0;
    final variationScore = (std / amplitude * 3).clamp(0.0, 1.0);
    return (variationScore * 0.7 + (amplitude * 2).clamp(0.0, 0.3)).clamp(0.0, 1.0);
  }

  void _detectPeaksAndCalculateBpm() {
    if (_filteredSignal.length < 45 || _sampleTimes.length != _filteredSignal.length) return;
    final start = max(2, _filteredSignal.length - 90);
    final end = _filteredSignal.length - 2;
    final local = _filteredSignal.sublist(start, end);
    final mean = local.reduce((a, b) => a + b) / local.length;
    var variance = 0.0;
    for (final value in local) variance += pow(value - mean, 2).toDouble();
    final std = sqrt(variance / local.length);
    if (std < 0.002) return;
    final threshold = mean + std * 0.35;

    for (var i = start + 1; i < end - 1; i++) {
      if (_filteredSignal[i] <= threshold ||
          _filteredSignal[i] <= _filteredSignal[i - 1] ||
          _filteredSignal[i] < _filteredSignal[i + 1]) {
        continue;
      }
      final time = _sampleTimes[i];
      if (_peakTimes.isNotEmpty) {
        final gap = time.difference(_peakTimes.last).inMilliseconds;
        if (gap < 300) continue;
        if (gap > 2000) {
          _peakTimes.add(time);
          continue;
        }
      }
      if (_peakTimes.isEmpty || time.isAfter(_peakTimes.last)) {
        _peakTimes.add(time);
        if (_peakTimes.length > 8) _peakTimes.removeAt(0);
      }
    }

    if (_peakTimes.length < 3) return;
    var totalMs = 0;
    var intervals = 0;
    for (var i = 1; i < _peakTimes.length; i++) {
      final ms = _peakTimes[i].difference(_peakTimes[i - 1]).inMilliseconds;
      if (ms >= 300 && ms <= 2000) {
        totalMs += ms;
        intervals++;
      }
    }
    if (intervals < 2) return;

    final avgMs = totalMs / intervals;
    final bpm = 60000 / avgMs;
    if (!bpm.isFinite || bpm < 40 || bpm > 200) return;

    _bpmHistory.add(bpm);
    if (_bpmHistory.length > 5) _bpmHistory.removeAt(0);
    _currentBPM = bpm.round();
    _averageBPM = _bpmHistory.reduce((a, b) => a + b) / _bpmHistory.length;
    _bpmController.add(_currentBPM);
    if (_signalQuality >= 0.55) _statusController.add(2);
  }

  Future<void> _saveMeasurement() async {
    try {
      final db = await database;
      final duration = _startTime == null ? 0 : DateTime.now().difference(_startTime!).inSeconds;
      await db.insert('heart_rate_measurements', {
        'bpm': _currentBPM,
        'oxygen': null,
        'signal_quality': _signalQuality,
        'avg_bpm': _averageBPM,
        'duration': duration,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('HeartRate save error: $e');
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    final rows = await db.query('heart_rate_measurements', orderBy: 'timestamp DESC', limit: 50);
    if (rows.isEmpty) {
      return {'avg_bpm': 0.0, 'max_bpm': 0, 'min_bpm': 0, 'count': 0, 'avg_quality': 0.0};
    }
    final bpms = rows.map((row) => (row['bpm'] as num).toDouble()).toList();
    final qualities = rows.map((row) => (row['signal_quality'] as num).toDouble()).toList();
    return {
      'avg_bpm': bpms.reduce((a, b) => a + b) / bpms.length,
      'max_bpm': bpms.reduce(max).round(),
      'min_bpm': bpms.reduce(min).round(),
      'count': rows.length,
      'avg_quality': qualities.reduce((a, b) => a + b) / qualities.length,
    };
  }

  Future<List<Map<String, dynamic>>> getHistory({int limit = 30}) async {
    final db = await database;
    return db.query('heart_rate_measurements', orderBy: 'timestamp DESC', limit: limit);
  }

  Future<void> dispose() async {
    await stopMeasurement();
    await _cameraController?.dispose();
    _cameraController = null;
    _isInitialized = false;
    await _database?.close();
    _database = null;
    await _bpmController.close();
    await _signalController.close();
    await _oxygenController.close();
    await _waveformController.close();
    await _statusController.close();
  }
}

extension on Iterable<double> {
  List<double> takeLast(int count) {
    final list = toList(growable: false);
    return list.length <= count ? list : list.sublist(list.length - count);
  }
}
