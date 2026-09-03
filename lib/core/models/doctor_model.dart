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

  @override
  List<Object?> get props => [
    id, name, specialty, photoUrl, rating, reviewsCount,
    consultationFee, isAvailable, isOnline, experienceYears, hospital,
    about, isVerified, isFeatured
  ];
}
