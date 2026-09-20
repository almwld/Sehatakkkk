import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Unified source of truth for user-entered health measurements.
/// All trackers write the latest values to health_metrics/{uid}.
class HealthMetricsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static DocumentReference<Map<String, dynamic>>? get _ref {
    final uid = _auth.currentUser?.uid;
    return uid == null ? null : _db.collection('health_metrics').doc(uid);
  }

  static Stream<Map<String, dynamic>> watch() {
    final ref = _ref;
    if (ref == null) return const Stream.empty();
    return ref.snapshots().map((s) => s.data() ?? const <String, dynamic>{});
  }

  static Future<Map<String, dynamic>> read() async {
    final ref = _ref;
    if (ref == null) return const <String, dynamic>{};
    final snap = await ref.get();
    return snap.data() ?? const <String, dynamic>{};
  }

  static Future<void> update(Map<String, dynamic> values) async {
    final uid = _auth.currentUser?.uid;
    final ref = _ref;
    if (uid == null || ref == null) throw StateError('يجب تسجيل الدخول أولاً');

    final batch = _db.batch();
    batch.set(ref, {...values, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    final vitals = <String, dynamic>{};
    final history = <Map<String, dynamic>>[];
    void addVital(String key, dynamic value) {
      if (value == null) return;
      vitals[key] = value;
      history.add({'key': key, 'value': value});
    }
    if (values['systolic'] is num && values['diastolic'] is num) addVital('bloodPressure', '${values['systolic']}/${values['diastolic']}');
    if (values['blood_sugar'] != null) addVital('glucose', values['blood_sugar']);
    if (values['heartRate'] != null) addVital('heartRate', values['heartRate']);
    if (values['weight'] != null) addVital('weight', values['weight']);
    if (values['bloodOxygen'] != null) addVital('bloodOxygen', values['bloodOxygen']);
    if (values['temperature'] != null) addVital('temperature', values['temperature']);
    if (values['sleep'] != null) addVital('sleep', values['sleep']);
    if (values['steps'] != null) addVital('steps', values['steps']);
    if (values['calories'] != null) addVital('calories', values['calories']);
    if (vitals.isNotEmpty) {
      final userRef = _db.collection('users').doc(uid);
      batch.set(userRef, {'vitals': vitals}, SetOptions(merge: true));
      for (final item in history) {
        batch.set(userRef.collection('vital_history').doc(), {...item, 'timestamp': FieldValue.serverTimestamp()});
      }
    }
    await batch.commit();
  }
