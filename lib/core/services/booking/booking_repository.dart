import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/booking/specialty_model.dart';
import 'package:sehatak/core/models/booking/doctor_booking_model.dart';
import 'package:sehatak/core/models/booking/time_slot_model.dart';
import 'package:sehatak/core/models/booking/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // 🏷️ جلب التخصصات
  // ============================================================
  Future<List<SpecialtyModel>> getSpecialties() async {
    try {
      final snapshot = await _firestore.collection('specialties').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => SpecialtyModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print('⚠️ Error loading specialties: $e');
    }
    return _getDefaultSpecialties();
  }

  List<SpecialtyModel> _getDefaultSpecialties() {
    return [
      const SpecialtyModel(id: '1', name: 'باطنية', icon: '🫀', doctorCount: 12),
      const SpecialtyModel(id: '2', name: 'قلبية', icon: '❤️', doctorCount: 8),
      const SpecialtyModel(id: '3', name: 'عظام', icon: '🦴', doctorCount: 10),
      const SpecialtyModel(id: '4', name: 'أطفال', icon: '👶', doctorCount: 15),
      const SpecialtyModel(id: '5', name: 'نساء وولادة', icon: '👩‍⚕️', doctorCount: 9),
    ];
  }

  // ============================================================
  // 👨‍⚕️ جلب الأطباء
  // ============================================================
  Future<List<DoctorBookingModel>> getDoctors({String? specialtyId}) async {
    try {
      Query query = _firestore.collection('doctors');
      if (specialtyId != null && specialtyId.isNotEmpty) {
        query = query.where('specialtyId', isEqualTo: specialtyId);
      }
      final snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => DoctorBookingModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print('⚠️ Error loading doctors: $e');
    }
    return _getDefaultDoctors();
  }

  List<DoctorBookingModel> _getDefaultDoctors() {
    return [
      const DoctorBookingModel(
        id: '1',
        name: 'د. أحمد المولد',
        specialty: 'باطنية',
        specialtyId: '1',
        rating: 4.9,
        reviewsCount: 328,
      ),
      const DoctorBookingModel(
        id: '2',
        name: 'د. خالد النخلاني',
        specialty: 'قلبية',
        specialtyId: '2',
        rating: 4.8,
        reviewsCount: 256,
      ),
      const DoctorBookingModel(
        id: '3',
        name: 'د. أسماء الهندي',
        specialty: 'أطفال',
        specialtyId: '4',
        rating: 4.7,
        reviewsCount: 189,
      ),
    ];
  }

  // ============================================================
  // ⏰ جلب المواعيد المتاحة
  // ============================================================
  Future<List<TimeSlotModel>> getTimeSlots({String? doctorId}) async {
    try {
      final snapshot = await _firestore
          .collection('time_slots')
          .where('doctorId', isEqualTo: doctorId ?? '')
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => TimeSlotModel.fromMap(doc.data()))
            .toList();
      }
    } catch (e) {
      print('⚠️ Error loading time slots: $e');
    }
    return _getDefaultTimeSlots();
  }

  List<TimeSlotModel> _getDefaultTimeSlots() {
    return [
      const TimeSlotModel(id: '1', date: 'السبت 10 يوليو', time: '09:00 - 09:30'),
      const TimeSlotModel(id: '2', date: 'السبت 10 يوليو', time: '10:00 - 10:30'),
      const TimeSlotModel(id: '3', date: 'السبت 10 يوليو', time: '11:00 - 11:30', isBooked: true),
      const TimeSlotModel(id: '4', date: 'السبت 10 يوليو', time: '12:00 - 12:30'),
      const TimeSlotModel(id: '5', date: 'الأحد 11 يوليو', time: '09:00 - 09:30'),
      const TimeSlotModel(id: '6', date: 'الأحد 11 يوليو', time: '10:00 - 10:30'),
    ];
  }

  // ============================================================
  // 📝 تأكيد الحجز
  // ============================================================
  Future<BookingModel> confirmBooking({
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String time,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final booking = BookingModel(
      id: '',
      patientId: user.uid,
      patientName: user.displayName ?? 'مريض',
      doctorId: doctorId,
      doctorName: doctorName,
      date: date,
      time: time,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('appointments')
        .add(booking.toFirestore());

    return booking.copyWith(id: docRef.id);
  }

  // ============================================================
  // 📋 جلب مواعيد المستخدم
  // ============================================================
  Future<List<BookingModel>> getUserAppointments() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('⚠️ Error loading appointments: $e');
      return [];
    }
  }

  // ============================================================
  // ❌ إلغاء موعد
  // ============================================================
  Future<void> cancelAppointment(String bookingId) async {
    await _firestore
        .collection('appointments')
        .doc(bookingId)
        .update({
      'status': BookingStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

// ============================================================
// 📝 Extension
// ============================================================
extension BookingModelCopy on BookingModel {
  BookingModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    DateTime? date,
    String? time,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
