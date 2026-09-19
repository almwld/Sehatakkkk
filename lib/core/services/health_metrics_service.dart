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
    final ref = _ref;
    if (ref == null) throw StateError('يجب تسجيل الدخول أولاً');
    await ref.set({
      ...values,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
