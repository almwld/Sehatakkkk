import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/cache_service.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cache = CacheService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    await _cache.init();
    print('✅ AppointmentService initialized');
  }

  Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final cached = await _cache.getList('appointments_${user.uid}');
      if (cached != null && cached.isNotEmpty) {
        return cached.map((e) => e as Map<String, dynamic>).toList();
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .where('status', isEqualTo: 'upcoming')
          .orderBy('date')
          .orderBy('time')
          .get();

      final appointments = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      await _cache.saveList('appointments_${user.uid}', appointments);
      return appointments;
    } catch (e) {
      print('⚠️ Error getting appointments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String specialty,
    required String clinic,
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final data = {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'specialty': specialty,
        'clinic': clinic,
        'date': date.toIso8601String(),
        'time': time,
        'notes': notes ?? '',
        'status': 'upcoming',
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'reminderSent': false,
        'confirmed': false,
      };

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .add(data);

      await _cache.remove('appointments_${user.uid}');

      return {
        'id': docRef.id,
        ...data,
      };
    } catch (e) {
      print('⚠️ Error booking appointment: $e');
      rethrow;
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .doc(id)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      await _cache.remove('appointments_${user.uid}');
    } catch (e) {
      print('⚠️ Error canceling appointment: $e');
      rethrow;
    }
  }

  Future<void> confirmAppointment(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .doc(id)
          .update({
        'confirmed': true,
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      await _cache.remove('appointments_${user.uid}');
    } catch (e) {
      print('⚠️ Error confirming appointment: $e');
      rethrow;
    }
  }

  Future<void> rescheduleAppointment(String id, DateTime newDate, String newTime) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .doc(id)
          .update({
        'date': newDate.toIso8601String(),
        'time': newTime,
        'rescheduledAt': FieldValue.serverTimestamp(),
      });

      await _cache.remove('appointments_${user.uid}');
    } catch (e) {
      print('⚠️ Error rescheduling appointment: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> watchUpcomingAppointments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('appointments')
        .where('status', isEqualTo: 'upcoming')
        .orderBy('date')
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
