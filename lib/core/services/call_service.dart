// ============================================================
// 📞 خدمة المكالمات
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInCall = false;
  String? _currentCallId;

  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;
  String? get currentUserId => _auth.currentUser?.uid;

  String _getUserIdOrThrow() {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');
    return userId;
  }

  Stream<List<CallModel>> streamCallHistory({int limit = 50}) => _firestore
      .collection('calls')
      .where('participants', arrayContains: _getUserIdOrThrow())
      .orderBy('startedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CallModel.fromFirestore(doc.id, doc.data()))
          .toList());

  Stream<CallModel?> streamCall(String callId) => _firestore
      .collection('calls')
      .doc(callId)
      .snapshots()
      .map((doc) => doc.exists ? CallModel.fromFirestore(doc.id, doc.data()!) : null);

  Future<CallModel?> initiateCall({
    required String receiverId,
    required String receiverName,
    String? receiverPhotoUrl,
    required CallType type,
    required String chatId,
    String? idempotencyKey,
  }) async {
    final userId = _getUserIdOrThrow();
    final user = _auth.currentUser!;
    final callId = idempotencyKey ?? _firestore.collection('calls').doc().id;
    final callRef = _firestore.collection('calls').doc(callId);
    final existing = await callRef.get();
    if (existing.exists) return CallModel.fromFirestore(callId, existing.data()!);

    final roomName = 'call_$callId';
    final data = <String, dynamic>{
      'id': callId,
      'chatId': chatId,
      'callerId': userId,
      'callerName': user.displayName ?? 'مستخدم',
      'callerPhotoUrl': user.photoURL,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPhotoUrl': receiverPhotoUrl,
      'callType': type.name,
      'status': CallStatus.calling.name,
      'startedAt': FieldValue.serverTimestamp(),
      'isAnswered': false,
      'participants': [userId, receiverId],
      'liveKitRoomName': roomName,
      'roomName': roomName,
      'isVideoCall': type == CallType.video,
    };

    await callRef.set(data);
    _isInCall = true;
    _currentCallId = callId;
    return CallModel.fromFirestore(callId, data);
  }

  Future<void> acceptCall(String callId) async => _updateCallState(
        callId,
        allowed: const [CallStatus.calling, CallStatus.ringing],
        data: {
          'status': CallStatus.connected.name,
          'isAnswered': true,
          'connectedAt': FieldValue.serverTimestamp(),
        },
        active: true,
      );

  Future<void> rejectCall(String callId) async => _updateCallState(
        callId,
        allowed: const [CallStatus.calling, CallStatus.ringing],
        data: {'status': CallStatus.rejected.name, 'endedAt': FieldValue.serverTimestamp()},
        active: false,
      );

  Future<void> cancelCall(String callId) async => _updateCallState(
        callId,
        allowed: const [CallStatus.calling, CallStatus.ringing],
        data: {'status': CallStatus.cancelled.name, 'endedAt': FieldValue.serverTimestamp()},
        active: false,
      );

  Future<void> endCall(String callId, {int? durationSeconds}) async => _updateCallState(
        callId,
        allowed: const [CallStatus.calling, CallStatus.ringing, CallStatus.connected],
        data: {
          'status': CallStatus.ended.name,
          'endedAt': FieldValue.serverTimestamp(),
          'durationSeconds': durationSeconds,
        },
        active: false,
      );

  Future<void> missCall(String callId) async => _updateCallState(
        callId,
        allowed: const [CallStatus.calling, CallStatus.ringing],
        data: {'status': CallStatus.missed.name, 'endedAt': FieldValue.serverTimestamp()},
        active: false,
        ignoreInvalidState: true,
      );

  Future<void> _updateCallState(
    String callId, {
    required List<CallStatus> allowed,
    required Map<String, dynamic> data,
    required bool active,
    bool ignoreInvalidState = false,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _firestore.collection('calls').doc(callId);
      final doc = await transaction.get(ref);
      if (!doc.exists) return;
      final rawStatus = doc.data()?['status'] as String?;
      final current = CallStatus.values.firstWhere(
        (value) => value.name == rawStatus,
        orElse: () => CallStatus.calling,
      );
      if (!allowed.contains(current)) {
        if (ignoreInvalidState) return;
        throw Exception('لا يمكن تغيير حالة المكالمة الحالية');
      }
      transaction.update(ref, data);
    });
    _isInCall = active;
    _currentCallId = active ? callId : null;
  }

  void handleIncomingCall(BuildContext context, RemoteMessage message) {
    final callId = message.data['callId'] ?? message.data['id'];
    final callerName = message.data['callerName'] ?? 'مستخدم';
    final callerId = message.data['callerId'] ?? 'unknown';
    final chatId = message.data['chatId'] ?? 'call_$callId';
    final isVideo = message.data['isVideo'] == 'true';
    if (callId == null || callId.isEmpty) {
      ToastService.showError('❌ لا يمكن معالجة المكالمة');
      return;
    }
    ToastService.showInfo('📞 مكالمة واردة من $callerName');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: chatId,
          doctorName: callerName,
          doctorId: callerId,
          isVideo: isVideo,
          callId: callId,
          isOutgoing: false,
        ),
      ),
    );
  }

  void dispose() {
    _isInCall = false;
    _currentCallId = null;
  }
}
