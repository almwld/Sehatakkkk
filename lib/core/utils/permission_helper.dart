// ============================================================
// 🔐 مساعد الصلاحيات
// ============================================================

import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionHelper {
  static Future<bool> requestCameraPermission() async =>
      (await ph.Permission.camera.request()).isGranted;

  static Future<bool> checkCameraPermission() async =>
      (await ph.Permission.camera.status).isGranted;

  static Future<bool> requestMicrophonePermission() async =>
      (await ph.Permission.microphone.request()).isGranted;

  static Future<bool> checkMicrophonePermission() async =>
      (await ph.Permission.microphone.status).isGranted;

  static Future<bool> requestStoragePermission() async =>
      (await ph.Permission.storage.request()).isGranted;

  static Future<bool> checkStoragePermission() async =>
      (await ph.Permission.storage.status).isGranted;

  static Future<bool> requestLocationPermission() async =>
      (await ph.Permission.location.request()).isGranted;

  static Future<bool> checkLocationPermission() async =>
      (await ph.Permission.location.status).isGranted;

  static Future<bool> requestNotificationPermission() async =>
      (await ph.Permission.notification.request()).isGranted;

  static Future<bool> checkNotificationPermission() async =>
      (await ph.Permission.notification.status).isGranted;

  static Future<bool> requestPhonePermission() async =>
      (await ph.Permission.phone.request()).isGranted;

  static Future<bool> checkPhonePermission() async =>
      (await ph.Permission.phone.status).isGranted;

  static Future<Map<ph.Permission, ph.PermissionStatus>> requestPermissions(
    List<ph.Permission> permissions,
  ) => permissions.request();

  static Future<Map<ph.Permission, ph.PermissionStatus>> checkPermissions(
    List<ph.Permission> permissions,
  ) async {
    final result = <ph.Permission, ph.PermissionStatus>{};
    for (final permission in permissions) {
      result[permission] = await permission.status;
    }
    return result;
  }

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

  static String getPermissionStatusText(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return 'ممنوحة ✅';
      case ph.PermissionStatus.denied:
        return 'مرفوضة ❌';
      case ph.PermissionStatus.restricted:
        return 'مقيدة ⚠️';
      case ph.PermissionStatus.permanentlyDenied:
        return 'مرفوضة نهائياً 🚫';
      case ph.PermissionStatus.limited:
        return 'محدودة 📌';
      default:
        return 'غير معروفة ❓';
    }
  }

  static bool isPermissionGranted(ph.PermissionStatus status) =>
      status == ph.PermissionStatus.granted || status == ph.PermissionStatus.limited;

  static Future<bool> openAppSettings() => ph.openAppSettings();
}
