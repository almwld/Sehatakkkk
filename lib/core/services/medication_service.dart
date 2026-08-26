import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/cache_service.dart';

class MedicationService {
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cache = CacheService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    await _cache.init();
    print('✅ MedicationService initialized');
  }

  Future<List<Map<String, dynamic>>> getUpcomingMedications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // محاولة تحميل من الكاش أولاً
      final cached = await _cache.getList('medications_${user.uid}');
      if (cached != null && cached.isNotEmpty) {
        return cached.map((e) => e as Map<String, dynamic>).toList();
      }

      // جلب من Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .where('active', isEqualTo: true)
          .orderBy('time')
          .get();

      final medications = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // حفظ في الكاش
      await _cache.saveList('medications_${user.uid}', medications);
      
      return medications;
    } catch (e) {
      print('⚠️ Error getting medications: $e');
      return [];
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
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final data = {
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'time': time,
        'notes': notes ?? '',
        'startDate': startDate ?? FieldValue.serverTimestamp(),
        'endDate': endDate,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'reminderEnabled': true,
      };

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .add(data);

      // تحديث الكاش
      await _cache.remove('medications_${user.uid}');

      return {
        'id': docRef.id,
        ...data,
      };
    } catch (e) {
      print('⚠️ Error adding medication: $e');
      rethrow;
    }
  }

  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(id)
          .update(data);

      await _cache.remove('medications_${user.uid}');
    } catch (e) {
      print('⚠️ Error updating medication: $e');
      rethrow;
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(id)
          .delete();

      await _cache.remove('medications_${user.uid}');
    } catch (e) {
      print('⚠️ Error deleting medication: $e');
      rethrow;
    }
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(id)
          .update({'reminderEnabled': enabled});

      await _cache.remove('medications_${user.uid}');
    } catch (e) {
      print('⚠️ Error toggling reminder: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMedicationHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications_history')
          .orderBy('takenAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('⚠️ Error getting medication history: $e');
      return [];
    }
  }

  Future<void> markAsTaken(String medicationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications_history')
          .add({
        'medicationId': medicationId,
        'takenAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });
    } catch (e) {
      print('⚠️ Error marking as taken: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> watchUpcomingMedications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('medications')
        .where('active', isEqualTo: true)
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        });
  }
}
