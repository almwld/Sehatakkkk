import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/roles.dart';

enum VerificationStatus {
  pending,     // قيد المراجعة
  approved,    // تم الموافقة
  rejected,    // مرفوض
  notSubmitted, // لم يتم التقديم
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final VerificationStatus verificationStatus;
  final bool isActive;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;
  final String? licenseNumber;
  final String? specialty;
  final String? experience;
  final String? bio;
  final List<String>? documents;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.role = UserRole.user,
    this.verificationStatus = VerificationStatus.notSubmitted,
    this.isActive = true,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.licenseNumber,
    this.specialty,
    this.experience,
    this.bio,
    this.documents,
    this.additionalData,
  });

  bool get isProvider {
    return role == UserRole.doctor ||
        role == UserRole.pharmacist ||
        role == UserRole.lab ||
        role == UserRole.veterinarian;
  }

  bool get isAdmin {
    return role == UserRole.admin || role == UserRole.admin;
  }

  bool get isVerified {
    return verificationStatus == VerificationStatus.approved;
  }

  bool get isPendingVerification {
    return verificationStatus == VerificationStatus.pending;
  }

  String get verificationStatusText {
    switch (verificationStatus) {
      case VerificationStatus.pending:
        return '⏳ قيد المراجعة';
      case VerificationStatus.approved:
        return '✅ موثق';
      case VerificationStatus.rejected:
        return '❌ مرفوض';
      case VerificationStatus.notSubmitted:
        return '📤 لم يتم التقديم';
    }
  }

  Color get verificationStatusColor {
    switch (verificationStatus) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
      case VerificationStatus.notSubmitted:
        return Colors.grey;
    }
  }

  IconData get verificationStatusIcon {
    switch (verificationStatus) {
      case VerificationStatus.pending:
        return Icons.hourglass_empty;
      case VerificationStatus.approved:
        return Icons.verified;
      case VerificationStatus.rejected:
        return Icons.cancel;
      case VerificationStatus.notSubmitted:
        return Icons.upload_file;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'licenseNumber': licenseNumber,
      'specialty': specialty,
      'experience': experience,
      'bio': bio,
      'documents': documents,
      'additionalData': additionalData,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role'] ?? 'user'),
      verificationStatus: _parseVerificationStatus(data['verificationStatus'] ?? 'notSubmitted'),
      isActive: data['isActive'] ?? true,
      isAvailable: data['isAvailable'] ?? true,
      rating: data['rating']?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      verifiedAt: data['verifiedAt'] != null ? DateTime.parse(data['verifiedAt']) : null,
      licenseNumber: data['licenseNumber'],
      specialty: data['specialty'],
      experience: data['experience'],
      bio: data['bio'],
      documents: List<String>.from(data['documents'] ?? []),
      additionalData: data['additionalData'],
    );
  }

  static UserRole _parseRole(String value) {
    switch (value) {
      case 'doctor': return UserRole.doctor;
      case 'pharmacist': return UserRole.pharmacist;
      case 'lab': return UserRole.lab;
      case 'veterinarian': return UserRole.veterinarian;
      case 'admin': return UserRole.admin;
      case 'superAdmin': return UserRole.admin;
      default: return UserRole.user;
    }
  }

  static VerificationStatus _parseVerificationStatus(String value) {
    switch (value) {
      case 'pending': return VerificationStatus.pending;
      case 'approved': return VerificationStatus.approved;
      case 'rejected': return VerificationStatus.rejected;
      default: return VerificationStatus.notSubmitted;
    }
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    UserRole? role,
    VerificationStatus? verificationStatus,
    bool? isActive,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    String? licenseNumber,
    String? specialty,
    String? experience,
    String? bio,
    List<String>? documents,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialty: specialty ?? this.specialty,
      experience: experience ?? this.experience,
      bio: bio ?? this.bio,
      documents: documents ?? this.documents,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
