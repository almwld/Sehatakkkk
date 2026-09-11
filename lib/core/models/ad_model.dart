import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AdType { doctor, pharmacy, lab, hospital, general }
enum AdStatus { pending, active, rejected, expired }

class AdModel {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final String imageUrl;
  final AdType type;
  final AdStatus status;
  final double budget;
  final double spent;
  final int views;
  final int clicks;
  final DateTime startDate;
  final DateTime endDate;
  final String? reviewNotes;

  const AdModel({required this.id, required this.providerId, required this.title, required this.description, required this.imageUrl, required this.type, required this.status, required this.budget, required this.spent, required this.views, required this.clicks, required this.startDate, required this.endDate, this.reviewNotes});

  factory AdModel.fromFirestore(Map<String, dynamic> data, String id) {
    final now = DateTime.now();
    DateTime date(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }
    final type = AdType.values.firstWhere((v) => v.name == data['type']?.toString(), orElse: () => AdType.general);
    final status = AdStatus.values.firstWhere((v) => v.name == data['status']?.toString(), orElse: () => AdStatus.pending);
    return AdModel(
      id: id,
      providerId: data['providerId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      type: type,
      status: status,
      budget: (data['budget'] as num?)?.toDouble() ?? 0,
      spent: (data['spent'] as num?)?.toDouble() ?? 0,
      views: (data['views'] as num?)?.toInt() ?? 0,
      clicks: (data['clicks'] as num?)?.toInt() ?? 0,
      startDate: date(data['startDate'], now),
      endDate: date(data['endDate'], now.add(const Duration(days: 30))),
      reviewNotes: data['reviewNotes']?.toString(),
    );
  }

  String get displayName => switch (type) { AdType.doctor => 'طبي', AdType.pharmacy => 'صيدلية', AdType.lab => 'مختبر', AdType.hospital => 'مستشفى', AdType.general => 'إعلان' };
  IconData get displayIcon => switch (type) { AdType.doctor => Icons.medical_services_outlined, AdType.pharmacy => Icons.local_pharmacy_outlined, AdType.lab => Icons.science_outlined, AdType.hospital => Icons.local_hospital_outlined, AdType.general => Icons.campaign_outlined };
  Color get displayColor => switch (type) { AdType.doctor => Colors.blue, AdType.pharmacy => Colors.green, AdType.lab => Colors.purple, AdType.hospital => Colors.red, AdType.general => Colors.orange };
  String get statusText => switch (status) { AdStatus.pending => 'قيد المراجعة', AdStatus.active => 'نشط', AdStatus.rejected => 'مرفوض', AdStatus.expired => 'منتهي' };
  Color get statusColor => switch (status) { AdStatus.pending => Colors.orange, AdStatus.active => Colors.green, AdStatus.rejected => Colors.red, AdStatus.expired => Colors.grey };

  Map<String, dynamic> toJson() => {
    'providerId': providerId, 'title': title, 'description': description, 'imageUrl': imageUrl,
    'type': type.name, 'status': status.name, 'budget': budget, 'spent': spent,
    'views': views, 'clicks': clicks, 'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate), 'reviewNotes': reviewNotes,
  };
}