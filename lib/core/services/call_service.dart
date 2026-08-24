import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/presentation/screens/call/incoming_call_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ✅ بدء مكالمة
  Future<void> startCall({
    required String receiverId,
    required String callerName,
    required bool isVideo,
    required String chatId,
    required BuildContext context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول');
      return;
    }

    try {
      final callData = {
        'callerId': user.uid,
        'callerName': callerName,
        'receiverId': receiverId,
        'isVideo': isVideo,
        'chatId': chatId,
        'status': 'calling',
        'startedAt': FieldValue.serverTimestamp(),
        'participants': [user.uid, receiverId],
      };

      await _firestore.collection('calls').doc(chatId).set(callData);

      await _sendCallNotification(
        receiverId: receiverId,
        callerName: callerName,
        isVideo: isVideo,
        chatId: chatId,
        callerId: user.uid,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            chatId: chatId,
            doctorName: callerName,
            doctorId: user.uid,
            isVideo: isVideo,
          ),
        ),
      );
    } catch (e) {
      print('❌ Start call error: $e');
      ToastService.showError('❌ فشل بدء المكالمة: $e');
    }
  }

  // ✅ إرسال إشعار المكالمة
  Future<void> _sendCallNotification({
    required String receiverId,
    required String callerName,
    required bool isVideo,
    required String chatId,
    required String callerId,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(receiverId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        print('⚠️ No FCM token for user: $receiverId');
        return;
      }

      final payload = {
        'type': 'incoming_call',
        'callerName': callerName,
        'isVideo': isVideo.toString(),
        'chatId': chatId,
        'callerId': callerId,
      };

      await _sendFCMNotification(
        token: fcmToken,
        title: isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة واردة',
        body: 'من $callerName',
        data: payload,
      );

      print('✅ Call notification sent to $receiverId');
    } catch (e) {
      print('❌ Notification error: $e');
    }
  }

  // ✅ إرسال إشعار عبر FCM HTTP API
  Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${await _getFCMKey()}',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'call_ringtone',
          },
          'data': data,
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM notification sent successfully');
      } else {
        print('❌ FCM notification failed: ${response.body}');
      }
    } catch (e) {
      print('❌ FCM send error: $e');
    }
  }

  // ✅ الحصول على مفتاح FCM
  Future<String> _getFCMKey() async {
    // ✅ استخدم مفتاح الخادم من Firebase Console
    return 'YOUR_FCM_SERVER_KEY';
  }

  // ✅ معالجة المكالمة الواردة (تقبل RemoteMessage)
  void handleIncomingCall(BuildContext context, RemoteMessage message) {
    final data = message.data;
    final callerName = data['callerName'] ?? 'مستخدم';
    final isVideo = data['isVideo'] == 'true';
    final chatId = data['chatId'] ?? '';
    final callerId = data['callerId'] ?? '';

    final currentUser = _auth.currentUser;
    if (currentUser?.uid == callerId) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: callerName,
          callerId: callerId,
          isVideo: isVideo,
          chatId: chatId,
          onCallAnswered: (accepted) {
            _logCallResponse(chatId, accepted);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  // ✅ معالجة المكالمة الواردة (تقبل Map)
  void handleIncomingCallData(BuildContext context, Map<String, dynamic> data) {
    final callerName = data['callerName'] ?? 'مستخدم';
    final isVideo = data['isVideo'] == 'true';
    final chatId = data['chatId'] ?? '';
    final callerId = data['callerId'] ?? '';

    final currentUser = _auth.currentUser;
    if (currentUser?.uid == callerId) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callerName: callerName,
          callerId: callerId,
          isVideo: isVideo,
          chatId: chatId,
          onCallAnswered: (accepted) {
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

  // ✅ الحصول على سجل المكالمات
  Stream<List<Map<String, dynamic>>> getCallHistory(String userId) {
    return _firestore
        .collection('calls')
        .where('participants', arrayContains: userId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  // ✅ التحقق من مكالمة نشطة
  Future<bool> isCallActive(String chatId) async {
    try {
      final doc = await _firestore.collection('calls').doc(chatId).get();
      if (!doc.exists) return false;
      final status = doc.data()?['status'] as String?;
      return status == 'calling' || status == 'answered';
    } catch (e) {
      return false;
    }
  }

  // ✅ إلغاء مكالمة
  Future<void> cancelCall(String chatId) async {
    try {
      await _firestore.collection('calls').doc(chatId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Cancel call error: $e');
    }
  }

  // ✅ حذف سجل مكالمة
  Future<void> deleteCallHistory(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).delete();
    } catch (e) {
      print('❌ Delete call history error: $e');
    }
  }
}
