import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  static final AppointmentService _instance =
      AppointmentService._internal();

  factory AppointmentService() => _instance;

  AppointmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection('appointments');

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    return user.uid;
  }

  // ============================================================
  // Real-Time: مواعيد المريض
  // ============================================================

  Stream<List<Map<String, dynamic>>> watchPatientAppointments() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _appointments
        .where('patientId', isEqualTo: user.uid)
        .orderBy('date')
        .snapshots()
        .map(_mapSnapshot);
  }

  // ============================================================
  // Real-Time: مواعيد الطبيب
  // ============================================================

  Stream<List<Map<String, dynamic>>> watchDoctorAppointments() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _appointments
        .where('doctorId', isEqualTo: user.uid)
        .orderBy('date')
        .snapshots()
        .map(_mapSnapshot);
  }

  // ============================================================
  // Real-Time: مواعيد قادمة للمريض
  // ============================================================

  Stream<List<Map<String, dynamic>>> watchUpcomingAppointments() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _appointments
        .where('patientId', isEqualTo: user.uid)
        .where('status', whereIn: [
          'pending',
          'confirmed',
        ])
        .orderBy('date')
        .snapshots()
        .map(_mapSnapshot);
  }

  // ============================================================
  // One-shot fallback
  // ============================================================

  Future<List<Map<String, dynamic>>> getPatientAppointments() async {
    final userId = _userId;

    final snapshot = await _appointments
        .where('patientId', isEqualTo: userId)
        .orderBy('date')
        .get();

    return _mapSnapshot(snapshot);
  }

  Future<List<Map<String, dynamic>>> getDoctorAppointments() async {
    final userId = _userId;

    final snapshot = await _appointments
        .where('doctorId', isEqualTo: userId)
        .orderBy('date')
        .get();

    return _mapSnapshot(snapshot);
  }

  // ============================================================
  // Create appointment
  // ============================================================

  Future<String> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime date,
    required String time,
    String type = 'in_person',
    String notes = '',
    String? clinicAddress,
    String? clinicPhone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final docRef = _appointments.doc();

    final data = <String, dynamic>{
      'patientId': user.uid,
      'patientName': user.displayName ?? 'مريض',

      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,

      'date': Timestamp.fromDate(date),
      'time': time,

      'type': type,
      'status': 'pending',

      'notes': notes,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      'confirmedAt': null,
      'cancelledAt': null,

      'reminderSent': false,

      'clinicAddress': clinicAddress,
      'clinicPhone': clinicPhone,
    };

    await docRef.set(data);

    return docRef.id;
  }

  // ============================================================
  // Confirm
  // ============================================================

  Future<void> confirmAppointment(String appointmentId) async {
    _validateId(appointmentId);

    await _appointments.doc(appointmentId).update({
      'status': 'confirmed',
      'confirmedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Cancel
  // ============================================================

  Future<void> cancelAppointment(String appointmentId) async {
    _validateId(appointmentId);

    await _appointments.doc(appointmentId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Reschedule
  // ============================================================

  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
  }) async {
    _validateId(appointmentId);

    await _appointments.doc(appointmentId).update({
      'date': Timestamp.fromDate(newDate),
      'time': newTime,
      'status': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Complete
  // ============================================================

  Future<void> completeAppointment(String appointmentId) async {
    _validateId(appointmentId);

    await _appointments.doc(appointmentId).update({
      'status': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // Helpers
  // ============================================================

  List<Map<String, dynamic>> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  void _validateId(String appointmentId) {
    if (appointmentId.trim().isEmpty) {
      throw Exception('معرّف الموعد غير صالح');
    }
  }
}
