import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatNavigation {
  static Future<void> openChat(
    BuildContext context, {
    required String doctorName,
    required String doctorId,
    String? doctorImage,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ يجب تسجيل الدخول أولاً'),
        ),
      );
      return;
    }

    if (doctorId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ معرف الطبيب غير صالح'),
        ),
      );
      return;
    }

    if (doctorId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ لا يمكنك بدء محادثة مع نفسك'),
        ),
      );
      return;
    }

    try {
      final patientName =
          user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : 'المريض';

      final chatService = ChatService();

      final chatId = await chatService.createChat(
        doctorId: doctorId.trim(),
        doctorName: doctorName.trim().isNotEmpty ? doctorName.trim() : 'الطبيب',
        patientId: user.uid,
        patientName: patientName,
        doctorImage: doctorImage,
        patientImage: user.photoURL,
      );

      if (!context.mounted) return;

      if (chatId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ تعذر إنشاء المحادثة'),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: chatId,
            userName:
                doctorName.trim().isNotEmpty ? doctorName.trim() : 'الطبيب',
            userId: doctorId.trim(),
            isDoctor: false,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل فتح المحادثة: $e'),
        ),
      );
    }
  }

  static void openCall(
    BuildContext context, {
    required String chatId,
    required String doctorName,
    required String doctorId,
    required bool isVideo,
  }) {
    if (chatId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ لا توجد محادثة مرتبطة بهذه المكالمة'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: chatId,
          doctorName: doctorName,
          doctorId: doctorId,
          isVideo: isVideo,
        ),
      ),
    );
  }
}
