import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/call/incoming_call_screen.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ بدء مكالمة
  Future<void> startCall({
    required String receiverId,
    required String callerName,
    required bool isVideo,
    required String chatId,
    required BuildContext context,
  }) async {
    try {
      final user = _auth.currentUser;
      final callData = {
        'callerId': user?.uid ?? '',
        'callerName': callerName,
        'receiverId': receiverId,
        'isVideo': isVideo,
        'chatId': chatId,
        'status': 'calling',
        'startedAt': FieldValue.serverTimestamp(),
        'callId': chatId,
      };

      // ✅ حفظ معلومات المكالمة في Firestore
      await _firestore.collection('calls').doc(chatId).set(callData);

      // ✅ إرسال إشعار للمستقبل
      await _sendCallNotification(
        receiverId: receiverId,
        callerName: callerName,
        isVideo: isVideo,
        chatId: chatId,
      );

      // ✅ بدء المكالمة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            chatId: chatId,
            doctorName: callerName,
            doctorId: user?.uid ?? '',
            isVideo: isVideo,
          ),
        ),
      );
    } catch (e) {
      print('❌ Start call error: $e');
      rethrow;
    }
  }

  // ✅ إرسال إشعار المكالمة
  Future<void> _sendCallNotification({
    required String receiverId,
    required String callerName,
    required bool isVideo,
    required String chatId,
  }) async {
    try {
      // ✅ الحصول على توكن المستخدم
      final userDoc = await _firestore.collection('users').doc(receiverId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        // ✅ إرسال الإشعار عبر FCM
        final message = RemoteMessage(
          notification: RemoteNotification(
            title: '📞 مكالمة ${isVideo ? 'فيديو' : 'صوتية'} واردة',
            body: 'من $callerName',
          ),
          data: {
            'type': 'incoming_call',
            'callerName': callerName,
            'isVideo': isVideo.toString(),
            'chatId': chatId,
            'callerId': _auth.currentUser?.uid ?? '',
          },
        );

        // ✅ إرسال الإشعار
        await FirebaseMessaging.instance.sendMessage(
          to: fcmToken,
          message: message,
        );
      }
    } catch (e) {
      print('❌ Notification error: $e');
    }
  }

  // ✅ معالجة المكالمة الواردة
  void handleIncomingCall(BuildContext context, RemoteMessage message) {
    final data = message.data;
    final callerName = data['callerName'] ?? 'مستخدم';
    final isVideo = data['isVideo'] == 'true';
    final chatId = data['chatId'] ?? '';
    final callerId = data['callerId'] ?? '';

    // ✅ عرض شاشة المكالمة الواردة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: callerName,
          callerId: callerId,
          isVideo: isVideo,
          chatId: chatId,
          onCallAnswered: (accepted) {
            // ✅ تسجيل الرد على المكالمة
            _logCallResponse(chatId, accepted);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  // ✅ تسجيل الرد على المكالمة
  Future<void> _logCallResponse(String chatId, bool accepted) async {
    try {
      await _firestore.collection('calls').doc(chatId).update({
        'status': accepted ? 'answered' : 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Log call response error: $e');
    }
  }

  // ✅ تسجيل مكالمة منتهية
  Future<void> endCall(String chatId, int duration) async {
    try {
      await _firestore.collection('calls').doc(chatId).update({
        'status': 'ended',
        'duration': duration,
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ End call error: $e');
    }
  }
}
