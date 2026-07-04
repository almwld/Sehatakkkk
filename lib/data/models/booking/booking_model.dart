class SpecialtyModel {
  final String id;
  final String name;
  final String icon;
  final int doctorCount;

  SpecialtyModel({
    required this.id,
    required this.name,
    required this.icon,
    this.doctorCount = 0,
  });
}

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String specialtyId;
  final double rating;
  final int experience;
  final double fee;
  final bool isAvailable;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.specialtyId,
    required this.rating,
    required this.experience,
    required this.fee,
    this.isAvailable = true,
  });
}

class TimeSlotModel {
  final String id;
  final String date;
  final String time;
  final bool isPast;
  final bool isBooked;

  TimeSlotModel({
    required this.id,
    required this.date,
    required this.time,
    this.isPast = false,
    this.isBooked = false,
  });
}

class BookingModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final double fee;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.fee,
    required this.status,
    required this.createdAt,
  });

  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
