// ============================================================
// 📁 lib/core/models/pharmacy/pharmacy_model.dart
// 💊 نموذج الصيدلية
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PharmacyModel extends Equatable {
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
  final bool? delivery;
  final bool? insuranceAccepted;
  final bool? isVerified;
  final bool? isFeatured;
  final String? deliveryFee;
  final String? minOrder;
  final List<Map<String, dynamic>>? workingHours;
  final Map<String, dynamic>? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PharmacyModel({
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
    this.delivery,
    this.insuranceAccepted,
    this.isVerified = false,
    this.isFeatured = false,
    this.deliveryFee,
    this.minOrder,
    this.workingHours,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PharmacyModel(
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
      delivery: data['delivery'],
      insuranceAccepted: data['insuranceAccepted'],
      isVerified: data['isVerified'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      deliveryFee: data['deliveryFee'],
      minOrder: data['minOrder'],
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
      'delivery': delivery,
      'insuranceAccepted': insuranceAccepted,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'deliveryFee': deliveryFee,
      'minOrder': minOrder,
      'workingHours': workingHours,
      'location': location,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, name];
}
