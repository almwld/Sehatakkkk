import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  CollectionReference<Map<String, dynamic>> get _appointments => _firestore.collection('appointments');

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    return user.uid;
  }

  Stream<List<Map<String, dynamic>>> watchPatientAppointments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _appointments.where('patientId', isEqualTo: user.uid).orderBy('date').snapshots().map(_mapSnapshot);
  }

  Stream<List<Map<String, dynamic>>> watchDoctorAppointments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _appointments.where('doctorId', isEqualTo: user.uid).orderBy('date').snapshots().map(_mapSnapshot);
  }

  Stream<List<Map<String, dynamic>>> watchUpcomingAppointments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _appointments.where('patientId', isEqualTo: user.uid).where('status', whereIn: ['pending', 'confirmed']).orderBy('date').snapshots().map(_mapSnapshot);
  }

  Future<List<Map<String, dynamic>>> getPatientAppointments() async {
    final userId = _userId;
    final snapshot = await _appointments.where('patientId', isEqualTo: userId).orderBy('date').get();
    return _mapSnapshot(snapshot);
  }

  Future<List<Map<String, dynamic>>> getDoctorAppointments() async {
    final userId = _userId;
    final snapshot = await _appointments.where('doctorId', isEqualTo: userId).orderBy('date').get();
    return _mapSnapshot(snapshot);
  }

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
    _userId;
    try {
      final result = await _functions.httpsCallable('createAppointment').call({
        'doctorId': doctorId.trim(),
        'date': date.toUtc().toIso8601String(),
        'time': time,
        'type': type,
        'notes': notes,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final id = data['appointmentId']?.toString() ?? '';
      if (id.isEmpty) throw Exception('لم يتم إنشاء الموعد');
      return id;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'تعذر إنشاء الموعد');
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    _validateId(appointmentId);
    await _appointments.doc(appointmentId).update({'status': 'confirmed', 'confirmedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> cancelAppointment(String appointmentId) async {
    _validateId(appointmentId);
    await _appointments.doc(appointmentId).update({'status': 'cancelled', 'cancelledAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> rescheduleAppointment({required String appointmentId, required DateTime newDate, required String newTime}) async {
    _validateId(appointmentId);
    await _appointments.doc(appointmentId).update({'date': Timestamp.fromDate(newDate), 'time': newTime, 'status': 'pending', 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> completeAppointment(String appointmentId) async {
    _validateId(appointmentId);
    await _appointments.doc(appointmentId).update({'status': 'completed', 'updatedAt': FieldValue.serverTimestamp()});
  }

  List<Map<String, dynamic>> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

  void _validateId(String appointmentId) {
    if (appointmentId.trim().isEmpty) throw Exception('معرّف الموعد غير صالح');
  }
}
