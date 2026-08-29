// ============================================================
// 🔐 مساعد الصلاحيات
// ============================================================

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // ============================================================
  // 📷 صلاحيات الكاميرا
  // ============================================================

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // ============================================================
  // 🎤 صلاحيات الميكروفون
  // ============================================================

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  // ============================================================
  // 📁 صلاحيات التخزين
  // ============================================================

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  // ============================================================
  // 📍 صلاحيات الموقع
  // ============================================================

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // ============================================================
  // 📱 صلاحيات الإشعارات
  // ============================================================

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // ============================================================
  // 📞 صلاحيات الاتصال
  // ============================================================

  static Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  static Future<bool> checkPhonePermission() async {
    final status = await Permission.phone.status;
    return status.isGranted;
  }

  // ============================================================
  // 🔄 صلاحيات متعددة
  // ============================================================

  static Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  static Future<Map<Permission, PermissionStatus>> checkPermissions(
    List<Permission> permissions,
  ) async {
    final result = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      result[permission] = await permission.status;
    }
    return result;
  }

  // ============================================================
  // 🎯 صلاحيات الدردشة
  // ============================================================

  static Future<bool> requestChatPermissions() async {
    final camera = await requestCameraPermission();
    final microphone = await requestMicrophonePermission();
    final storage = await requestStoragePermission();
    return camera && microphone && storage;
  }

  static Future<bool> checkChatPermissions() async {
    final camera = await checkCameraPermission();
    final microphone = await checkMicrophonePermission();
    final storage = await checkStoragePermission();
    return camera && microphone && storage;
  }

  // ============================================================
  // 🛠️ عرض حالة الصلاحيات
  // ============================================================

  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'ممنوحة ✅';
      case PermissionStatus.denied:
        return 'مرفوضة ❌';
      case PermissionStatus.restricted:
        return 'مقيدة ⚠️';
      case PermissionStatus.permanentlyDenied:
        return 'مرفوضة نهائياً 🚫';
      case PermissionStatus.limited:
        return 'محدودة 📌';
      default:
        return 'غير معروفة ❓';
    }
  }

  static bool isPermissionGranted(PermissionStatus status) {
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  // ============================================================
  // 🔄 فتح إعدادات التطبيق
  // ============================================================

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
