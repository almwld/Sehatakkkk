import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/lab/lab_booking_model.dart';
import 'package:sehatak/core/models/lab/lab_booking_status.dart';
import 'package:sehatak/core/models/lab/sample_collection_method.dart';

class LabService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ إنشاء حجز مختبر
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
    final booking = LabBookingModel(
      id: _firestore.collection('lab_bookings').doc().id,
      consultationId: consultationId,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      patientAddress: patientAddress,
      labId: labId,
      labName: labName,
      labAddress: labAddress,
      tests: tests,
      totalPrice: totalPrice,
      collectionMethod: collectionMethod,
      bookingDate: DateTime.now(),
      createdAt: DateTime.now(),
      notes: notes,
    );

    await _firestore
        .collection('lab_bookings')
        .doc(booking.id)
        .set(booking.toFirestore());

    return booking;
  }

  // ✅ تحديث حالة الحجز
  Future<void> updateBookingStatus({
    required String bookingId,
    required LabBookingStatus status,
    String? notes,
  }) async {
    final updates = {
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (notes != null) {
      updates['notes'] = notes;
    }

    if (status == LabBookingStatus.sampleTaken) {
      updates['sampleDate'] = FieldValue.serverTimestamp();
    }

    if (status == LabBookingStatus.completed) {
      updates['resultDate'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('lab_bookings')
        .doc(bookingId)
        .update(updates);
  }

  // ✅ إضافة نتائج الفحوصات
  Future<void> addLabResults({
    required String bookingId,
    required Map<String, dynamic> results,
    String? resultFile,
  }) async {
    await _firestore
        .collection('lab_bookings')
        .doc(bookingId)
        .update({
      'results': results,
      'resultFile': resultFile,
      'status': LabBookingStatus.completed.toString().split('.').last,
      'resultDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ جلب حجوزات المريض
  Stream<List<LabBookingModel>> getPatientBookings(String patientId) {
    return _firestore
        .collection('lab_bookings')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return LabBookingModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ جلب حجوزات المختبر
  Stream<List<LabBookingModel>> getLabBookings(String labId) {
    return _firestore
        .collection('lab_bookings')
        .where('labId', isEqualTo: labId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return LabBookingModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ جلب حجز محدد
  Future<LabBookingModel?> getLabBooking(String bookingId) async {
    final doc = await _firestore
        .collection('lab_bookings')
        .doc(bookingId)
        .get();

    if (!doc.exists) return null;
    return LabBookingModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ✅ إلغاء حجز
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    await _firestore
        .collection('lab_bookings')
        .doc(bookingId)
        .update({
      'status': LabBookingStatus.cancelled.toString().split('.').last,
      'notes': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ الحصول على إحصائيات المختبر
  Future<Map<String, dynamic>> getLabStats(String labId) async {
    final snap = await _firestore
        .collection('lab_bookings')
        .where('labId', isEqualTo: labId)
        .get();

    final bookings = snap.docs.map((doc) {
      return LabBookingModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    final totalBookings = bookings.length;
    final completed = bookings.where((b) => b.status == LabBookingStatus.completed).length;
    final pending = bookings.where((b) => b.status == LabBookingStatus.pending).length;
    final cancelled = bookings.where((b) => b.status == LabBookingStatus.cancelled).length;
    final totalRevenue = bookings.fold(0.0, (sum, b) => sum + b.totalPrice);

    return {
      'totalBookings': totalBookings,
      'completed': completed,
      'pending': pending,
      'cancelled': cancelled,
      'totalRevenue': totalRevenue,
    };
  }
}
