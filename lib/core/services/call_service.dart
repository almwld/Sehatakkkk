import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/call_model.dart';
import 'notification_service.dart';

enum CallType { audio, video }
enum CallStatus { calling, ringing, connected, ended, missed, rejected, busy }

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // 📞 بدء مكالمة
  // ============================================================
  Future<CallModel?> initiateCall({
    required String receiverId,
    required String receiverName,
    String? receiverPhotoUrl,
    required CallType type,
    required String chatId,
  }) async {
    final userId = currentUserId;
    final user = _auth.currentUser;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    final callId = _firestore.collection('calls').doc().id;
    final now = FieldValue.serverTimestamp();

    final callData = {
      'id': callId,
      'chatId': chatId,
      'callerId': userId,
      'callerName': user?.displayName ?? 'مستخدم',
      'callerPhotoUrl': user?.photoURL,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhotoUrl': receiverPhotoUrl,
      'type': type.name,
      'status': CallStatus.calling.name,
      'startedAt': now,
      'isAnswered': false,
      'participants': [userId, receiverId],
      'roomName': 'call_${chatId}_${DateTime.now().millisecondsSinceEpoch}',
    };

    await _firestore.collection('calls').doc(callId).set(callData);

    // ✅ إرسال إشعار للمستقبل
    await _notificationService.sendNotification(
      userId: receiverId,
      title: type == CallType.video ? '📹 مكالمة فيديو' : '📞 مكالمة صوتية',
      body: '${user?.displayName ?? "مستخدم"} يتصل بك',
      data: {
        'type': 'incoming_call',
        'callId': callId,
        'chatId': chatId,
        'callerId': userId,
        'callerName': user?.displayName ?? 'مستخدم',
        'isVideo': type == CallType.video ? 'true' : 'false',
      },
    );

    final doc = await _firestore.collection('calls').doc(callId).get();
    return CallModel.fromFirestore(callId, doc.data()!);
  }

  // ============================================================
  // ✅ قبول المكالمة
  // ============================================================
  Future<void> acceptCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': CallStatus.connected.name,
      'isAnswered': true,
      'connectedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ❌ رفض المكالمة
  // ============================================================
  Future<void> declineCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': CallStatus.rejected.name,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // 🔚 إنهاء المكالمة
  // ============================================================
  Future<void> endCall(String callId, {int? durationSeconds}) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': CallStatus.ended.name,
      'endedAt': FieldValue.serverTimestamp(),
      'durationSeconds': durationSeconds,
    });
  }

  // ============================================================
  // ⏰ تفويت المكالمة (مهلة)
  // ============================================================
  Future<void> missCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': CallStatus.missed.name,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // 📋 الاستماع لمكالمة محددة
  // ============================================================
  Stream<CallModel?> streamCall(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((doc) => doc.exists ? CallModel.fromFirestore(doc.id, doc.data()!) : null);
  }

  // ============================================================
  // 📋 الاستماع لسجل المكالمات
  // ============================================================
  Stream<List<CallModel>> streamCallHistory() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('calls')
        .where('participants', arrayContains: userId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CallModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ============================================================
  // 📞 معالجة مكالمة واردة (من FCM)
  // ============================================================
  void handleIncomingCall(BuildContext context, Map<String, dynamic> data) {
    final callId = data['callId'];
    final chatId = data['chatId'];
    final callerId = data['callerId'];
    final callerName = data['callerName'] ?? 'متصل';
    final isVideo = data['isVideo'] == 'true';

    if (callId == null || chatId == null) return;

    // ✅ فتح شاشة المكالمة الواردة
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => IncomingCallScreen(
          callId: callId,
          chatId: chatId,
          callerId: callerId,
          callerName: callerName,
          isVideo: isVideo,
          onAccept: () => acceptCall(callId),
          onReject: () => declineCall(callId),
          onTimeout: () => missCall(callId),
        ),
      ),
    );
  }
}
