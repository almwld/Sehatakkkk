import 'package:sehatak/data/models/booking/booking_model.dart';

class BookingService {
  // ✅ جلب التخصصات
  Future<List<SpecialtyModel>> getSpecialties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      SpecialtyModel(id: '1', name: 'باطنية', icon: '🫀', doctorCount: 12),
      SpecialtyModel(id: '2', name: 'قلبية', icon: '❤️', doctorCount: 8),
      SpecialtyModel(id: '3', name: 'عظام', icon: '🦴', doctorCount: 10),
      SpecialtyModel(id: '4', name: 'أطفال', icon: '👶', doctorCount: 15),
      SpecialtyModel(id: '5', name: 'نساء وولادة', icon: '👩‍⚕️', doctorCount: 9),
      SpecialtyModel(id: '6', name: 'جلدية', icon: '🧴', doctorCount: 6),
      SpecialtyModel(id: '7', name: 'عيون', icon: '👁️', doctorCount: 7),
      SpecialtyModel(id: '8', name: 'أنف وأذن', icon: '👂', doctorCount: 5),
      SpecialtyModel(id: '9', name: 'نفسية', icon: '🧠', doctorCount: 4),
      SpecialtyModel(id: '10', name: 'تغذية', icon: '🥗', doctorCount: 3),
    ];
  }

  // ✅ جلب الأطباء
  Future<List<DoctorModel>> getDoctors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DoctorModel(
        id: '1',
        name: 'د. أحمد المولد',
        specialty: 'باطنية',
        specialtyId: '1',
        rating: 4.9,
        experience: 12,
        fee: 500,
        isAvailable: true,
      ),
      DoctorModel(
        id: '2',
        name: 'د. خالد النخلاني',
        specialty: 'قلبية',
        specialtyId: '2',
        rating: 4.8,
        experience: 15,
        fee: 600,
        isAvailable: true,
      ),
      DoctorModel(
        id: '3',
        name: 'د. سارة العمري',
        specialty: 'أطفال',
        specialtyId: '4',
        rating: 4.7,
        experience: 8,
        fee: 450,
        isAvailable: false,
      ),
      DoctorModel(
        id: '4',
        name: 'د. أسماء الهندي',
        specialty: 'نساء وولادة',
        specialtyId: '5',
        rating: 4.9,
        experience: 10,
        fee: 550,
        isAvailable: true,
      ),
      DoctorModel(
        id: '5',
        name: 'د. محمد العلاي',
        specialty: 'عظام',
        specialtyId: '3',
        rating: 4.6,
        experience: 14,
        fee: 500,
        isAvailable: true,
      ),
    ];
  }

  // ✅ جلب المواعيد المتاحة
  Future<List<TimeSlotModel>> getTimeSlots() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TimeSlotModel(id: '1', date: 'السبت 10 يوليو', time: '09:00 - 09:30'),
      TimeSlotModel(id: '2', date: 'السبت 10 يوليو', time: '10:00 - 10:30'),
      TimeSlotModel(id: '3', date: 'السبت 10 يوليو', time: '11:00 - 11:30', isBooked: true),
      TimeSlotModel(id: '4', date: 'السبت 10 يوليو', time: '12:00 - 12:30'),
      TimeSlotModel(id: '5', date: 'الأحد 11 يوليو', time: '09:00 - 09:30'),
      TimeSlotModel(id: '6', date: 'الأحد 11 يوليو', time: '10:00 - 10:30'),
      TimeSlotModel(id: '7', date: 'الأحد 11 يوليو', time: '11:00 - 11:30'),
      TimeSlotModel(id: '8', date: 'الأحد 11 يوليو', time: '12:00 - 12:30', isPast: true),
    ];
  }

  // ✅ تأكيد الحجز
  Future<BookingModel> confirmBooking({
    required String patientId,
    required String doctorId,
    required String date,
    required String time,
    required double fee,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return BookingModel(
      id: 'BOOK_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      doctorId: doctorId,
      doctorName: 'د. أحمد المولد',
      specialty: 'باطنية',
      date: date,
      time: time,
      fee: fee,
      status: 'confirmed',
      createdAt: DateTime.now(),
    );
  }
}
