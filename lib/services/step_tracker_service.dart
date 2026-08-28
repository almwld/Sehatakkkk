/*
// ============================================================
// 📁 lib/services/step_tracker_service.dart
// 🚶 خدمة تتبع الخطوات والمشي
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class StepTrackerService {
  static final StepTrackerService _instance = StepTrackerService._internal();
  factory StepTrackerService() => _instance;
  StepTrackerService._internal();

  Database? _database;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _periodicTimer;
  final StreamController<int> _stepController = StreamController<int>.broadcast();

  // ✅ بيانات الخطوات
  int _stepCount = 0;
  int _todaySteps = 0;
  double _distance = 0.0;
  int _calories = 0;
  double _speed = 0.0;
  int _stepGoal = 10000;

  // ✅ بيانات الحركة
  List<double> _accelerometerData = [];
  bool _isWalking = false;
  DateTime? _walkStartTime;
  double _lastMagnitude = 0.0;

  // ✅ Stream للخطوات
  Stream<int> get stepStream => _stepController.stream;

  // ============================================================
  // 🗄️ تهيئة قاعدة البيانات
  // ============================================================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'step_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_steps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        steps INTEGER,
        distance REAL,
        calories INTEGER,
        duration INTEGER,
        avg_speed REAL,
        max_speed REAL,
        timestamp INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE hourly_steps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        hour INTEGER,
        steps INTEGER,
        timestamp INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE daily_steps ADD COLUMN max_speed REAL');
    }
  }

  // ============================================================
  📊 بدء تتبع الخطوات
  // ============================================================

  Future<void> startStepTracking() async {
    try {
      // ✅ طلب الأذونات
      if (!await Permission.sensors.isGranted) {
        await Permission.sensors.request();
      }
      if (!await Permission.activityRecognition.isGranted) {
        await Permission.activityRecognition.request();
      }

      // ✅ بدء الاستماع للحساسات
      _accelerometerSubscription = accelerometerEvents.listen(_processAccelerometer);

      // ✅ تحميل بيانات اليوم
      await _loadTodayData();

      // ✅ بدء التتبع الدوري
      _startPeriodicTracking();

      print('🚶 بدأ تتبع الخطوات');

    } catch (e) {
      print('❌ خطأ في بدء تتبع الخطوات: $e');
    }
  }

  // ============================================================
  📈 معالجة بيانات التسارع
  // ============================================================

  void _processAccelerometer(AccelerometerEvent event) {
    // ✅ حساب مقدار الحركة
    double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    // ✅ إضافة البيانات للتحليل
    _accelerometerData.add(magnitude);
    if (_accelerometerData.length > 100) {
      _accelerometerData.removeAt(0);
    }

    // ✅ كشف المشي
    _detectWalking(magnitude);

    // ✅ تحديث السرعة
    if (_isWalking && _walkStartTime != null) {
      Duration walkDuration = DateTime.now().difference(_walkStartTime!);
      if (walkDuration.inSeconds > 0) {
        _speed = (_distance / (walkDuration.inSeconds / 3600.0)).clamp(0.0, 10.0);
      }
    }

    _lastMagnitude = magnitude;
  }

  // ============================================================
  🚶 خوارزمية اكتشاف الخطوات
  // ============================================================

  void _detectWalking(double magnitude) {
    double stepThreshold = 1.2;

    // ✅ التحقق من وجود حركة كافية
    if (magnitude > stepThreshold) {
      // ✅ استخدام خوارزمية الذروة
      if (_accelerometerData.length >= 3) {
        double prev = _accelerometerData[_accelerometerData.length - 3];
        double current = _accelerometerData[_accelerometerData.length - 2];
        double next = _accelerometerData[_accelerometerData.length - 1];

        // ✅ الكشف عن الذروة (الخطوة)
        if (current > prev && current > next && current > stepThreshold) {
          _addStep();
        }
      }
    }

    // ✅ تحديث حالة المشي
    bool wasWalking = _isWalking;
    _isWalking = magnitude > 0.8;

    if (_isWalking && !wasWalking) {
      _walkStartTime = DateTime.now();
    }
  }

  // ============================================================
  ➕ إضافة خطوة
  // ============================================================

  void _addStep() {
    _stepCount++;
    _todaySteps++;

    // ✅ حساب المسافة (متوسط طول الخطوة 0.76 متر)
    _distance += 0.00076; // كيلومتر

    // ✅ حساب السعرات الحرارية
    _calories += 1;

    // ✅ إرسال التحديث
    _stepController.add(_todaySteps);

    // ✅ حفظ البيانات دورياً
    if (_stepCount % 10 == 0) {
      _saveCurrentData();
    }
  }

  // ============================================================
  💾 حفظ البيانات
  // ============================================================

  Future<void> _saveCurrentData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    await prefs.setInt('today_steps', _todaySteps);
    await prefs.setDouble('today_distance', _distance);
    await prefs.setInt('today_calories', _calories);
    await prefs.setString('today_date', today);
  }

  Future<void> _loadTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final savedDate = prefs.getString('today_date') ?? '';

    if (savedDate == today) {
      _todaySteps = prefs.getInt('today_steps') ?? 0;
      _distance = prefs.getDouble('today_distance') ?? 0.0;
      _calories = prefs.getInt('today_calories') ?? 0;
    } else {
      await saveDailyData();
      _todaySteps = 0;
      _distance = 0.0;
      _calories = 0;
      await prefs.setString('today_date', today);
    }
  }

  Future<void> saveDailyData() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    List<Map<String, dynamic>> existing = await db.query(
      'daily_steps',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'daily_steps',
        {
          'steps': _todaySteps,
          'distance': _distance,
          'calories': _calories,
          'duration': _calculateWalkDuration(),
          'avg_speed': _speed,
          'max_speed': _speed,
          'timestamp': now.millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      await db.insert('daily_steps', {
        'date': today,
        'steps': _todaySteps,
        'distance': _distance,
        'calories': _calories,
        'duration': _calculateWalkDuration(),
        'avg_speed': _speed,
        'max_speed': _speed,
        'timestamp': now.millisecondsSinceEpoch,
      });
    }
  }

  int _calculateWalkDuration() {
    if (_walkStartTime == null) return 0;
    return DateTime.now().difference(_walkStartTime!).inSeconds;
  }

  // ============================================================
  🔄 التتبع الدوري
  // ============================================================

  void _startPeriodicTracking() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveCurrentData();
    });
  }

  // ============================================================
  📊 الحصول على البيانات
  // ============================================================

  Future<List<Map<String, dynamic>>> getWeeklySteps() async {
    final db = await database;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekAgoStr = DateFormat('yyyy-MM-dd').format(weekAgo);

    return await db.query(
      'daily_steps',
      where: 'date >= ?',
      whereArgs: [weekAgoStr],
      orderBy: 'date ASC',
    );
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final weekly = await getWeeklySteps();

    int weeklyTotal = weekly.fold(0, (sum, item) => sum + (item['steps'] as int));
    double weeklyAvg = weekly.isNotEmpty ? weeklyTotal / weekly.length : 0;

    int bestDaySteps = weekly.isNotEmpty ? weekly.map((e) => e['steps'] as int).reduce(max) : 0;
    String bestDay = weekly.isNotEmpty ? weekly.firstWhere(
      (e) => e['steps'] == bestDaySteps,
      orElse: () => {'date': '--'},
    )['date'] : '--';

    return {
      'weekly_total': weeklyTotal,
      'weekly_avg': weeklyAvg,
      'best_day_steps': bestDaySteps,
      'best_day': bestDay,
      'today_steps': _todaySteps,
      'today_distance': _distance,
      'today_calories': _calories,
      'step_goal': _stepGoal,
    };
  }

  int get todaySteps => _todaySteps;
  double get distance => _distance;
  int get calories => _calories;
  double get speed => _speed;

  // ============================================================
  🛑 إيقاف التتبع
  // ============================================================

  void stopTracking() {
    _accelerometerSubscription?.cancel();
    _periodicTimer?.cancel();
    _stepController.close();
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _periodicTimer?.cancel();
    _stepController.close();
  }
}
*/
