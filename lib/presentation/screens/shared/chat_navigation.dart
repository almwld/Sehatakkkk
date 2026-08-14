import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatNavigation {
  static void openChat(
    BuildContext context, {
    required String doctorName,
    required String doctorId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          chatId: 'chat_${doctorId}_${DateTime.now().millisecondsSinceEpoch}',
          userName: doctorName,
          userId: doctorId,
          isDoctor: false,
        ),
      ),
    );
  }

  static void openCall(
    BuildContext context, {
    required String chatId,
    required String doctorName,
    required String doctorId,
    required bool isVideo,
  }) {
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
