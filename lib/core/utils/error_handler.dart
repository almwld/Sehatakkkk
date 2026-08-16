import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  // ✅ عرض رسالة خطأ للمستخدم
  static void showError(BuildContext context, String message) {
    ToastService.showError(context, message,
                style: const TextStyle(fontSize: 14);
  }

  // ✅ عرض رسالة نجاح
  static void showSuccess(BuildContext context, String message) {
    ToastService.showSuccess(context, message,
                style: const TextStyle(fontSize: 14);
  }

  // ✅ عرض رسالة تحذير
  static void showWarning(BuildContext context, String message) {
    ToastService.showError(context, message,
                style: const TextStyle(fontSize: 14);
  }

  // ✅ عرض رسالة معلومات
  static void showInfo(BuildContext context, String message) {
    ToastService.showSuccess(context, message,
                style: const TextStyle(fontSize: 14);
  }

  // ✅ معالجة الأخطاء العامة
  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';
  }

  // ✅ معالجة أخطاء الاتصال
  static String getNetworkErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    }
    return getErrorMessage(error);
  }

  // ✅ معالجة أخطاء Firebase
  static String getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت';
      default:
        return 'حدث خطأ، يرجى المحاولة لاحقاً';
    }
  }
}
