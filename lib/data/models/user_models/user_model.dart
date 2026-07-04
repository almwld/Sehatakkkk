import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? address;
  final String? bloodType;
  final String? allergies;
  final String? chronicDiseases;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? weight;
  final String? height;
  final String? bloodPressure;
  final String? glucose;
  final String? medications;
  final String? age;
  final String? gender;
  final String? role;
  final bool isActive;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final List<Map<String, dynamic>> appointments;
  final List<Map<String, dynamic>> recentResults;
  final List<Map<String, dynamic>> prescriptions;
  final List<Map<String, dynamic>> medicalHistory;
  final List<Map<String, dynamic>> notifications;
  final Map<String, dynamic>? preferences;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.address,
    this.bloodType,
    this.allergies,
    this.chronicDiseases,
    this.emergencyContact,
    this.emergencyPhone,
    this.weight,
    this.height,
    this.bloodPressure,
    this.glucose,
    this.medications,
    this.age,
    this.gender,
    this.role = 'user',
    this.isActive = true,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.appointments = const [],
    this.recentResults = const [],
    this.prescriptions = const [],
    this.medicalHistory = const [],
    this.notifications = const [],
    this.preferences,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      address: data['address'],
      bloodType: data['bloodType'],
      allergies: data['allergies'],
      chronicDiseases: data['chronicDiseases'],
      emergencyContact: data['emergencyContact'],
      emergencyPhone: data['emergencyPhone'],
      weight: data['weight']?.toString(),
      height: data['height']?.toString(),
      bloodPressure: data['bloodPressure'],
      glucose: data['glucose']?.toString(),
      medications: data['medications']?.toString(),
      age: data['age']?.toString(),
      gender: data['gender'],
      role: data['role'] ?? 'user',
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      appointments: List<Map<String, dynamic>>.from(data['appointments'] ?? []),
      recentResults: List<Map<String, dynamic>>.from(data['recentResults'] ?? []),
      prescriptions: List<Map<String, dynamic>>.from(data['prescriptions'] ?? []),
      medicalHistory: List<Map<String, dynamic>>.from(data['medicalHistory'] ?? []),
      notifications: List<Map<String, dynamic>>.from(data['notifications'] ?? []),
      preferences: data['preferences'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'address': address,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'weight': weight,
      'height': height,
      'bloodPressure': bloodPressure,
      'glucose': glucose,
      'medications': medications,
      'age': age,
      'gender': gender,
      'role': role,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt ?? FieldValue.serverTimestamp(),
      'appointments': appointments,
      'recentResults': recentResults,
      'prescriptions': prescriptions,
      'medicalHistory': medicalHistory,
      'notifications': notifications,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? address,
    String? bloodType,
    String? allergies,
    String? chronicDiseases,
    String? emergencyContact,
    String? emergencyPhone,
    String? weight,
    String? height,
    String? bloodPressure,
    String? glucose,
    String? medications,
    String? age,
    String? gender,
    String? role,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    List<Map<String, dynamic>>? appointments,
    List<Map<String, dynamic>>? recentResults,
    List<Map<String, dynamic>>? prescriptions,
    List<Map<String, dynamic>>? medicalHistory,
    List<Map<String, dynamic>>? notifications,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      glucose: glucose ?? this.glucose,
      medications: medications ?? this.medications,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      appointments: appointments ?? this.appointments,
      recentResults: recentResults ?? this.recentResults,
      prescriptions: prescriptions ?? this.prescriptions,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
    );
  }

  // ✅ Getters
  String get fullName => name;
  String get displayName => name.isNotEmpty ? name : 'مستخدم';
  String get initial => name.isNotEmpty ? name[0] : 'م';
  String get ageText => age != null ? '$age سنة' : 'غير محدد';
  String get bloodTypeText => bloodType ?? 'غير محدد';
  String get genderText => gender ?? 'غير محدد';
  String get weightText => weight != null ? '$weight كجم' : 'غير محدد';
  String get heightText => height != null ? '$height سم' : 'غير محدد';
  String get bloodPressureText => bloodPressure ?? '--/--';
  String get glucoseText => glucose != null ? '$glucose mg/dL' : '--';
  String get medicationsText => medications ?? '0';

  @override
  List<Object?> get props => [
    uid, name, email, phone, photoUrl, address, bloodType, allergies,
    chronicDiseases, emergencyContact, emergencyPhone, weight, height,
    bloodPressure, glucose, medications, age, gender, role, isActive, isVerified,
    createdAt, updatedAt, lastLoginAt, appointments, recentResults,
    prescriptions, medicalHistory, notifications, preferences,
  ];

  static UserModel empty() {
    return const UserModel(
      uid: '',
      name: '',
      email: '',
      phone: '',
    );
  }
}
