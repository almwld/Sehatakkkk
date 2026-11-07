import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class DoctorModel extends Equatable {
  final String id;
  final String? userId;
  final String name;
  final String? nameEn;
  final String? nameFr;
  final String specialty;
  final String? specialtyEn;
  final String? specialtyFr;
  final String? subspecialty;
  final String? subspecialtyEn;
  final String? subspecialtyFr;
  final String? photoUrl;
  final double? rating;
  final int? reviewsCount;
  final double? consultationFee;
  final bool isAvailable;
  final bool isOnline;
  final int? experienceYears;
  final String? hospital;
  final String? hospitalEn;
  final String? hospitalFr;
  final String? clinicAddress;
  final String? clinicAddressEn;
  final String? clinicAddressFr;
  final String? about;
  final String? aboutEn;
  final String? aboutFr;
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
    this.nameEn,
    this.nameFr,
    required this.specialty,
    this.specialtyEn,
    this.specialtyFr,
    this.subspecialty,
    this.subspecialtyEn,
    this.subspecialtyFr,
    this.photoUrl,
    this.rating,
    this.reviewsCount,
    this.consultationFee,
    this.isAvailable = false,
    this.isOnline = false,
    this.experienceYears,
    this.hospital,
    this.hospitalEn,
    this.hospitalFr,
    this.clinicAddress,
    this.clinicAddressEn,
    this.clinicAddressFr,
    this.about,
    this.aboutEn,
    this.aboutFr,
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
    List<Map<String, dynamic>> parseMapList(dynamic value) {
      if (value is! List) return [];
      return value
          .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .toList();
    }

    List<String> parseStringList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.trim().isNotEmpty) return [value.trim()];
      return [];
    }

    int? parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    double? parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }

    Map<String, double>? parseRatingBreakdown(dynamic value) {
      if (value is! Map) return null;
      final result = <String, double>{};
      value.forEach((key, item) {
        final parsed = parseDouble(item);
        if (parsed != null) result[key.toString()] = parsed;
      });
      return result.isEmpty ? null : result;
    }

    final rawReviewsCount = data['reviewsCount'] ?? data['reviewCount'];
    final rawFee = data['consultationFee'] ?? data['fee'];
    final rawExperience = data['experienceYears'] ?? data['experience'];
    final resolvedUserId = (data['userId'] ?? data['uid'] ?? id).toString().trim();
    final resolvedPhotoUrl = ImageKit.doctorPhoto(data);

    return DoctorModel(
      id: id,
      userId: resolvedUserId.isEmpty ? null : resolvedUserId,
      name: data['name']?.toString() ?? '',
      nameEn: data['nameEn']?.toString(),
      nameFr: data['nameFr']?.toString(),
      specialty: data['specialty']?.toString() ?? '',
      specialtyEn: data['specialtyEn']?.toString(),
      specialtyFr: data['specialtyFr']?.toString(),
      subspecialty: data['subspecialty']?.toString(),
      subspecialtyEn: data['subspecialtyEn']?.toString(),
      subspecialtyFr: data['subspecialtyFr']?.toString(),
      photoUrl: resolvedPhotoUrl,
      rating: parseDouble(data['rating']),
      reviewsCount: parseInt(rawReviewsCount),
      consultationFee: parseDouble(rawFee),
      isAvailable: parseBool(data['isAvailable']),
      isOnline: parseBool(data['isOnline']),
      experienceYears: parseInt(rawExperience),
      hospital: data['hospital']?.toString(),
      hospitalEn: data['hospitalEn']?.toString(),
      hospitalFr: data['hospitalFr']?.toString(),
      clinicAddress: data['clinicAddress']?.toString(),
      clinicAddressEn: data['clinicAddressEn']?.toString(),
      clinicAddressFr: data['clinicAddressFr']?.toString(),
      about: data['about']?.toString(),
      aboutEn: data['aboutEn']?.toString(),
      aboutFr: data['aboutFr']?.toString(),
      languages: data.containsKey('languages') ? parseStringList(data['languages']) : null,
      services: parseStringList(data['services']),
      workingHours: data['workingHours'] is Map ? Map<String, dynamic>.from(data['workingHours']) : null,
      education: parseMapList(data['education']),
      certifications: parseMapList(data['certifications']),
      reviews: parseMapList(data['reviews']),
      isVerified: parseBool(data['isVerified']),
      patientsCount: parseInt(data['patientsCount']),
      specialties: data.containsKey('specialties') ? parseStringList(data['specialties']) : null,
      ratingBreakdown: parseRatingBreakdown(data['ratingBreakdown']),
      isFeatured: parseBool(data['isFeatured']),
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'name': name,
        'nameEn': nameEn,
        'nameFr': nameFr,
        'specialty': specialty,
        'specialtyEn': specialtyEn,
        'specialtyFr': specialtyFr,
        'subspecialty': subspecialty,
        'subspecialtyEn': subspecialtyEn,
        'subspecialtyFr': subspecialtyFr,
        'photoUrl': photoUrl,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'consultationFee': consultationFee,
        'isAvailable': isAvailable,
        'isOnline': isOnline,
        'experienceYears': experienceYears,
        'hospital': hospital,
        'hospitalEn': hospitalEn,
        'hospitalFr': hospitalFr,
        'clinicAddress': clinicAddress,
        'clinicAddressEn': clinicAddressEn,
        'clinicAddressFr': clinicAddressFr,
        'about': about,
        'aboutEn': aboutEn,
        'aboutFr': aboutFr,
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

  String localized(String field, String languageCode) {
    final language = languageCode.toLowerCase();
    final value = language == 'en'
        ? {'name': nameEn, 'specialty': specialtyEn, 'subspecialty': subspecialtyEn, 'hospital': hospitalEn, 'clinicAddress': clinicAddressEn, 'about': aboutEn}[field]
        : language == 'fr'
            ? {'name': nameFr, 'specialty': specialtyFr, 'subspecialty': subspecialtyFr, 'hospital': hospitalFr, 'clinicAddress': clinicAddressFr, 'about': aboutFr}[field]
            : null;
    final fallback = {'name': name, 'specialty': specialty, 'subspecialty': subspecialty, 'hospital': hospital, 'clinicAddress': clinicAddress, 'about': about}[field];
    final selected = value?.toString().trim() ?? '';
    return selected.isNotEmpty ? selected : (fallback ?? '').toString();
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        nameEn,
        nameFr,
        specialty,
        specialtyEn,
        specialtyFr,
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
