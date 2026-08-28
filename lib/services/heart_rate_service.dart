/*
// ============================================================
// 📁 lib/services/heart_rate_service.dart
// Heart Rate خدمة قياس نبضات القلب باستخدام الكاميرا
// ============================================================

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class HeartRateService {
  static final HeartRateService _instance = HeartRateService._internal();
  factory HeartRateService() => _instance;
  HeartRateService._internal();

  // ============================================================
  // 📊 متغيرات الحالة
  // ============================================================
  Database? _database;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  
  bool _isMeasuring = false;
  bool _isInitialized = false;
  int _currentBPM = 0;
  double _oxygenSaturation = 98.0;
  double _signalQuality = 0.0;
  double _averageBPM = 0.0;
  
  // 📈 بيانات الإشارة
  List<double> _ppgSignal = [];
  List<double> _filteredSignal = [];
  List<int> _peakTimes = [];
  List<double> _bpmHistory = [];
  List<double> _signalBuffer = [];
  
  // 📡 Streams للتحديث
  final StreamController<int> _bpmController = StreamController<int>.broadcast();
  final StreamController<double> _signalController = StreamController<double>.broadcast();
  final StreamController<double> _oxygenController = StreamController<double>.broadcast();
  final StreamController<List<double>> _waveformController = StreamController<List<double>>.broadcast();
  final StreamController<int> _statusController = StreamController<int>.broadcast();
  
  Stream<int> get bpmStream => _bpmController.stream;
  Stream<double> get signalStream => _signalController.stream;
  Stream<double> get oxygenStream => _oxygenController.stream;
  Stream<List<double>> get waveformStream => _waveformController.stream;
  Stream<int> get statusStream => _statusController.stream;

  // 🎯 ثوابت الخوارزمية
  static const double _SAMPLE_RATE = 30.0;
  static const int _WINDOW_SIZE = 150;
  static const double _LOW_PASS_ALPHA = 0.1;
  static const double _HIGH_PASS_ALPHA = 0.01;
  static const double _PEAK_THRESHOLD = 0.3;
  static const int _MIN_PEAK_DISTANCE = 20;
  
  double _prevLowPass = 0.0;
  double _prevHighPass = 0.0;
  int _frameCount = 0;
  DateTime? _startTime;

  // ============================================================
  // 🏗️ Getters
  // ============================================================
  bool get isMeasuring => _isMeasuring;
  bool get isInitialized => _isInitialized;
  int get currentBPM => _currentBPM;
  double get oxygenSaturation => _oxygenSaturation;
  double get signalQuality => _signalQuality;
  double get averageBPM => _averageBPM;

  // ============================================================
  // 🗄️ قاعدة البيانات
  // ============================================================
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'heart_rate.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE heart_rate_measurements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bpm INTEGER,
        oxygen REAL,
        signal_quality REAL,
        avg_bpm REAL,
        duration INTEGER,
        timestamp INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE heart_rate_measurements ADD COLUMN avg_bpm REAL');
      await db.execute('ALTER TABLE heart_rate_measurements ADD COLUMN duration INTEGER');
    }
  }

  // ============================================================
  // 📷 تهيئة الكاميرا
  // ============================================================
  Future<void> initializeCamera() async {
    try {
      if (!await Permission.camera.isGranted) {
        await Permission.camera.request();
      }
      
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('لا توجد كاميرات متاحة');
      }
      
      CameraDescription camera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(FlashMode.torch);
      await _cameraController!.setExposureMode(ExposureMode.locked);
      await _cameraController!.setFocusMode(FocusMode.locked);
      
      _isInitialized = true;
      debugPrint('Success كاميرا مهيأة بنجاح');
      
    } catch (e) {
      debugPrint('Error خطأ في تهيئة الكاميرا: $e');
      rethrow;
    }
  }

  // ============================================================
  Start بدء القياس
  // ============================================================
  Future<void> startMeasurement() async {
    if (!_isInitialized) {
      await initializeCamera();
    }
    
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw Exception('الكاميرا غير مهيأة');
    }
    
    _isMeasuring = true;
    _ppgSignal.clear();
    _filteredSignal.clear();
    _peakTimes.clear();
    _bpmHistory.clear();
    _signalBuffer.clear();
    _currentBPM = 0;
    _averageBPM = 0.0;
    _frameCount = 0;
    _startTime = DateTime.now();
    _prevLowPass = 0.0;
    _prevHighPass = 0.0;
    
    debugPrint('Heart Rate بدء قياس النبض...');
    _statusController.add(1);
    
    _cameraController!.startImageStream(_processImage);
    _startForegroundService();
  }

  // ============================================================
  🛑 إيقاف القياس
  // ============================================================
  Future<void> stopMeasurement() async {
    _isMeasuring = false;
    
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.setFlashMode(FlashMode.off);
    }
    
    if (_currentBPM > 0) {
      await _saveMeasurement();
    }
    
    _stopForegroundService();
    _statusController.add(0);
    
    debugPrint('Stop إيقاف قياس النبض');
  }

  // ============================================================
  Processing معالجة الإطارات
  // ============================================================
  void _processImage(CameraImage image) {
    if (!_isMeasuring) return;
    
    try {
      _frameCount++;
      Uint8List? rgbData = _convertYUV420ToRGB(image);
      
      if (rgbData != null) {
        double redChannel = _calculateRedChannel(rgbData, image.width, image.height);
        double filtered = _applyFilters(redChannel);
        
        _ppgSignal.add(redChannel);
        _filteredSignal.add(filtered);
        _signalBuffer.add(filtered);
        
        if (_ppgSignal.length > _WINDOW_SIZE) {
          _ppgSignal.removeAt(0);
          _filteredSignal.removeAt(0);
        }
        
        if (_signalBuffer.length > 30) {
          _signalBuffer.removeAt(0);
        }
        
        if (_filteredSignal.length > 10) {
          _detectPeaksAndCalculateBPM();
        }
        
        _signalQuality = _calculateSignalQuality();
        _signalController.add(_signalQuality);
        _waveformController.add(List.from(_filteredSignal));
        _calculateOxygenSaturation();
      }
      
    } catch (e) {
      debugPrint('Warning خطأ في معالجة الإطار: $e');
    }
  }

  // ============================================================
  🔄 تحويل YUV إلى RGB
  // ============================================================
  Uint8List? _convertYUV420ToRGB(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvPixelStride = image.planes[1].bytesPerPixel ?? 2;
      final int uvRowStride = image.planes[1].bytesPerRow;
      
      final Uint8List yPlane = image.planes[0].bytes;
      final Uint8List uPlane = image.planes[1].bytes;
      final Uint8List vPlane = image.planes[2].bytes;
      
      final Uint8List rgbData = Uint8List(width * height * 3);
      int rgbIndex = 0;
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * image.planes[0].bytesPerRow + x;
          final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
          
          final int yValue = yPlane[yIndex] & 0xFF;
          final int uValue = uPlane[uvIndex] & 0xFF;
          final int vValue = vPlane[uvIndex] & 0xFF;
          
          int r = (yValue + 1.370705 * (vValue - 128)).round();
          int g = (yValue - 0.698001 * (vValue - 128) - 0.337633 * (uValue - 128)).round();
          int b = (yValue + 1.732446 * (uValue - 128)).round();
          
          rgbData[rgbIndex++] = r.clamp(0, 255);
          rgbData[rgbIndex++] = g.clamp(0, 255);
          rgbData[rgbIndex++] = b.clamp(0, 255);
        }
      }
      return rgbData;
      
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  🔴 حساب القناة الحمراء
  // ============================================================
  double _calculateRedChannel(Uint8List rgbData, int width, int height) {
    int totalRed = 0;
    int count = 0;
    
    int startX = width ~/ 4;
    int endX = width * 3 ~/ 4;
    int startY = height ~/ 4;
    int endY = height * 3 ~/ 4;
    
    for (int y = startY; y < endY; y++) {
      for (int x = startX; x < endX; x++) {
        int index = (y * width + x) * 3;
        totalRed += rgbData[index];
        count++;
      }
    }
    
    return count > 0 ? totalRed / count : 0.0;
  }

  // ============================================================
  🔽 تطبيق الفلاتر
  // ============================================================
  double _applyFilters(double value) {
    double lowPass = _prevLowPass + _LOW_PASS_ALPHA * (value - _prevLowPass);
    _prevLowPass = lowPass;
    
    double highPass = _HIGH_PASS_ALPHA * (lowPass - _prevHighPass) + _prevHighPass;
    _prevHighPass = highPass;
    
    return highPass / 255.0;
  }

  // ============================================================
  📈 كشف القمم وحساب BPM
  // ============================================================
  void _detectPeaksAndCalculateBPM() {
    if (_filteredSignal.length < 10) return;
    
    double mean = _filteredSignal.reduce((a, b) => a + b) / _filteredSignal.length;
    double std = sqrt(_filteredSignal.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / _filteredSignal.length);
    double threshold = mean + _PEAK_THRESHOLD * std;
    
    for (int i = 5; i < _filteredSignal.length - 5; i++) {
      if (_filteredSignal[i] > threshold &&
          _filteredSignal[i] > _filteredSignal[i-1] &&
          _filteredSignal[i] > _filteredSignal[i+1]) {
        
        bool isValid = true;
        for (int peak in _peakTimes) {
          if ((i - peak).abs() < _MIN_PEAK_DISTANCE) {
            isValid = false;
            break;
          }
        }
        
        if (isValid) {
          _peakTimes.add(i);
          
          if (_peakTimes.length > 2) {
            List<int> recentPeaks = _peakTimes.sublist(_peakTimes.length - 5);
            if (recentPeaks.length > 1) {
              int totalDistance = 0;
              for (int j = 1; j < recentPeaks.length; j++) {
                totalDistance += recentPeaks[j] - recentPeaks[j-1];
              }
              double avgDistance = totalDistance / (recentPeaks.length - 1);
              double bpm = (_SAMPLE_RATE * 60) / avgDistance;
              
              if (bpm > 40 && bpm < 200) {
                _currentBPM = bpm.round();
                _bpmHistory.add(_currentBPM.toDouble());
                
                if (_bpmHistory.length > 5) {
                  _bpmHistory.removeAt(0);
                }
                
                _averageBPM = _bpmHistory.reduce((a, b) => a + b) / _bpmHistory.length;
                _bpmController.add(_currentBPM);
                
                if (_currentBPM > 50 && _currentBPM < 150) {
                  _statusController.add(2);
                }
              }
            }
          }
          
          if (_peakTimes.length > 20) {
            _peakTimes.removeAt(0);
          }
        }
      }
    }
  }

  // ============================================================
  📊 حساب جودة الإشارة
  // ============================================================
  double _calculateSignalQuality() {
    if (_filteredSignal.length < 20) return 0.0;
    
    List<double> recentSignal = _filteredSignal.sublist(_filteredSignal.length - 20);
    double mean = recentSignal.reduce((a, b) => a + b) / recentSignal.length;
    double variance = recentSignal.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / recentSignal.length;
    double std = sqrt(variance);
    
    double snr = std / (mean + 0.001);
    return snr.clamp(0.0, 1.0);
  }

  // ============================================================
  💨 حساب تشبع الأوكسجين
  // ============================================================
  void _calculateOxygenSaturation() {
    if (_bpmHistory.isNotEmpty && _bpmHistory.length > 3) {
      double avgBPM = _bpmHistory.reduce((a, b) => a + b) / _bpmHistory.length;
      double spo2 = 100.0 - (avgBPM - 60) * 0.1;
      _oxygenSaturation = spo2.clamp(90.0, 100.0);
      _oxygenController.add(_oxygenSaturation);
    }
  }

  // ============================================================
  💾 حفظ القياس
  // ============================================================
  Future<void> _saveMeasurement() async {
    try {
      final db = await database;
      int duration = _startTime != null 
          ? DateTime.now().difference(_startTime!).inSeconds 
          : 0;
      
      await db.insert('heart_rate_measurements', {
        'bpm': _currentBPM,
        'oxygen': _oxygenSaturation,
        'signal_quality': _signalQuality,
        'avg_bpm': _averageBPM,
        'duration': duration,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_bpm', _currentBPM);
      await prefs.setDouble('last_oxygen', _oxygenSaturation);
      await prefs.setInt('last_measurement_time', DateTime.now().millisecondsSinceEpoch);
      
    } catch (e) {
      debugPrint('Warning خطأ في حفظ القياس: $e');
    }
  }

  // ============================================================
  📊 الحصول على الإحصائيات
  // ============================================================
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> measurements = await db.query(
        'heart_rate_measurements',
        orderBy: 'timestamp DESC',
        limit: 20,
      );
      
      if (measurements.isEmpty) {
        return {
          'avg_bpm': 0,
          'avg_oxygen': 0,
          'max_bpm': 0,
          'min_bpm': 0,
          'count': 0,
          'avg_quality': 0,
        };
      }
      
      int totalBPM = 0;
      int totalOxygen = 0;
      int maxBPM = 0;
      int minBPM = 200;
      double totalQuality = 0;
      
      for (var m in measurements) {
        int bpm = m['bpm'] as int;
        totalBPM += bpm;
        totalOxygen += (m['oxygen'] as double).round();
        totalQuality += m['signal_quality'] as double;
        if (bpm > maxBPM) maxBPM = bpm;
        if (bpm < minBPM) minBPM = bpm;
      }
      
      return {
        'avg_bpm': totalBPM / measurements.length,
        'avg_oxygen': totalOxygen / measurements.length,
        'max_bpm': maxBPM,
        'min_bpm': minBPM,
        'count': measurements.length,
        'avg_quality': totalQuality / measurements.length,
      };
      
    } catch (e) {
      debugPrint('Warning خطأ في جلب الإحصائيات: $e');
      return {};
    }
  }

  // ============================================================
  ⏰ خدمة الخلفية
  // ============================================================
  void _startForegroundService() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Heart Rate قياس نبضات القلب',
      notificationText: 'جاري قياس نبضات قلبك...',
      notificationIcon: 'ic_launcher',
    );
  }

  void _stopForegroundService() {
    FlutterForegroundTask.stopService();
  }

  // ============================================================
  🧹 التنظيف
  // ============================================================
  void dispose() {
    _bpmController.close();
    _signalController.close();
    _oxygenController.close();
    _waveformController.close();
    _statusController.close();
    _cameraController?.dispose();
  }
}
*/
