import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:step_counter/step_counter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sehatak/core/models/steps/steps_model.dart';
import 'dart:async';

class StepsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // ✅ متغيرات عداد الخطوات
  bool _isTracking = false;
  int _currentSteps = 0;
  int _todaySteps = 0;
  int _calories = 0;
  double _distance = 0;
  int _activeMinutes = 0;
  List<int> _hourlySteps = List.filled(24, 0);
  Timer? _updateTimer;
  DateTime? _startTime;
  
  // ✅ مستشعرات الخطوات
  int _lastStepCount = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<StepCountEvent>? _stepCountSubscription;

  // ✅ طلب الإذن
  Future<bool> requestPermissions() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  // ✅ بدء تتبع الخطوات
  Future<void> startTracking() async {
    if (_isTracking) return;
    
    if (!await requestPermissions()) {
      throw Exception('يجب منح إذن الوصول إلى مستشعرات الحركة');
    }
    
    _isTracking = true;
    _startTime = DateTime.now();
    _currentSteps = 0;
    _todaySteps = await getTodaySteps();
    _hourlySteps = List.filled(24, 0);
    
    // ✅ بدء تتبع المستشعرات
    _startSensorTracking();
    
    // ✅ تحديث كل 10 ثواني
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateStepData();
    });
  }

  // ✅ إيقاف تتبع الخطوات
  Future<void> stopTracking() async {
    if (!_isTracking) return;
    
    _isTracking = false;
    _updateTimer?.cancel();
    _stopSensorTracking();
    
    // ✅ حفظ اليوم
    if (_todaySteps > 0) {
      await _saveTodayRecord();
    }
  }

  // ✅ جلب خطوات اليوم
  Future<int> getTodaySteps() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final snap = await _firestore
          .collection('steps_records')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: startOfDay.toIso8601String())
          .limit(1)
          .get();
      
      if (snap.docs.isNotEmpty) {
        final record = StepRecord.fromFirestore(snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
        return record.steps;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // ✅ جلب سجل الخطوات للأسبوع
  Future<List<StepRecord>> getWeeklySteps() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final snap = await _firestore
          .collection('steps_records')
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: weekAgo.toIso8601String())
          .orderBy('date', descending: true)
          .get();
      
      return snap.docs.map((doc) {
        return StepRecord.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ جلب إحصائيات الخطوات
  Future<Map<String, dynamic>> getStepsStats() async {
    final records = await getWeeklySteps();
    if (records.isEmpty) {
      return {
        'avgSteps': 0,
        'totalSteps': 0,
        'bestDay': '',
        'totalDistance': 0,
        'totalCalories': 0,
      };
    }
    
    final totalSteps = records.fold(0, (sum, r) => sum + r.steps);
    final avgSteps = totalSteps ~/ records.length;
    final totalDistance = records.fold(0.0, (sum, r) => sum + r.distance);
    final totalCalories = records.fold(0, (sum, r) => sum + r.calories);
    
    // ✅ أفضل يوم
    final bestDay = records.reduce((a, b) => a.steps > b.steps ? a : b);
    
    return {
      'avgSteps': avgSteps,
      'totalSteps': totalSteps,
      'bestDay': '${bestDay.date.day}/${bestDay.date.month}',
      'totalDistance': totalDistance / 1000, // كم
      'totalCalories': totalCalories,
    };
  }

  // ============================================================
  // 🔧 دوال المستشعرات
  // ============================================================
  
  void _startSensorTracking() {
    // ✅ استخدام مستشعر عداد الخطوات
    _stepCountSubscription = stepCounterEvents.listen((event) {
      if (event.count > _lastStepCount) {
        final newSteps = event.count - _lastStepCount;
        _currentSteps += newSteps;
        _todaySteps += newSteps;
        _lastStepCount = event.count;
        
        // ✅ تحديث السعرات
        _calories += (newSteps * 0.04).toInt(); // 0.04 سعرة لكل خطوة
        
        // ✅ تحديث المسافة
        _distance += newSteps * 0.0008; // 0.8 متر لكل خطوة
        
        // ✅ تحديث الدقائق النشطة
        _activeMinutes = (_todaySteps / 100).toInt();
        
        // ✅ تحديث الخطوات لكل ساعة
        final hour = DateTime.now().hour;
        if (hour < 24) {
          _hourlySteps[hour] += newSteps;
        }
      }
    });
    
    // ✅ استخدام الـ Accelerometer كبديل
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      // ✅ تحليل حركة المستخدم
      final acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z
      );
      
      // ✅ اكتشاف الخطوات (إذا كان التسارع فوق عتبة معينة)
      if (acceleration > 12.0 && acceleration < 20.0) {
        // محاكاة اكتشاف الخطوات (سيتم استخدام الـ Step Counter الفعلي)
      }
    });
  }

  void _stopSensorTracking() {
    _stepCountSubscription?.cancel();
    _accelerometerSubscription?.cancel();
  }

  void _updateStepData() {
    // ✅ تحديث البيانات في الواجهة
    // يمكن إضافة منطق إضافي هنا
  }

  Future<void> _saveTodayRecord() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final record = StepRecord(
        id: _firestore.collection('steps_records').doc().id,
        userId: user.uid,
        date: startOfDay,
        steps: _todaySteps,
        distance: _distance,
        calories: _calories,
        activeMinutes: _activeMinutes,
        hourlySteps: _hourlySteps,
        createdAt: DateTime.now(),
      );
      
      await _firestore
          .collection('steps_records')
          .doc(record.id)
          .set(record.toFirestore());
          
    } catch (e) {
      // تجاهل
    }
  }
}
