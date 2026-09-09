import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatNavigation {
  static Future<void> openChat(BuildContext context, {required String doctorName, required String doctorId, String? doctorImage}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ToastService.showError('يجب تسجيل الدخول أولاً'); return; }
    if (doctorId.trim().isEmpty) { ToastService.showError('معرف الطبيب غير صالح'); return; }
    if (doctorId == user.uid) { ToastService.showError('لا يمكنك بدء محادثة مع نفسك'); return; }
    try {
      final patientName = user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : 'المريض';
      final chatId = await ChatService().createChat(doctorId: doctorId.trim(), doctorName: doctorName.trim().isNotEmpty ? doctorName.trim() : 'الطبيب', patientId: user.uid, patientName: patientName, doctorImage: doctorImage, patientImage: user.photoURL);
      if (!context.mounted) return;
      if (chatId.isEmpty) { ToastService.showError('تعذر إنشاء المحادثة'); return; }
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatId, userName: doctorName.trim().isNotEmpty ? doctorName.trim() : 'الطبيب', userId: doctorId.trim(), isDoctor: false)));
    } catch (e) { if (context.mounted) ToastService.showError('فشل فتح المحادثة: $e'); }
  }

  static Future<void> openCall(BuildContext context, {required String chatId, required String doctorName, required String doctorId, required bool isVideo}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ToastService.showError('يجب تسجيل الدخول أولاً'); return; }
    if (chatId.trim().isEmpty) { ToastService.showError('لا توجد محادثة مرتبطة بهذه المكالمة'); return; }
    if (doctorId.trim().isEmpty || doctorId == user.uid) { ToastService.showError('معرف الطرف الآخر غير صالح'); return; }
    try {
      final call = await CallService().initiateCall(chatId: chatId, receiverId: doctorId, receiverName: doctorName, type: isVideo ? CallType.video : CallType.audio);
      if (!context.mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(callId: call.id, chatId: chatId, isVideo: isVideo, isOutgoing: true)));
    } catch (e) { if (context.mounted) ToastService.showError('فشل بدء المكالمة: $e'); }
  }
}
