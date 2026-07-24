import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  patient,
  doctor,
  pharmacist,
  lab,
  hospital,
  nurse,
  midwife,
  physiotherapist,
  paramedic,
  delivery,
  service,
  veterinarian,
  admin,
  user,  // ✅ إضافة user كقيمة افتراضية
}

enum UserStatus {
  pending,
  active,
  blocked,
  rejected,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.role,
    this.status = UserStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  String get roleText {
    switch (role) {
      case UserRole.patient: return 'مريض';
      case UserRole.doctor: return 'طبيب';
      case UserRole.pharmacist: return 'صيدلي';
      case UserRole.lab: return 'مختبر';
      case UserRole.hospital: return 'مستشفى';
      case UserRole.nurse: return 'ممرض';
      case UserRole.midwife: return 'قابلة';
      case UserRole.physiotherapist: return 'معالج فيزيائي';
      case UserRole.paramedic: return 'مسعف';
      case UserRole.delivery: return 'موصل طلبات';
      case UserRole.service: return 'خدمي';
      case UserRole.veterinarian: return 'بيطري';
      case UserRole.admin: return 'مشرف';
      case UserRole.user: return 'مستخدم';
    }
  }

  String get statusText {
    switch (status) {
      case UserStatus.pending: return 'قيد المراجعة';
      case UserStatus.active: return 'نشط';
      case UserStatus.blocked: return 'محظور';
      case UserStatus.rejected: return 'مرفوض';
    }
  }

  Color get statusColor {
    switch (status) {
      case UserStatus.pending: return Colors.orange;
      case UserStatus.active: return Colors.green;
      case UserStatus.blocked: return Colors.red;
      case UserStatus.rejected: return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case UserStatus.pending: return Icons.hourglass_empty;
      case UserStatus.active: return Icons.verified;
      case UserStatus.blocked: return Icons.cancel;
      case UserStatus.rejected: return Icons.upload_file;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role'] ?? 'user'),
      status: _parseStatus(data['status'] ?? 'pending'),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      metadata: data['metadata'],
    );
  }

  static UserRole _parseRole(String value) {
    switch (value) {
      case 'doctor': return UserRole.doctor;
      case 'pharmacist': return UserRole.pharmacist;
      case 'lab': return UserRole.lab;
      case 'hospital': return UserRole.hospital;
      case 'nurse': return UserRole.nurse;
      case 'midwife': return UserRole.midwife;
      case 'physiotherapist': return UserRole.physiotherapist;
      case 'paramedic': return UserRole.paramedic;
      case 'delivery': return UserRole.delivery;
      case 'service': return UserRole.service;
      case 'veterinarian': return UserRole.veterinarian;
      case 'admin': return UserRole.admin;
      case 'user': return UserRole.user;
      default: return UserRole.patient;
    }
  }

  static UserStatus _parseStatus(String value) {
    switch (value) {
      case 'active': return UserStatus.active;
      case 'blocked': return UserStatus.blocked;
      case 'rejected': return UserStatus.rejected;
      default: return UserStatus.pending;
    }
  }
}
