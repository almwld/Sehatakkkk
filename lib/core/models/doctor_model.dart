import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel extends Equatable {
  final String id;

  /// Firebase Auth UID المرتبط بهذا الطبيب.
  /// للطبيب الجديد سيكون:
  /// doctors/{uid} + userId == uid
  final String? userId;

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
    this.userId,
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

  factory DoctorModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    List<Map<String, dynamic>> parseEducation(dynamic value) {
      if (value == null) return [];

      if (value is List) {
        return value.map((e) {
          if (e is Map<String, dynamic>) return e;
          if (e is String) return {'degree': e};
          return <String, dynamic>{};
        }).toList().cast<Map<String, dynamic>>();
      }

      if (value is String) {
        return [
          {'degree': value}
        ];
      }

      return [];
    }

    List<Map<String, dynamic>>? parseMapList(dynamic value) {
      if (value is! List) return null;

      return value.map((e) {
        if (e is Map<String, dynamic>) {
          return Map<String, dynamic>.from(e);
        }

        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }

        return <String, dynamic>{};
      }).toList();
    }

    List<String> parseStringList(dynamic value) {
      if (value == null) return [];

      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }

      if (value is String) {
        return [value];
      }

      return [];
    }

    Map<String, double>? parseRatingBreakdown(dynamic value) {
      if (value is! Map) return null;

      final result = <String, double>{};

      value.forEach((key, value) {
        if (value is num) {
          result[key.toString()] = value.toDouble();
        }
      });

      return result;
    }

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    return DoctorModel(
      id: id,

      // الهوية المرتبطة بحساب Firebase Auth.
      userId: data['userId']?.toString(),

      name: data['name']?.toString() ?? '',
      specialty: data['specialty']?.toString() ?? '',
      subspecialty: data['subspecialty']?.toString(),
      photoUrl: data['photoUrl']?.toString(),

      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: parseInt(data['reviewsCount']),
      consultationFee: (data['consultationFee'] as num?)?.toDouble(),

      isAvailable: data['isAvailable'] == true,
      isOnline: data['isOnline'] == true,

      experienceYears: parseInt(data['experienceYears']),

      hospital: data['hospital']?.toString(),
      clinicAddress: data['clinicAddress']?.toString(),
      about: data['about']?.toString(),

      languages: data['languages'] is List
          ? parseStringList(data['languages'])
          : null,

      services: parseStringList(data['services']),

      workingHours: data['workingHours'] is Map
          ? Map<String, dynamic>.from(data['workingHours'])
          : null,

      education: parseEducation(data['education']),

      certifications: parseMapList(data['certifications']),

      reviews: parseMapList(data['reviews']),

      isVerified: data['isVerified'] == true,

      patientsCount: parseInt(data['patientsCount']),

      specialties: data['specialties'] is List
          ? parseStringList(data['specialties'])
          : null,

      ratingBreakdown:
          parseRatingBreakdown(data['ratingBreakdown']),

      isFeatured: data['isFeatured'] == true,

      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
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

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        specialty,
        photoUrl,
        rating,
        reviewsCount,
        consultationFee,
        isAvailable,
        isOnline,
        experienceYears,
        hospital,
        about,
        isVerified,
        isFeatured,
      ];
}
