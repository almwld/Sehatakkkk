import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/models/steps/steps_model.dart';

class StepsService {
  StepsService._();
  static final StepsService instance = StepsService._();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isTracking = false;
  int _todaySteps = 0, _calories = 0, _activeMinutes = 0;
  double _distance = 0;
  List<int> _hourlySteps = List.filled(24, 0);
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _saveTimer;
  int? _lastSensorSteps;
  final StreamController<StepsSnapshot> _updates = StreamController<StepsSnapshot>.broadcast();

  Stream<StepsSnapshot> get updates => _updates.stream;
  bool get isTracking => _isTracking;
  int get currentSteps => _todaySteps;

  Future<bool> requestPermissions() async =>
      (await Permission.activityRecognition.request()).isGranted;

  Future<bool> startTracking() async {
    if (_isTracking) return true;
    if (!await requestPermissions()) return false;
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(DateTime.now());
    if (prefs.getString('steps_tracking_day') != key) {
      _todaySteps = 0;
      _calories = 0;
      _distance = 0;
      _hourlySteps = List.filled(24, 0);
      await prefs.setString('steps_tracking_day', key);
    } else {
      _todaySteps = prefs.getInt('steps_today') ?? await getTodaySteps();
      _calories = prefs.getInt('steps_calories') ?? (_todaySteps * 0.04).round();
      _distance = prefs.getDouble('steps_distance') ?? (_todaySteps * 0.8);
    }
    _isTracking = true;
    await _startSensorTracking();
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 10), (_) => _persist());
    _emit();
    return true;
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;
    _isTracking = false;
    _saveTimer?.cancel();
    await _persist();
    await _stopSensorTracking();
  }

  Future<int> getTodaySteps() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;
      final snap = await _firestore.collection('steps_records')
          .where('userId', isEqualTo: user.uid)
          .where('dateKey', isEqualTo: _dateKey(DateTime.now()))
          .limit(1).get();
      if (snap.docs.isEmpty) return 0;
      return StepRecord.fromFirestore(snap.docs.first.data(), snap.docs.first.id).steps;
    } catch (_) {
      return 0;
    }
  }

  Future<List<StepRecord>> getWeeklySteps() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      final since = DateTime.now().subtract(const Duration(days: 7));
      final snap = await _firestore.collection('steps_records')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: since.toIso8601String())
          .orderBy('date', descending: true).get();
      return snap.docs.map((d) => StepRecord.fromFirestore(d.data(), d.id)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getStepsStats() async {
    final records = await getWeeklySteps();
    if (records.isEmpty) {
      return {'avgSteps': 0, 'totalSteps': 0, 'bestDay': '', 'totalDistance': 0, 'totalCalories': 0};
    }
    final total = records.fold<int>(0, (s, r) => s + r.steps);
    final best = records.reduce((a, b) => a.steps > b.steps ? a : b);
    return {
      'avgSteps': total ~/ records.length,
      'totalSteps': total,
      'bestDay': best.date.day.toString() + '/' + best.date.month.toString(),
      'totalDistance': records.fold<double>(0, (s, r) => s + r.distance) / 1000,
      'totalCalories': records.fold<int>(0, (s, r) => s + r.calories),
    };
  }

  Future<void> _startSensorTracking() async {
    await _stepCountSubscription?.cancel();
    _lastSensorSteps = null;
    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen((event) {
        final previous = _lastSensorSteps;
        _lastSensorSteps = event.steps;
        if (previous == null) return;
        final delta = event.steps - previous;
        if (delta > 0 && delta < 100) _addSteps(delta);
      }, onError: (_) => _startFallbackTracking(), cancelOnError: true);
      _pedestrianStatusSubscription =
          Pedometer.pedestrianStatusStream.listen((_) {}, onError: (_) {});
    } catch (_) {
      _startFallbackTracking();
    }
  }

  void _startFallbackTracking() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 12 && magnitude < 20) _addSteps(1);
    });
  }

  void _addSteps(int delta) {
    if (!_isTracking || delta <= 0) return;
    _todaySteps += delta;
    _calories = (_todaySteps * 0.04).round();
    _distance = _todaySteps * 0.8;
    _activeMinutes = (_todaySteps / 100).floor();
    _hourlySteps[DateTime.now().hour] += delta;
    _emit();
  }

  Future<void> _stopSensorTracking() async {
    await _stepCountSubscription?.cancel();
    await _pedestrianStatusSubscription?.cancel();
    await _accelerometerSubscription?.cancel();
    _stepCountSubscription = null;
    _pedestrianStatusSubscription = null;
    _accelerometerSubscription = null;
  }

  Future<void> _persist() async {
    if (_auth.currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(DateTime.now());
    await prefs.setString('steps_tracking_day', key);
    await prefs.setInt('steps_today', _todaySteps);
    await prefs.setInt('steps_calories', _calories);
    await prefs.setDouble('steps_distance', _distance);
    final user = _auth.currentUser!;
    final day = DateTime.now();
    final start = DateTime(day.year, day.month, day.day);
    final record = StepRecord(
      id: user.uid + '_' + key,
      userId: user.uid,
      date: start,
      steps: _todaySteps,
      distance: _distance,
      calories: _calories,
      activeMinutes: _activeMinutes,
      hourlySteps: _hourlySteps,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('steps_records').doc(record.id).set(
      {...record.toFirestore(), 'dateKey': key},
      SetOptions(merge: true),
    );
    await _firestore.collection('health_metrics').doc(user.uid).set({
      'steps': _todaySteps,
      'calories': _calories,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _emit() {
    if (!_updates.isClosed) {
      _updates.add(StepsSnapshot(
        steps: _todaySteps,
        calories: _calories,
        distance: _distance,
        activeMinutes: _activeMinutes,
      ));
    }
  }

  String _dateKey(DateTime d) =>
      d.year.toString().padLeft(4, '0') + '-' +
      d.month.toString().padLeft(2, '0') + '-' +
      d.day.toString().padLeft(2, '0');
}

class StepsSnapshot {
  final int steps;
  final int calories;
  final double distance;
  final int activeMinutes;
  const StepsSnapshot({
    required this.steps,
    required this.calories,
    required this.distance,
    required this.activeMinutes,
  });
}
