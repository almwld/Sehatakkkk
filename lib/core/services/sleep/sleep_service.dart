import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/sleep/sleep_model.dart';
import 'package:sehatak/core/services/health_metrics_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepService {
  SleepService._();
  static final SleepService instance = SleepService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isTracking = false;
  String? _trackingUid;
  DateTime? _sleepStartTime;
  Timer? _trackingTimer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  int _movementCount = 0;
  double _avgHeartRate = 0;
  final List<double> _heartRates = [];
  final StreamController<SleepSnapshot> _updates = StreamController<SleepSnapshot>.broadcast();

  Stream<SleepSnapshot> get updates => _updates.stream;
  bool get isTracking => _isTracking;
  DateTime? get sleepStartTime => _sleepStartTime;

  Future<bool> restoreTracking() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    if (_isTracking && _trackingUid == uid) return true;
    if (_isTracking && _trackingUid != uid) {
      await _accelerometerSubscription?.cancel();
      _trackingTimer?.cancel();
      _isTracking = false;
      _sleepStartTime = null;
      _trackingUid = null;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sleep_${uid}_tracking_start');
    if (raw == null) return false;
    final start = DateTime.tryParse(raw);
    if (start == null) {
      await prefs.remove('sleep_${_trackingUid}_tracking_start');
      return false;
    }
    _sleepStartTime = start;
    _trackingUid = uid;
    _isTracking = true;
    _startSensors();
    _startTimer();
    _emit();
    return true;
  }

  Future<void> startSleepTracking() async {
    if (_isTracking) return;
    _sleepStartTime = DateTime.now();
    _trackingUid = _auth.currentUser?.uid;
    if (_trackingUid == null) return;
    _movementCount = 0;
    _heartRates.clear();
    _avgHeartRate = 0;
    _isTracking = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_${_trackingUid}_tracking_start', _sleepStartTime!.toIso8601String());
    _startSensors();
    _startTimer();
    _emit();
  }

  void _startTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (_) => _persistLive());
  }

  void _startSensors() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final movement = event.x.abs() + event.y.abs() + event.z.abs();
      if (movement > 18) _movementCount++;
      _emit();
    }, onError: (_) {});
  }

  Future<SleepRecord?> stopSleepTracking() async {
    if (!_isTracking || _sleepStartTime == null) return null;
    final endTime = DateTime.now();
    final duration = endTime.difference(_sleepStartTime!).inMinutes;
    _isTracking = false;
    _trackingTimer?.cancel();
    await _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sleep_tracking_start');

    final quality = _calculateSleepQuality(duration);
    final record = SleepRecord(
      id: _firestore.collection('sleep_records').doc().id,
      userId: _trackingUid ?? _auth.currentUser?.uid ?? '',
      date: DateTime.now(),
      bedtime: _sleepStartTime!,
      wakeTime: endTime,
      durationMinutes: duration,
      deepSleepMinutes: (duration * .22).toInt(),
      lightSleepMinutes: (duration * .52).toInt(),
      remSleepMinutes: (duration * .22).toInt(),
      awakeMinutes: _movementCount,
      quality: quality,
      heartRate: _avgHeartRate,
      notes: _notes(quality),
      createdAt: DateTime.now(),
    );
    if (record.userId.isNotEmpty) {
      await _firestore.collection('sleep_records').doc(record.id).set(record.toFirestore());
      await _firestore.collection('health_metrics').doc(record.userId).set({'sleep': duration / 60.0,'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      try { await HealthMetricsService.update({'sleep': duration / 60.0}); } catch (_) {}
    }
    _sleepStartTime = null;
    _trackingUid = null;
    _emit();
    return record;
  }

  Future<SleepRecord?> getTodaySleepRecord() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final start = DateTime.now();
      final day = DateTime(start.year, start.month, start.day);
      final snap = await _firestore.collection('sleep_records')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: day.toIso8601String())
          .orderBy('date', descending: true).limit(1).get();
      if (snap.docs.isEmpty) return null;
      return SleepRecord.fromFirestore(snap.docs.first.data(), snap.docs.first.id);
    } catch (_) {
      return null;
    }
  }

  Future<List<SleepRecord>> getWeeklySleepRecords() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      final since = DateTime.now().subtract(const Duration(days: 7));
      final snap = await _firestore.collection('sleep_records')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: since.toIso8601String())
          .orderBy('date', descending: true).get();
      return snap.docs.map((d) => SleepRecord.fromFirestore(d.data(), d.id)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getSleepStats() async {
    final records = await getWeeklySleepRecords();
    if (records.isEmpty) return {'avgDuration': 0, 'avgEfficiency': 0, 'totalHours': 0, 'bestDay': '', 'avgQuality': 'جيد'};
    final avgDuration = records.fold<int>(0, (sum, r) => sum + r.durationMinutes) / records.length;
    final avgEfficiency = records.fold<double>(0, (sum, r) => sum + r.sleepEfficiency) / records.length;
    final totalHours = records.fold<int>(0, (sum, r) => sum + r.durationMinutes) / 60;
    final best = records.reduce((a, b) => a.sleepEfficiency > b.sleepEfficiency ? a : b);
    return {
      'avgDuration': avgDuration.toInt(),
      'avgEfficiency': avgEfficiency,
      'totalHours': totalHours,
      'bestDay': best.date.day.toString() + '/' + best.date.month.toString(),
      'avgQuality': _getAverageQuality(records),
    };
  }

  Future<void> _persistLive() async {
    if (!_isTracking || _sleepStartTime == null || _trackingUid == null) return;
    final minutes = DateTime.now().difference(_sleepStartTime!).inMinutes;
    await _firestore.collection('health_metrics').doc(_trackingUid!).set({
      'sleep': minutes / 60.0,
      'sleepTrackingActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _emit();
  }

  void _emit() {
    if (!_updates.isClosed) {
      final minutes = _sleepStartTime == null ? 0 : DateTime.now().difference(_sleepStartTime!).inSeconds;
      _updates.add(SleepSnapshot(isTracking: _isTracking, elapsedSeconds: minutes));
    }
  }

  SleepQuality _calculateSleepQuality(int duration) {
    if (duration >= 480 && _movementCount < 10) return SleepQuality.excellent;
    if (duration >= 420 && _movementCount < 20) return SleepQuality.good;
    if (duration >= 360 && _movementCount < 30) return SleepQuality.fair;
    return SleepQuality.poor;
  }

  String _notes(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.excellent: return 'نوم ممتاز! استمر على هذا النمط الصحي.';
      case SleepQuality.good: return 'نوم جيد، حاول زيادة ساعة إضافية للحصول على نوم ممتاز.';
      case SleepQuality.fair: return 'نوم مقبول، حاول النوم مبكراً وتجنب المنبهات قبل النوم.';
      case SleepQuality.poor: return 'نوم غير كافٍ، حاول تحسين عادات النوم.';
    }
  }

  String _getAverageQuality(List<SleepRecord> records) {
    final avg = records.fold(0, (sum, r) => sum + r.quality.index) / records.length;
    if (avg < .5) return 'ممتاز';
    if (avg < 1.5) return 'جيد';
    if (avg < 2.5) return 'مقبول';
    return 'سيئ';
  }
}

class SleepSnapshot {
  final bool isTracking;
  final int elapsedSeconds;
  const SleepSnapshot({required this.isTracking, required this.elapsedSeconds});
}
