import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/sleep/sleep_model.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class SleepService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ متغيرات تتبع النوم
  bool _isTracking = false;
  Timer? _trackingTimer;
  DateTime? _sleepStartTime;
  int _movementCount = 0;
  int _soundCount = 0;
  double _avgHeartRate = 0;
  List<double> _heartRates = [];

  // ✅ بدء تتبع النوم
  Future<void> startSleepTracking() async {
    if (_isTracking) return;
    
    _isTracking = true;
    _sleepStartTime = DateTime.now();
    _movementCount = 0;
    _soundCount = 0;
    _heartRates.clear();
    
    // ✅ بدء تتبع المستشعرات
    _startSensorTracking();
    
    // ✅ تحديث كل دقيقة
    _trackingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateSleepData();
    });
  }

  // ✅ إيقاف تتبع النوم
  Future<SleepRecord?> stopSleepTracking() async {
    if (!_isTracking) return null;
    
    _isTracking = false;
    _trackingTimer?.cancel();
    _stopSensorTracking();
    
    final endTime = DateTime.now();
    final duration = endTime.difference(_sleepStartTime!).inMinutes;
    
    // ✅ حساب جودة النوم
    final quality = _calculateSleepQuality(duration);
    final deepSleep = _calculateDeepSleep(duration);
    final lightSleep = _calculateLightSleep(duration);
    final remSleep = _calculateRemSleep(duration);
    
    final record = SleepRecord(
      id: _firestore.collection('sleep_records').doc().id,
      userId: _auth.currentUser?.uid ?? '',
      date: DateTime.now(),
      bedtime: _sleepStartTime!,
      wakeTime: endTime,
      durationMinutes: duration,
      deepSleepMinutes: deepSleep,
      lightSleepMinutes: lightSleep,
      remSleepMinutes: remSleep,
      awakeMinutes: _movementCount,
      quality: quality,
      heartRate: _avgHeartRate,
      notes: _generateSleepNotes(quality),
      createdAt: DateTime.now(),
    );
    
    // ✅ حفظ في Firebase
    await _firestore
        .collection('sleep_records')
        .doc(record.id)
        .set(record.toFirestore());
    
    return record;
  }

  // ✅ جلب سجل النوم اليوم
  Future<SleepRecord?> getTodaySleepRecord() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final snap = await _firestore
          .collection('sleep_records')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      
      if (snap.docs.isNotEmpty) {
        return SleepRecord.fromFirestore(snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ جلب سجلات النوم للأسبوع
  Future<List<SleepRecord>> getWeeklySleepRecords() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final snap = await _firestore
          .collection('sleep_records')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: weekAgo.toIso8601String())
          .orderBy('date', descending: true)
          .get();
      
      return snap.docs.map((doc) {
        return SleepRecord.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ جلب إحصائيات النوم
  Future<Map<String, dynamic>> getSleepStats() async {
    final records = await getWeeklySleepRecords();
    if (records.isEmpty) {
      return {
        'avgDuration': 0,
        'avgEfficiency': 0,
        'totalHours': 0,
        'bestDay': '',
        'avgQuality': 'جيد',
      };
    }
    
    final avgDuration = records.fold(0, (sum, r) => sum + r.durationMinutes) / records.length;
    final avgEfficiency = records.fold(0.0, (sum, r) => sum + r.sleepEfficiency) / records.length;
    final totalHours = records.fold(0, (sum, r) => sum + r.durationMinutes) / 60;
    
    // ✅ أفضل يوم
    final bestDay = records.reduce((a, b) => a.sleepEfficiency > b.sleepEfficiency ? a : b);
    
    return {
      'avgDuration': avgDuration.toInt(),
      'avgEfficiency': avgEfficiency,
      'totalHours': totalHours,
      'bestDay': '${bestDay.date.day}/${bestDay.date.month}',
      'avgQuality': _getAverageQuality(records),
    };
  }

  // ============================================================
  // 🔧 دوال مساعدة (محاكاة - سيتم استبدالها بمستشعرات حقيقية)
  // ============================================================
  
  void _startSensorTracking() {
    // ✅ في الإصدار النهائي: استخدام مستشعرات الهاتف
    // accelerometerEvents.listen((event) { ... });
    // gyroscopeEvents.listen((event) { ... });
    // magnetometerEvents.listen((event) { ... });
  }

  void _stopSensorTracking() {
    // إيقاف المستشعرات
  }

  void _updateSleepData() {
    // ✅ محاكاة قراءات المستشعرات
    _movementCount += (DateTime.now().second % 5 == 0) ? 1 : 0;
    
    // ✅ محاكاة معدل النبض
    final heartRate = 60 + (DateTime.now().second % 20);
    _heartRates.add(heartRate.toDouble());
    _avgHeartRate = _heartRates.reduce((a, b) => a + b) / _heartRates.length;
  }

  SleepQuality _calculateSleepQuality(int duration) {
    // ✅ جودة النوم تعتمد على المدة والحركة
    if (duration >= 480 && _movementCount < 10) return SleepQuality.excellent; // 8+ ساعات
    if (duration >= 420 && _movementCount < 20) return SleepQuality.good;      // 7+ ساعات
    if (duration >= 360 && _movementCount < 30) return SleepQuality.fair;      // 6+ ساعات
    return SleepQuality.poor;
  }

  int _calculateDeepSleep(int duration) {
    // ✅ النوم العميق ~20-25% من إجمالي النوم
    return (duration * 0.22).toInt();
  }

  int _calculateLightSleep(int duration) {
    // ✅ النوم الخفيف ~50-55% من إجمالي النوم
    return (duration * 0.52).toInt();
  }

  int _calculateRemSleep(int duration) {
    // ✅ نوم الريم ~20-25% من إجمالي النوم
    return (duration * 0.22).toInt();
  }

  String _generateSleepNotes(SleepQuality quality) {
    switch (quality) {
      case SleepQuality.excellent:
        return 'نوم ممتاز! استمر على هذا النمط الصحي.';
      case SleepQuality.good:
        return 'نوم جيد، حاول زيادة ساعة إضافية للحصول على نوم ممتاز.';
      case SleepQuality.fair:
        return 'نوم مقبول، حاول النوم مبكراً وتجنب المنبهات قبل النوم.';
      case SleepQuality.poor:
        return 'نوم غير كافٍ، حاول تحسين عادات النوم.';
    }
  }

  String _getAverageQuality(List<SleepRecord> records) {
    final avg = records.fold(0, (sum, r) => sum + r.quality.index) / records.length;
    if (avg < 0.5) return 'ممتاز';
    if (avg < 1.5) return 'جيد';
    if (avg < 2.5) return 'مقبول';
    return 'سيئ';
  }
}
