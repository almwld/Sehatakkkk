// ============================================================
// 📁 lib/core/models/lab/lab_model.dart
// 🔬 نموذج المختبر
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LabModel extends Equatable {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final List<String>? images;
  final double? rating;
  final int? reviewsCount;
  final List<String>? tests;
  final bool? accredited;
  final bool? homeCollection;
  final bool? isVerified;
  final bool? isFeatured;
  final List<Map<String, dynamic>>? workingHours;
  final Map<String, dynamic>? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LabModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.address,
    this.city,
    this.phone,
    this.email,
    this.imageUrl,
    this.images,
    this.rating,
    this.reviewsCount,
    this.tests,
    this.accredited,
    this.homeCollection,
    this.isVerified = false,
    this.isFeatured = false,
    this.workingHours,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory LabModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LabModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameEn: data['nameEn'],
      description: data['description'],
      address: data['address'],
      city: data['city'],
      phone: data['phone'],
      email: data['email'],
      imageUrl: data['imageUrl'],
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'],
      tests: List<String>.from(data['tests'] ?? []),
      accredited: data['accredited'],
      homeCollection: data['homeCollection'],
      isVerified: data['isVerified'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      workingHours: data['workingHours'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'address': address,
      'city': city,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'images': images,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'tests': tests,
      'accredited': accredited,
      'homeCollection': homeCollection,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'workingHours': workingHours,
      'location': location,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, name];
}
