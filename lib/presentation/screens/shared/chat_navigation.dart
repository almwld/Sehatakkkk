import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatNavigation {
  static String _t(BuildContext context, String value) =>
      AppStrings.of(context).translate(value);

  static Future<void> openChat(BuildContext context, {required String doctorName, required String doctorId, String? doctorImage}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ToastService.showError(_t(context, 'يجب تسجيل الدخول أولاً')); return; }
    if (doctorId.trim().isEmpty) { ToastService.showError(_t(context, 'معرف الطبيب غير صالح')); return; }
    if (doctorId == user.uid) { ToastService.showError(_t(context, 'لا يمكنك بدء محادثة مع نفسك')); return; }
    try {
      final patientName = user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : _t(context, 'المريض');
      final chatId = await ChatService().createChat(
        doctorId: doctorId.trim(),
        doctorName: doctorName.trim().isNotEmpty ? doctorName.trim() : _t(context, 'الطبيب'),
        patientName: patientName,
        doctorImage: doctorImage,
        patientImage: user.photoURL,
      );
      if (!context.mounted) return;
      if (chatId.isEmpty) { ToastService.showError(_t(context, 'تعذر إنشاء المحادثة')); return; }
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(
        chatId: chatId,
        otherUserId: doctorId.trim(),
        otherUserName: doctorName.trim().isNotEmpty ? doctorName.trim() : _t(context, 'الطبيب'),
        groupImage: doctorImage,
        isGroup: false,
      )));
    } catch (e) { debugPrint('Open chat failed: $e'); if (context.mounted) ToastService.showError(_t(context, 'تعذر فتح المحادثة. حاول مرة أخرى.')); }
  }

  static Future<void> openCall(BuildContext context, {required String chatId, required String doctorName, required String doctorId, required bool isVideo}) async {
    final user = FirebaseAuth.instance.currentUser;
    final displayDoctorName = doctorName.trim().isNotEmpty
        ? doctorName.trim()
        : _t(context, 'الطبيب');
    if (user == null) { ToastService.showError(_t(context, 'يجب تسجيل الدخول أولاً')); return; }
    if (chatId.trim().isEmpty) { ToastService.showError(_t(context, 'لا توجد محادثة مرتبطة بهذه المكالمة')); return; }
    if (doctorId.trim().isEmpty || doctorId == user.uid) { ToastService.showError(_t(context, 'معرف الطرف الآخر غير صالح')); return; }
    try {
      final call = await CallService().initiateCall(chatId: chatId, receiverId: doctorId, receiverName: displayDoctorName, type: isVideo ? CallType.video : CallType.audio);
      if (!context.mounted) return;
      if (call == null || call.id.isEmpty) { ToastService.showError(_t(context, 'تعذر إنشاء المكالمة')); return; }
      await Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(chatId: chatId, doctorName: displayDoctorName, doctorId: doctorId, callId: call.id, isVideo: isVideo, isOutgoing: true)));
    } catch (e) { debugPrint('Start call failed: $e'); if (context.mounted) ToastService.showError(_t(context, 'تعذر بدء المكالمة. حاول مرة أخرى.')); }
  }
}
