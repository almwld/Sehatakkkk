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
    final ref = await _collection(user.uid).add(data);
    final result = {'id': ref.id, ...data, 'startDate': startDate ?? DateTime.now()};
    await CacheService.remove('medications_${user.uid}');
    await _scheduler.scheduleMedication(medication: result);
    return result;
  }

  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final updates = {...data, 'updatedAt': FieldValue.serverTimestamp()};
    await _collection(user.uid).doc(id).update(updates);
    await CacheService.remove('medications_${user.uid}');
    final doc = await _collection(user.uid).doc(id).get();
    if (doc.exists) {
      await _scheduler.scheduleMedication(medication: {'id': doc.id, ...doc.data()!});
    }
  }

  Future<void> deleteMedication(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _collection(user.uid).doc(id).delete();
    await _scheduler.cancelMedication(id);
    await CacheService.remove('medications_${user.uid}');
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _collection(user.uid).doc(id).update({
      'reminderEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await CacheService.remove('medications_${user.uid}');
    final doc = await _collection(user.uid).doc(id).get();
    if (enabled && doc.exists) {
      await _scheduler.scheduleMedication(medication: {'id': doc.id, ...doc.data()!});
    } else {
      await _scheduler.cancelMedication(id);
    }
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
