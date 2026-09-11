import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/booking/specialty_model.dart';
import 'package:sehatak/core/models/booking/doctor_booking_model.dart';
import 'package:sehatak/core/models/booking/time_slot_model.dart';
import 'package:sehatak/core/models/booking/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<SpecialtyModel>> getSpecialties() async {
    try {
      final snapshot = await _firestore.collection('specialties').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => SpecialtyModel.fromMap(doc.data())).toList();
      }
    } catch (e) { print('⚠️ Error loading specialties: $e'); }
    return const [
      SpecialtyModel(id: '1', name: 'باطنية', icon: '🫀', doctorCount: 12),
      SpecialtyModel(id: '2', name: 'قلبية', icon: '❤️', doctorCount: 8),
      SpecialtyModel(id: '3', name: 'عظام', icon: '🦴', doctorCount: 10),
    ];
  }

  Future<List<DoctorBookingModel>> getDoctors({String? specialtyId}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('doctors');
      if (specialtyId != null && specialtyId.isNotEmpty) query = query.where('specialtyId', isEqualTo: specialtyId);
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) return snapshot.docs.map((doc) => DoctorBookingModel.fromMap(doc.data())).toList();
    } catch (e) { print('⚠️ Error loading doctors: $e'); }
    return const [
      DoctorBookingModel(id: '1', name: 'د. أحمد المولد', specialty: 'باطنية', specialtyId: '1', rating: 4.9, reviewsCount: 328),
      DoctorBookingModel(id: '2', name: 'د. خالد النخلاني', specialty: 'قلبية', specialtyId: '2', rating: 4.8, reviewsCount: 256),
    ];
  }

  Future<List<TimeSlotModel>> getTimeSlots({String? doctorId}) async {
    try {
      final snapshot = await _firestore.collection('time_slots').where('doctorId', isEqualTo: doctorId ?? '').get();
      if (snapshot.docs.isNotEmpty) return snapshot.docs.map((doc) => TimeSlotModel.fromMap(doc.data())).toList();
    } catch (e) { print('⚠️ Error loading time slots: $e'); }
    return const [
      TimeSlotModel(id: '1', date: 'السبت 10 يوليو', time: '09:00 - 09:30'),
      TimeSlotModel(id: '2', date: 'السبت 10 يوليو', time: '10:00 - 10:30'),
      TimeSlotModel(id: '3', date: 'السبت 10 يوليو', time: '11:00 - 11:30', isBooked: true),
    ];
  }

  Future<BookingModel> confirmBooking({required String doctorId, required String doctorName, required DateTime date, required String time}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');
    final booking = BookingModel(id: '', patientId: user.uid, patientName: user.displayName ?? 'مريض', doctorId: doctorId, doctorName: doctorName, date: date, time: time, status: BookingStatus.pending, createdAt: DateTime.now());
    final ref = await _firestore.collection('appointments').add(booking.toFirestore());
    return booking.copyWith(id: ref.id);
  }

  Future<List<BookingModel>> getUserAppointments() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final snapshot = await _firestore.collection('appointments').where('patientId', isEqualTo: user.uid).orderBy('date').get();
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) { print('⚠️ Error loading appointments: $e'); return []; }
  }

  Future<void> cancelAppointment(String bookingId) => _firestore.collection('appointments').doc(bookingId).update({'status': BookingStatus.cancelled.name, 'updatedAt': FieldValue.serverTimestamp()});
}

extension BookingModelCopy on BookingModel {
  BookingModel copyWith({String? id, String? patientId, String? patientName, String? doctorId, String? doctorName, DateTime? date, String? time, BookingStatus? status, DateTime? createdAt, DateTime? updatedAt}) => BookingModel(id: id ?? this.id, patientId: patientId ?? this.patientId, patientName: patientName ?? this.patientName, doctorId: doctorId ?? this.doctorId, doctorName: doctorName ?? this.doctorName, date: date ?? this.date, time: time ?? this.time, status: status ?? this.status, createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt);
}
