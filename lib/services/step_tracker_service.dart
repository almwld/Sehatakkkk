import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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

  int _todaySteps = 0;
  double _distance = 0;
  double _calories = 0;
  double _speed = 0;
  int _stepGoal = 10000;
  final List<double> _accelerometerData = <double>[];
  DateTime? _walkStartTime;
  DateTime? _lastStepTime;

  Stream<int> get stepStream => _stepController.stream;
  int get todaySteps => _todaySteps;
  double get distance => _distance;
  double get calories => _calories;
  double get speed => _speed;
  int get stepGoal => _stepGoal;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'step_tracker.db'),
      version: 2,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE daily_steps(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT UNIQUE,steps INTEGER,distance REAL,calories REAL,duration INTEGER,avg_speed REAL,max_speed REAL,timestamp INTEGER)');
        await db.execute('CREATE TABLE hourly_steps(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,hour INTEGER,steps INTEGER,timestamp INTEGER)');
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) await db.execute('ALTER TABLE daily_steps ADD COLUMN max_speed REAL');
      },
    );
    return _database!;
  }

  Future<bool> startStepTracking() async {
    final sensors = await Permission.sensors.request();
    final activity = await Permission.activityRecognition.request();
    if (!sensors.isGranted && !activity.isGranted) return false;
    await _loadTodayData();
    await _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen(_processAccelerometer);
    _startPeriodicTracking();
    return true;
  }

  void _processAccelerometer(AccelerometerEvent event) {
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    _accelerometerData.add(magnitude);
    if (_accelerometerData.length > 12) _accelerometerData.removeAt(0);
    if (_accelerometerData.length >= 3) {
      final a = _accelerometerData[_accelerometerData.length - 3];
      final b = _accelerometerData[_accelerometerData.length - 2];
      final c = _accelerometerData[_accelerometerData.length - 1];
      final now = DateTime.now();
      final enoughTime = _lastStepTime == null || now.difference(_lastStepTime!).inMilliseconds >= 300;
      if (b > a && b >= c && b > 11.0 && enoughTime) _addStep(now);
    }
    if (magnitude > 10.3 && _walkStartTime == null) _walkStartTime = DateTime.now();
    if (magnitude <= 10.1 && _walkStartTime != null) {
      final seconds = DateTime.now().difference(_walkStartTime!).inSeconds;
      if (seconds > 0) _speed = (_distance / (seconds / 3600)).clamp(0, 12).toDouble();
      _walkStartTime = null;
    }
  }

  void _addStep(DateTime now) {
    _lastStepTime = now;
    _todaySteps++;
    _distance = _todaySteps * 0.00076;
    _calories = _todaySteps * 0.04;
    _stepController.add(_todaySteps);
    if (_todaySteps % 10 == 0) unawaited(saveDailyData());
  }

  Future<void> _loadTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (prefs.getString('today_date') == today) {
      _todaySteps = prefs.getInt('today_steps') ?? 0;
      _distance = prefs.getDouble('today_distance') ?? _todaySteps * 0.00076;
      _calories = prefs.getDouble('today_calories') ?? _todaySteps * 0.04;
    } else {
      _todaySteps = 0; _distance = 0; _calories = 0; _speed = 0;
      await prefs.setString('today_date', today);
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('today_date', DateFormat('yyyy-MM-dd').format(DateTime.now()));
    await prefs.setInt('today_steps', _todaySteps);
    await prefs.setDouble('today_distance', _distance);
    await prefs.setDouble('today_calories', _calories);
  }

  Future<void> saveDailyData() async {
    await _savePrefs();
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final duration = _walkStartTime == null ? 0 : DateTime.now().difference(_walkStartTime!).inSeconds;
    await db.insert('daily_steps', {
      'date': today, 'steps': _todaySteps, 'distance': _distance, 'calories': _calories,
      'duration': duration, 'avg_speed': _speed, 'max_speed': _speed,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  void _startPeriodicTracking() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) => saveDailyData());
  }

  Future<List<Map<String, dynamic>>> getWeeklySteps() async {
    final db = await database;
    final from = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 6)));
    return db.query('daily_steps', where: 'date >= ?', whereArgs: [from], orderBy: 'date ASC');
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final weekly = await getWeeklySteps();
    final total = weekly.fold<int>(0, (sum, e) => sum + ((e['steps'] as num?)?.toInt() ?? 0));
    final best = weekly.isEmpty ? 0 : weekly.map((e) => (e['steps'] as num?)?.toInt() ?? 0).reduce(max);
    return {'weekly_total': total, 'weekly_avg': weekly.isEmpty ? 0.0 : total / weekly.length, 'best_day_steps': best, 'today_steps': _todaySteps, 'today_distance': _distance, 'today_calories': _calories, 'step_goal': _stepGoal};
  }

  Future<void> setStepGoal(int goal) async { if (goal > 0) _stepGoal = goal; }

  Future<void> stopTracking() async {
    await _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await saveDailyData();
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _periodicTimer?.cancel();
    _stepController.close();
  }
}
