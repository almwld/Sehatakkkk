import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // ✅ طلب جميع الأذونات المطلوبة
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.location,
      Permission.notifications,
      Permission.phone,
    ];

    final statuses = await permissions.request();
    return statuses;
  }

  // ✅ التحقق من أذونات المكالمات
  Future<bool> checkCallPermissions() async {
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    return camera.isGranted && microphone.isGranted;
  }

  // ✅ طلب أذونات المكالمات
  Future<bool> requestCallPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    return camera.isGranted && microphone.isGranted;
  }

  // ✅ التحقق من أذونات التخزين
  Future<bool> checkStoragePermissions() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  // ✅ طلب أذونات التخزين
  Future<bool> requestStoragePermissions() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // ✅ التحقق من أذونات الموقع
  Future<bool> checkLocationPermissions() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // ✅ طلب أذونات الموقع
  Future<bool> requestLocationPermissions() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // ✅ التحقق من أذونات الإشعارات
  Future<bool> checkNotificationPermissions() async {
    final status = await Permission.notifications.status;
    return status.isGranted;
  }

  // ✅ طلب أذونات الإشعارات
  Future<bool> requestNotificationPermissions() async {
    final status = await Permission.notifications.request();
    return status.isGranted;
  }
}
