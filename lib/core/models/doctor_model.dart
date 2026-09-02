// ============================================================
// 📊 DoctorModel - نموذج الطبيب
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel extends Equatable {
  final String id;
  final String name;
  final String specialty;
  final String? subspecialty;
  final String? photoUrl;
  final double? rating;
  final int? reviewsCount;
  final double? consultationFee;
  final bool isAvailable;
  final bool isOnline;
  final int? experienceYears;
  final String? hospital;
  final String? clinicAddress;
  final String? about;
  final List<String>? languages;
  final List<String>? services;
  final Map<String, dynamic>? workingHours;
  final List<Map<String, dynamic>>? education;
  final List<Map<String, dynamic>>? certifications;
  final List<Map<String, dynamic>>? reviews;
  final bool isVerified;
  final int? patientsCount;
  final List<String>? specialties;
  final Map<String, double>? ratingBreakdown;
  final bool isFeatured;
  final Timestamp? createdAt;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.subspecialty,
    this.photoUrl,
    this.rating,
    this.reviewsCount,
    this.consultationFee,
    this.isAvailable = false,
    this.isOnline = false,
    this.experienceYears,
    this.hospital,
    this.clinicAddress,
    this.about,
    this.languages,
    this.services,
    this.workingHours,
    this.education,
    this.certifications,
    this.reviews,
    this.isVerified = false,
    this.patientsCount,
    this.specialties,
    this.ratingBreakdown,
    this.isFeatured = false,
    this.createdAt,
  });

  factory DoctorModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DoctorModel(
      id: id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      subspecialty: data['subspecialty'],
      photoUrl: data['photoUrl'],
      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'],
      consultationFee: (data['consultationFee'] as num?)?.toDouble(),
      isAvailable: data['isAvailable'] ?? false,
      isOnline: data['isOnline'] ?? false,
      experienceYears: data['experienceYears'],
      hospital: data['hospital'],
      clinicAddress: data['clinicAddress'],
      about: data['about'],
      languages: List<String>.from(data['languages'] ?? []),
      services: List<String>.from(data['services'] ?? []),
      workingHours: Map<String, dynamic>.from(data['workingHours'] ?? {}),
      education: List<Map<String, dynamic>>.from(data['education'] ?? []),
      certifications: List<Map<String, dynamic>>.from(data['certifications'] ?? []),
      reviews: List<Map<String, dynamic>>.from(data['reviews'] ?? []),
      isVerified: data['isVerified'] ?? false,
      patientsCount: data['patientsCount'],
      specialties: List<String>.from(data['specialties'] ?? []),
      ratingBreakdown: Map<String, double>.from(data['ratingBreakdown'] ?? {}),
      isFeatured: data['isFeatured'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialty': specialty,
      'subspecialty': subspecialty,
      'photoUrl': photoUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'isOnline': isOnline,
      'experienceYears': experienceYears,
      'hospital': hospital,
      'clinicAddress': clinicAddress,
      'about': about,
      'languages': languages,
      'services': services,
      'workingHours': workingHours,
      'education': education,
      'certifications': certifications,
      'reviews': reviews,
      'isVerified': isVerified,
      'patientsCount': patientsCount,
      'specialties': specialties,
      'ratingBreakdown': ratingBreakdown,
      'isFeatured': isFeatured,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialty,
    String? subspecialty,
    String? photoUrl,
    double? rating,
    int? reviewsCount,
    double? consultationFee,
    bool? isAvailable,
    bool? isOnline,
    int? experienceYears,
    String? hospital,
    String? clinicAddress,
    String? about,
    List<String>? languages,
    List<String>? services,
    Map<String, dynamic>? workingHours,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? certifications,
    List<Map<String, dynamic>>? reviews,
    bool? isVerified,
    int? patientsCount,
    List<String>? specialties,
    Map<String, double>? ratingBreakdown,
    bool? isFeatured,
    Timestamp? createdAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      subspecialty: subspecialty ?? this.subspecialty,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      experienceYears: experienceYears ?? this.experienceYears,
      hospital: hospital ?? this.hospital,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      about: about ?? this.about,
      languages: languages ?? this.languages,
      services: services ?? this.services,
      workingHours: workingHours ?? this.workingHours,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      reviews: reviews ?? this.reviews,
      isVerified: isVerified ?? this.isVerified,
      patientsCount: patientsCount ?? this.patientsCount,
      specialties: specialties ?? this.specialties,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, specialty, subspecialty, photoUrl, rating, reviewsCount,
    consultationFee, isAvailable, isOnline, experienceYears, hospital,
    clinicAddress, about, languages, services, workingHours, education,
    certifications, reviews, isVerified, patientsCount, specialties,
    ratingBreakdown, isFeatured, createdAt,
  ];

  // ✅ المساعدات
  double get averageRating => rating ?? 0.0;
  int get totalReviews => reviewsCount ?? 0;
  bool get hasConsultationFee => consultationFee != null && consultationFee! > 0;
  String get formattedConsultationFee {
    if (!hasConsultationFee) return 'مجاني';
    return '\$${consultationFee!.toStringAsFixed(0)}';
  }
  bool get isAvailableNow => isAvailable && isOnline;
  String getSpecialtyDisplay() {
    if (subspecialty != null && subspecialty!.isNotEmpty) {
      return '$specialty - $subspecialty';
    }
    return specialty;
  }
}
