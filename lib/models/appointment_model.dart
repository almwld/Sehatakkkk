// ============================================================
// 📦 نموذج الموعد - AppointmentModel
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================
  
  final String id;
  final String userId;
  final String userName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime date;
  final String time;
  final String type; // 'in_person', 'video', 'phone'
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final bool reminderSent;
  final String? clinicAddress;
  final String? clinicPhone;
  
  // ============================================================
  // 🏗️ المنشئ
  // ============================================================
  
  AppointmentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.reminderSent = false,
    this.clinicAddress,
    this.clinicPhone,
  });

  // ============================================================
  // 🔄 التحويل من Map
  // ============================================================
  
  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'مستخدم',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? 'طبيب',
      doctorSpecialty: map['doctorSpecialty'] ?? 'طبيب عام',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: map['time'] ?? '',
      type: map['type'] ?? 'in_person',
      status: map['status'] ?? 'pending',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      confirmedAt: (map['confirmedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (map['cancelledAt'] as Timestamp?)?.toDate(),
      reminderSent: map['reminderSent'] ?? false,
      clinicAddress: map['clinicAddress'],
      clinicPhone: map['clinicPhone'],
    );
  }

  // ============================================================
  // 🔄 التحويل إلى Map
  // ============================================================
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': Timestamp.fromDate(date),
      'time': time,
      'type': type,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'reminderSent': reminderSent,
      'clinicAddress': clinicAddress,
      'clinicPhone': clinicPhone,
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================
  
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isUpcoming => date.isAfter(DateTime.now()) && !isCancelled;
  bool get isPast => date.isBefore(DateTime.now()) && !isCancelled;
  
  String get statusText {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'confirmed': return 'مؤكد';
      case 'completed': return 'مكتمل';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  }
  
  String get typeText {
    switch (type) {
      case 'in_person': return 'حضوري';
      case 'video': return 'فيديو';
      case 'phone': return 'هاتفي';
      default: return type;
    }
  }
  
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String get formattedDateTime {
    return '$formattedDate الساعة $time';
  }
  
  AppointmentModel copyWith({
    String? status,
    String? notes,
    DateTime? date,
    String? time,
    bool? reminderSent,
  }) {
    return AppointmentModel(
      id: id,
      userId: userId,
      userName: userName,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      date: date ?? this.date,
      time: time ?? this.time,
      type: type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      confirmedAt: confirmedAt,
      cancelledAt: cancelledAt,
      reminderSent: reminderSent ?? this.reminderSent,
      clinicAddress: clinicAddress,
      clinicPhone: clinicPhone,
    );
  }
}
