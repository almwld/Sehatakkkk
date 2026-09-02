// ============================================================
// 📊 UserModel - نموذج المستخدم
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final String? photoUrl;
  final String? bio;
  final bool isDoctor;
  final bool isPatient;
  final String? specialty;
  final String? hospital;
  final String? location;
  final double? rating;
  final int? reviewsCount;
  final double? consultationFee;
  final bool isAvailable;
  final bool isOnline;
  final Timestamp? lastSeen;
  final DateTime? createdAt;
  final Map<String, dynamic>? preferences;
  final List<String>? languages;
  final String? fcmToken;
  final bool isVerified;
  final List<String>? blockedUsers;
  final List<String>? savedDoctors;

  const UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    this.photoUrl,
    this.bio,
    this.isDoctor = false,
    this.isPatient = true,
    this.specialty,
    this.hospital,
    this.location,
    this.rating,
    this.reviewsCount,
    this.consultationFee,
    this.isAvailable = false,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
    this.preferences,
    this.languages,
    this.fcmToken,
    this.isVerified = false,
    this.blockedUsers,
    this.savedDoctors,
  });

  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'],
      phone: data['phone'],
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      isDoctor: data['isDoctor'] ?? false,
      isPatient: data['isPatient'] ?? true,
      specialty: data['specialty'],
      hospital: data['hospital'],
      location: data['location'],
      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'],
      consultationFee: (data['consultationFee'] as num?)?.toDouble(),
      isAvailable: data['isAvailable'] ?? false,
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      languages: List<String>.from(data['languages'] ?? []),
      fcmToken: data['fcmToken'],
      isVerified: data['isVerified'] ?? false,
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
      savedDoctors: List<String>.from(data['savedDoctors'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone': phone,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'isDoctor': isDoctor,
      'isPatient': isPatient,
      'specialty': specialty,
      'hospital': hospital,
      'location': location,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'isOnline': isOnline,
      'lastSeen': lastSeen ?? FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'preferences': preferences,
      'languages': languages,
      'fcmToken': fcmToken,
      'isVerified': isVerified,
      'blockedUsers': blockedUsers,
      'savedDoctors': savedDoctors,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? photoUrl,
    String? bio,
    bool? isDoctor,
    bool? isPatient,
    String? specialty,
    String? hospital,
    String? location,
    double? rating,
    int? reviewsCount,
    double? consultationFee,
    bool? isAvailable,
    bool? isOnline,
    Timestamp? lastSeen,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
    List<String>? languages,
    String? fcmToken,
    bool? isVerified,
    List<String>? blockedUsers,
    List<String>? savedDoctors,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      isDoctor: isDoctor ?? this.isDoctor,
      isPatient: isPatient ?? this.isPatient,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      languages: languages ?? this.languages,
      fcmToken: fcmToken ?? this.fcmToken,
      isVerified: isVerified ?? this.isVerified,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      savedDoctors: savedDoctors ?? this.savedDoctors,
    );
  }

  @override
  List<Object?> get props => [
    id, email, phone, name, photoUrl, bio, isDoctor, isPatient,
    specialty, hospital, location, rating, reviewsCount, consultationFee,
    isAvailable, isOnline, lastSeen, createdAt, preferences, languages,
    fcmToken, isVerified, blockedUsers, savedDoctors,
  ];

  // ✅ المساعدات
  bool get isOnlineNow {
    if (!isOnline) return false;
    if (lastSeen == null) return false;
    final now = DateTime.now();
    final diff = now.difference(lastSeen!.toDate());
    return diff.inMinutes < 5;
  }
  String getDisplayName() => name;
  String getInitials() {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
  bool isBlocked(String userId) => blockedUsers?.contains(userId) ?? false;
}
