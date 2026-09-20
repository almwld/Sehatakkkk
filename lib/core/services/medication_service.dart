import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/cache_service.dart';
import 'package:sehatak/core/services/medication_reminder_scheduler.dart';

class MedicationService {
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MedicationReminderScheduler _scheduler = MedicationReminderScheduler.instance;

  Future<void> init() async => _scheduler.initialize();

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('medications');

  Future<List<Map<String, dynamic>>> getUpcomingMedications() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final snapshot = await _collection(user.uid).where('active', isEqualTo: true).get();
      final medications = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      await CacheService.saveList('medications_${user.uid}', medications);
      await _scheduler.sync(medications);
      return medications;
    } catch (e) {
      print('⚠️ Error getting medications: $e');
      final cached = await CacheService.getList('medications_${user.uid}');
      return cached ?? [];
    }
  }

  Future<Map<String, dynamic>> addMedication({
    required String name,
    required String dose,
    required String frequency,
    required String time,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? times,
    String? doctorId,
    String? consultationId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final data = <String, dynamic>{
      'name': name.trim(),
      'dose': dose.trim(),
      'frequency': frequency.trim(),
      'time': time.trim(),
      'times': times ?? [time.trim()],
      'notes': notes ?? '',
      'startDate': startDate ?? DateTime.now(),
      'endDate': endDate,
      'active': true,
      'reminderEnabled': true,
      'taken': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
      if (doctorId != null) 'doctorId': doctorId,
      if (consultationId != null) 'consultationId': consultationId,
    };
    final localId = 'med_${DateTime.now().microsecondsSinceEpoch}';
    final result = {'id': localId, ...data, 'startDate': startDate ?? DateTime.now()};
    final previous = await CacheService.getList('medications_${user.uid}') ?? const <Map<String, dynamic>>[];
    await CacheService.saveList('medications_${user.uid}', [result, ...previous]);

    // Persist the medication first. Firestore queues this write while offline;
    // a local scheduling failure must never reject the medication itself.
    try {
      final ref = _collection(user.uid).doc(localId);
      await ref.set(data);
    } catch (_) {
      // Keep the local copy so the medication remains available offline.
    }

    // Schedule independently from the database write so the reminder works
    // immediately, including when the device is offline.
    try {
      await _scheduler.scheduleMedication(medication: result);
    } catch (_) {
      // The medication is already saved locally/queued for Firestore.
      // The next medication sync will retry the local alarm setup.
    }
    return result;
  }

  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final cacheKey = 'medications_${user.uid}';
    final current = await CacheService.getList(cacheKey) ?? <Map<String, dynamic>>[];
    final merged = <String, dynamic>{...data, 'id': id, 'updatedAt': DateTime.now().toIso8601String()};
    final next = current.map((m) => m['id']?.toString() == id ? {...m, ...merged} : m).toList();
    await CacheService.saveList(cacheKey, next);
    try { await _collection(user.uid).doc(id).set({...data, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)); } catch (_) {}
    final local = next.firstWhere((m) => m['id']?.toString() == id, orElse: () => merged);
    if (local['reminderEnabled'] == false || local['active'] == false) {
      await _scheduler.cancelMedication(id);
    } else {
      await _scheduler.scheduleMedication(medication: local);
    }
  }

  Future<void> deleteMedication(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final key = 'medications_${user.uid}';
    final current = await CacheService.getList(key) ?? <Map<String, dynamic>>[];
    await CacheService.saveList(key, current.where((m) => m['id']?.toString() != id).toList());
    await _scheduler.cancelMedication(id);
    try { await _collection(user.uid).doc(id).delete(); } catch (_) {}
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final key = 'medications_${user.uid}';
    final current = await CacheService.getList(key) ?? <Map<String, dynamic>>[];
    final next = current.map((m) => m['id']?.toString() == id ? {...m, 'reminderEnabled': enabled} : m).toList();
    await CacheService.saveList(key, next);
    try { await _collection(user.uid).doc(id).set({'reminderEnabled': enabled, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)); } catch (_) {}
    final local = next.firstWhere((m) => m['id']?.toString() == id, orElse: () => <String,dynamic>{'id':id});
    if (enabled) { await _scheduler.scheduleMedication(medication: local); } else { await _scheduler.cancelMedication(id); }
  }

  Future<List<Map<String, dynamic>>> getMedicationHistory() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications_history')
          .orderBy('takenAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('⚠️ Error getting medication history: $e');
      return [];
    }
  }

  Future<void> markAsTaken(String medicationId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _firestore.collection('users').doc(user.uid).collection('medications_history').add({
      'medicationId': medicationId,
      'takenAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    });
    await _collection(user.uid).doc(medicationId).update({
      'taken': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchUpcomingMedications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _collection(user.uid).where('active', isEqualTo: true).snapshots().asyncMap((snapshot) async {
      final medications = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      await _scheduler.sync(medications);
      return medications;
    });
  }
}
