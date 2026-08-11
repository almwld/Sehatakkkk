import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/roles.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? specialty;
  final String? photoUrl;
  final bool isVerified;
  final bool isAvailable;
  final String? verificationStatus;
  final double rating;
  final int reviewCount;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.specialty,
    this.photoUrl,
    this.isVerified = false,
    this.isAvailable = true,
    this.verificationStatus,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: _parseRole(data['role'] ?? 'user'),
      specialty: data['specialty'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
      verificationStatus: data['verificationStatus'] ?? 'notSubmitted',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return UserRole.doctor;
      case 'pharmacist':
        return UserRole.pharmacist;
      case 'lab':
        return UserRole.lab;
      case 'veterinarian':
        return UserRole.veterinarian;
      case 'admin':
      case 'superadmin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'specialty': specialty,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'verificationStatus': verificationStatus,
      'rating': rating,
      'reviewCount': reviewCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? specialty,
    String? photoUrl,
    bool? isVerified,
    bool? isAvailable,
    String? verificationStatus,
    double? rating,
    int? reviewCount,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
