import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
  final bool isOnline;
  final Timestamp? lastSeen;
  final DateTime? createdAt;
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
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
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
      name: data['name'] ?? 'مستخدم',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      isDoctor: data['isDoctor'] ?? false,
      isPatient: data['isPatient'] ?? true,
      specialty: data['specialty'],
      hospital: data['hospital'],
      location: data['location'],
      rating: (data['rating'] as num?)?.toDouble(),
      reviewsCount: data['reviewsCount'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
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
      'isOnline': isOnline,
      'lastSeen': lastSeen ?? FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'fcmToken': fcmToken,
      'isVerified': isVerified,
      'blockedUsers': blockedUsers,
      'savedDoctors': savedDoctors,
    };
  }

  bool get isOnlineNow {
    if (!isOnline) return false;
    if (lastSeen == null) return false;
    final now = DateTime.now();
    final diff = now.difference(lastSeen!.toDate());
    return diff.inMinutes < 5;
  }

  @override
  List<Object?> get props => [
    id, email, phone, name, photoUrl, isDoctor, isOnline, lastSeen, fcmToken,
  ];
}
