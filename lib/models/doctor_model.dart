// ============================================================
// 📦 نموذج الطبيب - DoctorModel
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================
  
  final String id;
  final String userId;
  final String name;
  final String specialty;
  final String? subSpecialty;
  final String? image;
  final String? bio;
  final String? clinicAddress;
  final String? clinicPhone;
  final String? email;
  final double rating;
  final int reviewCount;
  final int experience; // عدد سنوات الخبرة
  final double consultationFee;
  final double? followUpFee;
  final bool isAvailable;
  final bool isVerified;
  final bool isOnline;
  final List<String> languages;
  final List<String> services;
  final String workingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;
  final bool isFavorite;

  // ============================================================
  // 🏗️ المنشئ
  // ============================================================
  
  DoctorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.specialty,
    this.subSpecialty,
    this.image,
    this.bio,
    this.clinicAddress,
    this.clinicPhone,
    this.email,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.experience = 0,
    this.consultationFee = 0.0,
    this.followUpFee,
    this.isAvailable = true,
    this.isVerified = false,
    this.isOnline = false,
    this.languages = const [],
    this.services = const [],
    this.workingHours = '',
    this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.isFavorite = false,
  });

  // ============================================================
  // 🔄 التحويل من Map
  // ============================================================
  
  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'طبيب',
      specialty: map['specialty'] ?? 'طبيب عام',
      subSpecialty: map['subSpecialty'],
      image: map['image'],
      bio: map['bio'],
      clinicAddress: map['clinicAddress'],
      clinicPhone: map['clinicPhone'],
      email: map['email'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      experience: map['experience'] ?? 0,
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(),
      followUpFee: (map['followUpFee'] as num?)?.toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      isVerified: map['isVerified'] ?? false,
      isOnline: map['isOnline'] ?? false,
      languages: List<String>.from(map['languages'] ?? []),
      services: List<String>.from(map['services'] ?? []),
      workingHours: map['workingHours'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // ============================================================
  // 🔄 التحويل إلى Map
  // ============================================================
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'specialty': specialty,
      'subSpecialty': subSpecialty,
      'image': image,
      'bio': bio,
      'clinicAddress': clinicAddress,
      'clinicPhone': clinicPhone,
      'email': email,
      'rating': rating,
      'reviewCount': reviewCount,
      'experience': experience,
      'consultationFee': consultationFee,
      'followUpFee': followUpFee,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'languages': languages,
      'services': services,
      'workingHours': workingHours,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================
  
  String get fullName => 'د. $name';
  
  String get specialtyText {
    switch (specialty) {
      case 'cardiology': return 'قلبية';
      case 'dermatology': return 'جلدية';
      case 'pediatrics': return 'أطفال';
      case 'gynecology': return 'نساء وولادة';
      case 'orthopedics': return 'عظام';
      case 'neurology': return 'أعصاب';
      case 'psychiatry': return 'نفسية';
      case 'ophthalmology': return 'عيون';
      case 'dentistry': return 'أسنان';
      default: return specialty;
    }
  }
  
  String get ratingText => rating.toStringAsFixed(1);
  
  String get experienceText => '$experience سنة';
  
  bool get hasClinic => clinicAddress != null && clinicAddress!.isNotEmpty;
  
  bool get hasPhone => clinicPhone != null && clinicPhone!.isNotEmpty;
  
  String get availabilityText => isAvailable ? 'متاح' : 'غير متاح';
  
  DoctorModel copyWith({
    String? name,
    String? specialty,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    bool? isOnline,
    bool? isFavorite,
  }) {
    return DoctorModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      subSpecialty: subSpecialty,
      image: image,
      bio: bio,
      clinicAddress: clinicAddress,
      clinicPhone: clinicPhone,
      email: email,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experience: experience,
      consultationFee: consultationFee,
      followUpFee: followUpFee,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified,
      isOnline: isOnline ?? this.isOnline,
      languages: languages,
      services: services,
      workingHours: workingHours,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
