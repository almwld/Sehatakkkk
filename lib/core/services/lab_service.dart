import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/lab/lab_booking_model.dart';
import 'package:sehatak/core/models/lab/lab_booking_status.dart';
import 'package:sehatak/core/models/lab/sample_collection_method.dart';

class LabService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<LabBookingModel> createLabBooking({
    required String consultationId,
    required String patientId,
    required String patientName,
    required String patientPhone,
    String? patientAddress,
    required String labId,
    required String labName,
    required String labAddress,
    required List<Map<String, dynamic>> tests,
    required double totalPrice,
    required SampleCollectionMethod collectionMethod,
    String? notes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    if (patientId != user.uid) throw Exception('حساب المريض غير صالح');
    if (tests.isEmpty) throw Exception('اختر فحصًا واحدًا على الأقل');

    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final result = await _functions.httpsCallable('createLabBooking').call({
      'labId': labId,
      'date': date,
      'time': time,
      'testIds': tests.map((t) => '${t['id'] ?? t['testId'] ?? ''}').where((id) => id.isNotEmpty).toList(),
      'notes': notes,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return LabBookingModel(
      id: '${data['bookingId'] ?? ''}',
      consultationId: consultationId,
      patientId: user.uid,
      patientName: patientName,
      patientPhone: patientPhone,
      patientAddress: patientAddress,
      labId: labId,
      labName: labName,
      labAddress: labAddress,
      tests: tests,
      totalPrice: totalPrice,
      collectionMethod: collectionMethod,
      bookingDate: now,
      createdAt: now,
      notes: notes,
    );
  }

  Future<void> updateBookingStatus({required String bookingId, required LabBookingStatus status, String? notes}) async {
    final updates = <String, dynamic>{'status': status.toString().split('.').last, 'updatedAt': FieldValue.serverTimestamp()};
    if (notes != null) updates['notes'] = notes;
    if (status == LabBookingStatus.sampleTaken) updates['sampleDate'] = FieldValue.serverTimestamp();
    if (status == LabBookingStatus.completed) updates['resultDate'] = FieldValue.serverTimestamp();
    await _firestore.collection('lab_bookings').doc(bookingId).update(updates);
  }

  Future<void> addLabResults({required String bookingId, required Map<String, dynamic> results, String? resultFile}) async {
    await _firestore.collection('lab_bookings').doc(bookingId).update({'results': results, 'resultFile': resultFile, 'status': LabBookingStatus.completed.toString().split('.').last, 'resultDate': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Stream<List<LabBookingModel>> getPatientBookings(String patientId) => _firestore.collection('lab_bookings').where('patientId', isEqualTo: patientId).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => LabBookingModel.fromFirestore(d.data(), d.id)).toList());
  Stream<List<LabBookingModel>> getLabBookings(String labId) => _firestore.collection('lab_bookings').where('labId', isEqualTo: labId).orderBy('createdAt', descending: true).snapshots().map((s) => s.docs.map((d) => LabBookingModel.fromFirestore(d.data(), d.id)).toList());

  Future<LabBookingModel?> getLabBooking(String bookingId) async {
    final doc = await _firestore.collection('lab_bookings').doc(bookingId).get();
    if (!doc.exists) return null;
    return LabBookingModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> cancelBooking({required String bookingId, required String reason}) async {
    await _firestore.collection('lab_bookings').doc(bookingId).update({'status': LabBookingStatus.cancelled.toString().split('.').last, 'notes': reason, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<Map<String, dynamic>> getLabStats(String labId) async {
    final snap = await _firestore.collection('lab_bookings').where('labId', isEqualTo: labId).get();
    final bookings = snap.docs.map((d) => LabBookingModel.fromFirestore(d.data(), d.id)).toList();
    return {'totalBookings': bookings.length, 'completed': bookings.where((b) => b.status == LabBookingStatus.completed).length, 'pending': bookings.where((b) => b.status == LabBookingStatus.pending).length, 'cancelled': bookings.where((b) => b.status == LabBookingStatus.cancelled).length, 'totalRevenue': bookings.fold<double>(0, (sum, b) => sum + b.totalPrice)};
  }
}
