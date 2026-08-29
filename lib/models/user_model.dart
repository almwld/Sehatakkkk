// ============================================================
// 📦 نموذج المستخدم المتكامل
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // ============================================================
  // 🏷️ البيانات الأساسية
  // ============================================================

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;
  final String role; // 'doctor', 'patient', 'admin'
  final String? specialty;
  final String? licenseNumber;
  final int? experience;
  final double? rating;
  final int? totalReviews;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bio;
  final String? location;
  final String? gender;
  final DateTime? birthDate;
  final String? bloodType;
  final List<String> allergies;
  final List<String> medicalHistory;
  final List<String> languages;
  final Map<String, dynamic> settings;
  final bool isVerified;
  final bool isActive;
  final String? deviceToken;

  // ============================================================
  // 🏗️ المنشئ
  // ============================================================

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.imageUrl,
    required this.role,
    this.specialty,
    this.licenseNumber,
    this.experience,
    this.rating,
    this.totalReviews,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    this.bio,
    this.location,
    this.gender,
    this.birthDate,
    this.bloodType,
    this.allergies = const [],
    this.medicalHistory = const [],
    this.languages = const [],
    this.settings = const {},
    this.isVerified = false,
    this.isActive = true,
    this.deviceToken,
  });

  // ============================================================
  // 🔄 التحويل من/إلى Map
  // ============================================================

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      imageUrl: map['imageUrl'],
      role: map['role'] ?? 'patient',
      specialty: map['specialty'],
      licenseNumber: map['licenseNumber'],
      experience: map['experience'],
      rating: map['rating']?.toDouble(),
      totalReviews: map['totalReviews'],
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: map['bio'],
      location: map['location'],
      gender: map['gender'],
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      bloodType: map['bloodType'],
      allergies: List<String>.from(map['allergies'] ?? []),
      medicalHistory: List<String>.from(map['medicalHistory'] ?? []),
      languages: List<String>.from(map['languages'] ?? []),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      deviceToken: map['deviceToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'role': role,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'experience': experience,
      'rating': rating,
      'totalReviews': totalReviews,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'bio': bio,
      'location': location,
      'gender': gender,
      'birthDate': birthDate,
      'bloodType': bloodType,
      'allergies': allergies,
      'medicalHistory': medicalHistory,
      'languages': languages,
      'settings': settings,
      'isVerified': isVerified,
      'isActive': isActive,
      'deviceToken': deviceToken,
    };
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';
  bool get isAdmin => role == 'admin';

  String get displayName => name;
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.isNotEmpty ? name[0] : 'م';
  }

  String get age {
    if (birthDate == null) return '';
    final now = DateTime.now();
    final years = now.year - birthDate!.year;
    return '$years سنة';
  }

  String get formattedRating {
    if (rating == null) return '0.0';
    return rating!.toStringAsFixed(1);
  }

  String get statusText {
    if (isOnline) return 'متصل';
    if (lastSeen == null) return 'غير متصل';
    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return 'منذ ${diff.inDays ~/ 7} أسبوع';
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    bool? isOnline,
    DateTime? lastSeen,
    String? bio,
    String? location,
    double? rating,
    int? totalReviews,
    bool? isVerified,
    bool? isActive,
    String? deviceToken,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role,
      specialty: specialty,
      licenseNumber: licenseNumber,
      experience: experience,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      bio: bio ?? this.bio,
      location: location ?? this.location,
      gender: gender,
      birthDate: birthDate,
      bloodType: bloodType,
      allergies: allergies,
      medicalHistory: medicalHistory,
      languages: languages,
      settings: settings,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }
}
