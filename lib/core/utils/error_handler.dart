import 'package:flutter/material.dart';
import 'package:sehatak/core/services/toast_service.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) => ToastService.showError(context, message);
  static void showSuccess(BuildContext context, String message) => ToastService.showSuccess(context, message);
  static void showWarning(BuildContext context, String message) => ToastService.showWarning(context, message);
  static void showInfo(BuildContext context, String message) => ToastService.showInfo(context, message);

  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString().replaceFirst('Exception: ', '');
    return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';
  }

  static String getNetworkErrorMessage(dynamic error) {
    final text = error.toString();
    if (text.contains('SocketException')) return 'لا يوجد اتصال بالإنترنت';
    if (text.contains('TimeoutException')) return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    return getErrorMessage(error);
  }

  static String getFirebaseErrorMessage(String code) => switch (code) {
    'user-not-found' => 'المستخدم غير موجود',
    'wrong-password' => 'كلمة المرور غير صحيحة',
    'email-already-in-use' => 'البريد الإلكتروني مستخدم بالفعل',
    'invalid-email' => 'البريد الإلكتروني غير صحيح',
    'weak-password' => 'كلمة المرور ضعيفة جداً',
    'too-many-requests' => 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً',
    'network-request-failed' => 'فشل الاتصال بالإنترنت',
    _ => 'حدث خطأ، يرجى المحاولة لاحقاً',
  };
}
