// ============================================================
// 📁 lib/core/services/permission_service.dart
// 🔐 صلاحيات المستخدمين
// ============================================================

import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // ============================================================
  // 📱 أذونات الجهاز
  // ============================================================
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.location,
      Permission.notification,
      Permission.phone,
    ];

    final statuses = await permissions.request();
    return statuses;
  }

  Future<bool> checkCallPermissions() async {
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    return camera.isGranted && microphone.isGranted;
  }

  Future<bool> requestCallPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    return camera.isGranted && microphone.isGranted;
  }

  Future<bool> checkStoragePermissions() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  Future<bool> requestStoragePermissions() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> checkLocationPermissions() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> requestLocationPermissions() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> checkNotificationPermissions() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // ============================================================
  // 👤 صلاحيات المستخدم
  // ============================================================
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> isDoctor() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final role = doc.data()?['role'] as String?;
      return role == 'doctor' || role == 'طبيب';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final role = doc.data()?['role'] as String?;
      return role == 'admin' || role == 'مشرف';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isPharmacist() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final role = doc.data()?['role'] as String?;
      return role == 'pharmacist' || role == 'صيدلي';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canCreatePosts() async {
    return await isDoctor() || await isAdmin();
  }

  static Future<bool> canEditOthersPosts() async {
    return await isAdmin();
  }

  static Future<bool> canDeleteOthersPosts() async {
    return await isAdmin();
  }

  static Future<String> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'guest';

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return 'guest';

      return doc.data()?['role'] as String? ?? 'guest';
    } catch (e) {
      return 'guest';
    }
  }
}
