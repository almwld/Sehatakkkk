import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// مصدر موحّد للقراءات الحيوية الحالية والتاريخية.
class VitalsService {
  VitalsService._();
  static final instance = VitalsService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Stream<Map<String, dynamic>> watchCurrent() {
    final id = uid;
    if (id == null) return Stream.value(<String, dynamic>{});
    return _db.collection('users').doc(id).snapshots().map((snap) {
      final value = snap.data()?['vitals'];
      return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    });
  }

  Stream<List<Map<String, dynamic>>> watchHistory(String key, {int limit = 30}) {
    final id = uid;
    if (id == null) return Stream.value(<Map<String, dynamic>>[]);
    return _db
        .collection('users').doc(id).collection('vital_history')
        .where('key', isEqualTo: key)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> record(String key, dynamic value, {Map<String, dynamic>? extra}) async {
    final id = uid;
    if (id == null) return;
    final userRef = _db.collection('users').doc(id);
    final historyRef = userRef.collection('vital_history').doc();
    final data = <String, dynamic>{
      'key': key,
      'value': value,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (extra != null) data.addAll(extra);
    await _db.runTransaction((tx) async {
      tx.set(userRef, {'vitals': {key: value}}, SetOptions(merge: true));
      tx.set(historyRef, data);
    });
  }

  Future<Map<String, dynamic>> getCurrent() async {
    final id = uid;
    if (id == null) return {};
    final snap = await _db.collection('users').doc(id).get();
    final value = snap.data()?['vitals'];
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }
}
