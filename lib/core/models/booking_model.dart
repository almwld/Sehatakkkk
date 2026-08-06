enum BookingType {
  doctor,
  lab,
  pharmacy,
  hospital,
  consultation,
  subscription,
}

class BookingModel {
  final String id;
  final String userId;
  final BookingType type;
  final String? providerId;
  final String? providerName;
  final DateTime bookingDate;
  final String? notes;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.type,
    this.providerId,
    this.providerName,
    required this.bookingDate,
    this.notes,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'providerId': providerId,
      'providerName': providerName,
      'bookingDate': bookingDate.toIso8601String(),
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BookingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      userId: data['userId'] ?? '',
      type: _parseType(data['type'] ?? 'doctor'),
      providerId: data['providerId'],
      providerName: data['providerName'],
      bookingDate: data['bookingDate'] != null
          ? DateTime.parse(data['bookingDate'])
          : DateTime.now(),
      notes: data['notes'],
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  static BookingType _parseType(String value) {
    switch (value) {
      case 'doctor':
        return BookingType.doctor;
      case 'lab':
        return BookingType.lab;
      case 'pharmacy':
        return BookingType.pharmacy;
      case 'hospital':
        return BookingType.hospital;
      case 'consultation':
        return BookingType.consultation;
      case 'subscription':
        return BookingType.subscription;
      default:
        return BookingType.doctor;
    }
  }

  String get typeText {
    switch (type) {
      case BookingType.doctor:
        return 'طبيب';
      case BookingType.lab:
        return 'مختبر';
      case BookingType.pharmacy:
        return 'صيدلية';
      case BookingType.hospital:
        return 'مستشفى';
      case BookingType.consultation:
        return 'استشارة';
      case BookingType.subscription:
        return 'اشتراك';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case BookingType.doctor:
        return Icons.local_hospital;
      case BookingType.lab:
        return Icons.science;
      case BookingType.pharmacy:
        return Icons.local_pharmacy;
      case BookingType.hospital:
        return Icons.medical_services;
      case BookingType.consultation:
        return Icons.video_call;
      case BookingType.subscription:
        return Icons.subscriptions;
    }
  }

  Color get typeColor {
    switch (type) {
      case BookingType.doctor:
        return Colors.blue;
      case BookingType.lab:
        return Colors.purple;
      case BookingType.pharmacy:
        return Colors.green;
      case BookingType.hospital:
        return Colors.red;
      case BookingType.consultation:
        return Colors.teal;
      case BookingType.subscription:
        return Colors.orange;
    }
  }
}
