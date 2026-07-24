import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/lab/lab_booking_status.dart';
import 'package:sehatak/core/models/lab/sample_collection_method.dart';

class LabBookingModel {
  final String id;
  final String consultationId;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String? patientAddress;
  final String labId;
  final String labName;
  final String labAddress;
  final List<Map<String, dynamic>> tests;
  final double totalPrice;
  final SampleCollectionMethod collectionMethod;
  final LabBookingStatus status;
  final DateTime bookingDate;
  final DateTime createdAt;
  final DateTime? sampleDate;
  final DateTime? resultDate;
  final DateTime? completedAt;
  final String? notes;
  final Map<String, dynamic>? results;
  final String? resultFile;

  LabBookingModel({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    this.patientAddress,
    required this.labId,
    required this.labName,
    required this.labAddress,
    required this.tests,
    required this.totalPrice,
    required this.collectionMethod,
    this.status = LabBookingStatus.pending,
    required this.bookingDate,
    required this.createdAt,
    this.sampleDate,
    this.resultDate,
    this.completedAt,
    this.notes,
    this.results,
    this.resultFile,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'consultationId': consultationId,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientAddress': patientAddress,
      'labId': labId,
      'labName': labName,
      'labAddress': labAddress,
      'tests': tests,
      'totalPrice': totalPrice,
      'collectionMethod': collectionMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'bookingDate': bookingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'sampleDate': sampleDate?.toIso8601String(),
      'resultDate': resultDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'results': results,
      'resultFile': resultFile,
    };
  }

  factory LabBookingModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LabBookingModel(
      id: id,
      consultationId: data['consultationId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      patientAddress: data['patientAddress'],
      labId: data['labId'] ?? '',
      labName: data['labName'] ?? '',
      labAddress: data['labAddress'] ?? '',
      tests: List<Map<String, dynamic>>.from(data['tests'] ?? []),
      totalPrice: data['totalPrice']?.toDouble() ?? 0,
      collectionMethod: _parseCollectionMethod(data['collectionMethod'] ?? 'atLab'),
      status: _parseStatus(data['status'] ?? 'pending'),
      bookingDate: DateTime.parse(data['bookingDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      sampleDate: data['sampleDate'] != null ? DateTime.parse(data['sampleDate']) : null,
      resultDate: data['resultDate'] != null ? DateTime.parse(data['resultDate']) : null,
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
      notes: data['notes'],
      results: data['results'],
      resultFile: data['resultFile'],
    );
  }

  static SampleCollectionMethod _parseCollectionMethod(String value) {
    switch (value) {
      case 'atHome': return SampleCollectionMethod.atHome;
      default: return SampleCollectionMethod.atLab;
    }
  }

  static LabBookingStatus _parseStatus(String value) {
    switch (value) {
      case 'sampleTaken': return LabBookingStatus.sampleTaken;
      case 'processing': return LabBookingStatus.processing;
      case 'completed': return LabBookingStatus.completed;
      case 'cancelled': return LabBookingStatus.cancelled;
      default: return LabBookingStatus.pending;
    }
  }
}
