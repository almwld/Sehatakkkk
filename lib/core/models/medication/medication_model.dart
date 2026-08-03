import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicationFrequency {
  once,
  twice,
  three,
  four,
  asNeeded,
  custom,
}

enum MedicationDosageForm {
  tablet,
  capsule,
  syrup,
  injection,
  drops,
  cream,
  spray,
  patch,
}

class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String? dosage;
  final MedicationDosageForm form;
  final MedicationFrequency frequency;
  final List<TimeOfDay> times;
  final List<int> daysOfWeek;
  final DateTime startDate;
  final DateTime? endDate;
  final int? durationDays;
  final String? instructions;
  final String? notes;
  final String? prescriptionImage;
  final bool isActive;
  final int remainingPills;
  final int? reorderThreshold;
  final DateTime? lastTaken;
  final List<MedicationLog> logs;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    this.dosage,
    required this.form,
    required this.frequency,
    required this.times,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    required this.startDate,
    this.endDate,
    this.durationDays,
    this.instructions,
    this.notes,
    this.prescriptionImage,
    this.isActive = true,
    this.remainingPills = 0,
    this.reorderThreshold,
    this.lastTaken,
    this.logs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get frequencyText {
    switch (frequency) {
      case MedicationFrequency.once: return 'مرة واحدة يومياً';
      case MedicationFrequency.twice: return 'مرتين يومياً';
      case MedicationFrequency.three: return 'ثلاث مرات يومياً';
      case MedicationFrequency.four: return 'أربع مرات يومياً';
      case MedicationFrequency.asNeeded: return 'حسب الحاجة';
      case MedicationFrequency.custom: return 'مخصص';
    }
  }

  String get formText {
    switch (form) {
      case MedicationDosageForm.tablet: return 'أقراص';
      case MedicationDosageForm.capsule: return 'كبسولات';
      case MedicationDosageForm.syrup: return 'شراب';
      case MedicationDosageForm.injection: return 'حقن';
      case MedicationDosageForm.drops: return 'قطرات';
      case MedicationDosageForm.cream: return 'كريم';
      case MedicationDosageForm.spray: return 'بخاخ';
      case MedicationDosageForm.patch: return 'لصقة';
    }
  }

  IconData get formIcon {
    switch (form) {
      case MedicationDosageForm.tablet: return Icons.medication;
      case MedicationDosageForm.capsule: return Icons.medication_outlined;
      case MedicationDosageForm.syrup: return Icons.science;
      case MedicationDosageForm.injection: return Icons.medical_services;
      case MedicationDosageForm.drops: return Icons.water_drop;
      case MedicationDosageForm.cream: return Icons.spa;
      case MedicationDosageForm.spray: return Icons.air;
      case MedicationDosageForm.patch: return Icons.health_and_safety;
    }
  }

  bool get needsRenewal {
    if (remainingPills <= 0) return true;
    if (reorderThreshold != null && remainingPills <= reorderThreshold!) return true;
    return false;
  }

  bool get isExpired {
    if (endDate == null) return false;
    return endDate!.isBefore(DateTime.now());
  }

  String get timesFormatted {
    return times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').join(' • ');
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'dosage': dosage,
    'form': form.toString().split('.').last,
    'frequency': frequency.toString().split('.').last,
    'times': times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
    'daysOfWeek': daysOfWeek,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'durationDays': durationDays,
    'instructions': instructions,
    'notes': notes,
    'prescriptionImage': prescriptionImage,
    'isActive': isActive,
    'remainingPills': remainingPills,
    'reorderThreshold': reorderThreshold,
    'lastTaken': lastTaken?.toIso8601String(),
    'logs': logs.map((log) => log.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MedicationModel.fromFirestore(Map<String, dynamic> data, String id) => MedicationModel(
    id: id,
    userId: data['userId'] ?? '',
    name: data['name'] ?? '',
    dosage: data['dosage'],
    form: _parseForm(data['form'] ?? 'tablet'),
    frequency: _parseFrequency(data['frequency'] ?? 'once'),
    times: (data['times'] as List?)?.map((t) => TimeOfDay(hour: t['hour'] ?? 0, minute: t['minute'] ?? 0)).toList() ?? [],
    daysOfWeek: data['daysOfWeek'] != null ? List<int>.from(data['daysOfWeek']) : [1, 2, 3, 4, 5, 6, 7],
    startDate: DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
    endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
    durationDays: data['durationDays'],
    instructions: data['instructions'],
    notes: data['notes'],
    prescriptionImage: data['prescriptionImage'],
    isActive: data['isActive'] ?? true,
    remainingPills: data['remainingPills'] ?? 0,
    reorderThreshold: data['reorderThreshold'],
    lastTaken: data['lastTaken'] != null ? DateTime.parse(data['lastTaken']) : null,
    logs: (data['logs'] as List?)?.map((log) => MedicationLog.fromMap(log)).toList() ?? [],
    createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
  );

  static MedicationDosageForm _parseForm(String value) {
    switch (value) {
      case 'capsule': return MedicationDosageForm.capsule;
      case 'syrup': return MedicationDosageForm.syrup;
      case 'injection': return MedicationDosageForm.injection;
      case 'drops': return MedicationDosageForm.drops;
      case 'cream': return MedicationDosageForm.cream;
      case 'spray': return MedicationDosageForm.spray;
      case 'patch': return MedicationDosageForm.patch;
      default: return MedicationDosageForm.tablet;
    }
  }

  static MedicationFrequency _parseFrequency(String value) {
    switch (value) {
      case 'twice': return MedicationFrequency.twice;
      case 'three': return MedicationFrequency.three;
      case 'four': return MedicationFrequency.four;
      case 'asNeeded': return MedicationFrequency.asNeeded;
      case 'custom': return MedicationFrequency.custom;
      default: return MedicationFrequency.once;
    }
  }
}

class MedicationLog {
  final DateTime takenAt;
  final bool taken;
  final String? notes;
  final String? skippedReason;

  MedicationLog({
    required this.takenAt,
    required this.taken,
    this.notes,
    this.skippedReason,
  });

  Map<String, dynamic> toMap() => {
    'takenAt': takenAt.toIso8601String(),
    'taken': taken,
    'notes': notes,
    'skippedReason': skippedReason,
  };

  factory MedicationLog.fromMap(Map<String, dynamic> data) => MedicationLog(
    takenAt: DateTime.parse(data['takenAt'] ?? DateTime.now().toIso8601String()),
    taken: data['taken'] ?? false,
    notes: data['notes'],
    skippedReason: data['skippedReason'],
  );
}

extension MedicationDosageFormExtension on MedicationDosageForm {
  Color get color {
    switch (this) {
      case MedicationDosageForm.tablet: return Colors.blue;
      case MedicationDosageForm.capsule: return Colors.purple;
      case MedicationDosageForm.syrup: return Colors.orange;
      case MedicationDosageForm.injection: return Colors.red;
      case MedicationDosageForm.drops: return Colors.cyan;
      case MedicationDosageForm.cream: return Colors.pink;
      case MedicationDosageForm.spray: return Colors.teal;
      case MedicationDosageForm.patch: return Colors.green;
    }
  }
}
