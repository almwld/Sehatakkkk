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
    // ✅ معالجة education (يمكن أن يكون String أو List)
    List<Map<String, dynamic>> parseEducation(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) {
          if (e is Map<String, dynamic>) return e;
          if (e is String) return {'degree': e};
          return {};
        }).toList();
      }
      if (value is String) {
        return [{'degree': value}];
      }
      return [];
    }

    // ✅ معالجة services (يمكن أن يكون String أو List)
    List<String> parseServices(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) {
        return [value];
      }
      return [];
    }

    // ✅ معالجة languages (يمكن أن يكون String أو List)
    List<String> parseLanguages(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) {
        return [value];
      }
      return [];
    }

    return DoctorModel(
      id: id,
      name: data['name']?.toString() ?? '',
      specialty: data['specialty']?.toString() ?? '',
      subspecialty: data['subspecialty']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'] as int?,
      consultationFee: (data['consultationFee'] as num?)?.toDouble(),
      isAvailable: data['isAvailable'] ?? false,
      isOnline: data['isOnline'] ?? false,
      experienceYears: data['experienceYears'] as int?,
      hospital: data['hospital']?.toString(),
      clinicAddress: data['clinicAddress']?.toString(),
      about: data['about']?.toString(),
      languages: parseLanguages(data['languages']),
      services: parseServices(data['services']),
      workingHours: data['workingHours'] is Map 
          ? Map<String, dynamic>.from(data['workingHours']) 
          : null,
      education: parseEducation(data['education']),
      certifications: data['certifications'] is List
          ? List<Map<String, dynamic>>.from(data['certifications'])
          : null,
      reviews: data['reviews'] is List
          ? List<Map<String, dynamic>>.from(data['reviews'])
          : null,
      isVerified: data['isVerified'] ?? false,
      patientsCount: data['patientsCount'] as int?,
      specialties: data['specialties'] is List
          ? List<String>.from(data['specialties'])
          : null,
      ratingBreakdown: data['ratingBreakdown'] is Map
          ? Map<String, double>.from(data['ratingBreakdown'])
          : null,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  @override
  List<Object?> get props => [
    id, name, specialty, photoUrl, rating, reviewsCount,
    consultationFee, isAvailable, isOnline, experienceYears, hospital,
    about, isVerified, isFeatured
  ];
}
