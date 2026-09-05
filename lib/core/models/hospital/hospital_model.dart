// ============================================================
// 📁 lib/core/models/hospital/hospital_model.dart
// 🏥 نموذج المستشفى
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HospitalModel extends Equatable {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final String? website;
  final String? imageUrl;
  final List<String>? images;
  final double? rating;
  final int? reviewsCount;
  final String? type;
  final int? beds;
  final int? doctorsCount;
  final bool? emergency;
  final bool? ambulance;
  final bool? isVerified;
  final bool? isFeatured;
  final List<String>? specialties;
  final List<Map<String, dynamic>>? departments;
  final List<Map<String, dynamic>>? workingHours;
  final Map<String, dynamic>? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HospitalModel({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.address,
    this.city,
    this.phone,
    this.email,
    this.website,
    this.imageUrl,
    this.images,
    this.rating,
    this.reviewsCount,
    this.type,
    this.beds,
    this.doctorsCount,
    this.emergency,
    this.ambulance,
    this.isVerified = false,
    this.isFeatured = false,
    this.specialties,
    this.departments,
    this.workingHours,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory HospitalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HospitalModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameEn: data['nameEn'],
      description: data['description'],
      address: data['address'],
      city: data['city'],
      phone: data['phone'],
      email: data['email'],
      website: data['website'],
      imageUrl: data['imageUrl'],
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'],
      type: data['type'],
      beds: data['beds'],
      doctorsCount: data['doctorsCount'],
      emergency: data['emergency'],
      ambulance: data['ambulance'],
      isVerified: data['isVerified'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      specialties: List<String>.from(data['specialties'] ?? []),
      departments: List<Map<String, dynamic>>.from(data['departments'] ?? []),
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
      'website': website,
      'imageUrl': imageUrl,
      'images': images,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'type': type,
      'beds': beds,
      'doctorsCount': doctorsCount,
      'emergency': emergency,
      'ambulance': ambulance,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'specialties': specialties,
      'departments': departments,
      'workingHours': workingHours,
      'location': location,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, name];
}
