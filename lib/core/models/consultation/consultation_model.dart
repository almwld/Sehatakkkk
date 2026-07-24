import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/consultation/consultation_status.dart';

class ConsultationModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialty;
  final String symptoms;
  final String? description;
  final List<String>? images;
  final List<String>? voiceNotes;
  final bool isUrgent;
  final double? fee;
  final ConsultationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? notes;
  final String? labChoice;
  final String? labId;
  final String? labName;
  final String? labResult;
  final List<Map<String, dynamic>>? labTests;
  final List<Map<String, dynamic>>? prescription;
  final List<String>? medicines;
  final String? medicineInstructions;
  final String? diagnosis;
  final DateTime? prescriptionDate;

  ConsultationModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialty,
    required this.symptoms,
    this.description,
    this.images,
    this.voiceNotes,
    this.isUrgent = false,
    this.fee,
    this.status = ConsultationStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.notes,
    this.labChoice,
    this.labId,
    this.labName,
    this.labResult,
    this.labTests,
    this.prescription,
    this.medicines,
    this.medicineInstructions,
    this.diagnosis,
    this.prescriptionDate,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'symptoms': symptoms,
      'description': description,
      'images': images,
      'voiceNotes': voiceNotes,
      'isUrgent': isUrgent,
      'fee': fee,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'labChoice': labChoice,
      'labId': labId,
      'labName': labName,
      'labResult': labResult,
      'labTests': labTests,
      'prescription': prescription,
      'medicines': medicines,
      'medicineInstructions': medicineInstructions,
      'diagnosis': diagnosis,
      'prescriptionDate': prescriptionDate?.toIso8601String(),
    };
  }

  factory ConsultationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ConsultationModel(
      id: id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialty: data['doctorSpecialty'],
      symptoms: data['symptoms'] ?? '',
      description: data['description'],
      images: List<String>.from(data['images'] ?? []),
      voiceNotes: List<String>.from(data['voiceNotes'] ?? []),
      isUrgent: data['isUrgent'] ?? false,
      fee: data['fee']?.toDouble(),
      status: _parseStatus(data['status'] ?? 'pending'),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
      notes: data['notes'],
      labChoice: data['labChoice'],
      labId: data['labId'],
      labName: data['labName'],
      labResult: data['labResult'],
      labTests: data['labTests'] != null ? List<Map<String, dynamic>>.from(data['labTests']) : null,
      prescription: data['prescription'] != null ? List<Map<String, dynamic>>.from(data['prescription']) : null,
      medicines: List<String>.from(data['medicines'] ?? []),
      medicineInstructions: data['medicineInstructions'],
      diagnosis: data['diagnosis'],
      prescriptionDate: data['prescriptionDate'] != null ? DateTime.parse(data['prescriptionDate']) : null,
    );
  }

  static ConsultationStatus _parseStatus(String value) {
    switch (value) {
      case 'confirmed': return ConsultationStatus.confirmed;
      case 'inProgress': return ConsultationStatus.inProgress;
      case 'labDone': return ConsultationStatus.labDone;
      case 'prescription': return ConsultationStatus.prescription;
      case 'completed': return ConsultationStatus.completed;
      case 'cancelled': return ConsultationStatus.cancelled;
      default: return ConsultationStatus.pending;
    }
  }
}
