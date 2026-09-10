import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unified step-tracking data source.
///
/// Data is persisted in SharedPreferences. The sensor loop may run from the
/// foreground UI or from the Android foreground-service isolate; both write to
/// the same daily/weekly SharedPreferences records.
class StepTrackerService {
  static final StepTrackerService _instance = StepTrackerService._internal();
  factory StepTrackerService() => _instance;
  StepTrackerService._internal();

  static const int defaultGoal = 10000;
  static const double averageStepKm = 0.00076;
  static const double caloriesPerStep = 0.04;

  final StreamController<int> _stepController = StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepController.stream;

  int _todaySteps = 0;
  double _distance = 0;
  double _calories = 0;
  double _speed = 0;
  int _stepGoal = defaultGoal;
  DateTime? _walkStartTime;
  DateTime? _lastStepTime;

  int get todaySteps => _todaySteps;
  double get distance => _distance;
  double get calories => _calories;
  double get speed => _speed;
  int get stepGoal => _stepGoal;

  Future<void> loadToday() async {
    final prefs = await SharedPreferences.getInstance();
    await loadFromPrefs(prefs);
  }

  Future<void> loadFromPrefs(SharedPreferences prefs) async {
    final today = _dateKey(DateTime.now());
    final storedDate = prefs.getString('steps.today.date');
    if (storedDate != today) {
      _todaySteps = 0;
      _distance = 0;
      _calories = 0;
      _speed = 0;
      await prefs.setString('steps.today.date', today);
      await _saveDay(prefs, today, 0);
    } else {
      _todaySteps = prefs.getInt('steps.today.count') ?? 0;
      _distance = prefs.getDouble('steps.today.distance') ?? _todaySteps * averageStepKm;
      _calories = prefs.getDouble('steps.today.calories') ?? _todaySteps * caloriesPerStep;
    }
    _stepGoal = prefs.getInt('steps.goal') ?? defaultGoal;
  }

  /// Adds a step after the caller's motion algorithm has accepted it.
  Future<void> addStep({DateTime? timestamp, SharedPreferences? prefs}) async {
    final now = timestamp ?? DateTime.now();
    final store = prefs ?? await SharedPreferences.getInstance();
    final today = _dateKey(now);
    if (store.getString('steps.today.date') != today) {
      _todaySteps = 0;
      _distance = 0;
      _calories = 0;
      _speed = 0;
      await store.setString('steps.today.date', today);
    }
    _todaySteps++;
    _distance = _todaySteps * averageStepKm;
    _calories = _todaySteps * caloriesPerStep;
    _lastStepTime = now;
    await store.setInt('steps.today.count', _todaySteps);
    await store.setDouble('steps.today.distance', _distance);
    await store.setDouble('steps.today.calories', _calories);
    await _saveDay(store, today, _todaySteps);
    _stepController.add(_todaySteps);
  }

  void updateWalkingSpeed(double magnitude) {
    final now = DateTime.now();
    if (magnitude > 10.3 && _walkStartTime == null) {
      _walkStartTime = now;
      return;
    }
    if (magnitude <= 10.1 && _walkStartTime != null) {
      final seconds = now.difference(_walkStartTime!).inMilliseconds / 1000;
      if (seconds > 0) {
        _speed = (_distance / (seconds / 3600)).clamp(0.0, 12.0).toDouble();
      }
      _walkStartTime = null;
    }
  }

  Future<void> setStepGoal(int goal) async {
    if (goal <= 0) return;
    _stepGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps.goal', goal);
  }

  Future<bool> requestPermissions() async {
    final activity = await Permission.activityRecognition.request();
    final sensors = await Permission.sensors.request();
    return activity.isGranted || sensors.isGranted;
  }

  Future<void> saveDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    await _persistCurrent(prefs);
  }

  Future<void> _persistCurrent(SharedPreferences prefs) async {
    final today = _dateKey(DateTime.now());
    await prefs.setString('steps.today.date', today);
    await prefs.setInt('steps.today.count', _todaySteps);
    await prefs.setDouble('steps.today.distance', _distance);
    await prefs.setDouble('steps.today.calories', _calories);
    await prefs.setInt('steps.goal', _stepGoal);
    await _saveDay(prefs, today, _todaySteps);
  }

  Future<void> _saveDay(SharedPreferences prefs, String date, int steps) async {
    final map = _readHistory(prefs);
    map[date] = steps;
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    map.removeWhere((key, value) {
      final dateValue = DateTime.tryParse(key);
      return dateValue != null && dateValue.isBefore(cutoff);
    });
    await prefs.setString('steps.history.v1', jsonEncode(map));
  }

  Map<String, int> _readHistory(SharedPreferences prefs) {
    final raw = prefs.getString('steps.history.v1');
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, int>{};
      return decoded.map<String, int>((key, value) => MapEntry(key.toString(), (value as num).toInt()));
    } catch (_) {
      return <String, int>{};
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final history = _readHistory(prefs);
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
      final key = _dateKey(date);
      return <String, dynamic>{'date': key, 'steps': history[key] ?? 0};
    });
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final weekly = await getWeeklySteps();
    final total = weekly.fold<int>(0, (sum, item) => sum + (item['steps'] as int));
    final best = weekly.isEmpty ? 0 : weekly.map((item) => item['steps'] as int).reduce(max);
    return <String, dynamic>{
      'weekly_total': total,
      'weekly_avg': total / 7,
      'best_day_steps': best,
      'today_steps': _todaySteps,
      'today_distance': _distance,
      'today_calories': _calories,
      'step_goal': _stepGoal,
    };
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void dispose() => _stepController.close();
}
