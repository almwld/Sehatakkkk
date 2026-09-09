// ============================================================
// 📞 خدمة المكالمات
// ============================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/incoming_call_screen.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
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

  Future<T> _withFirestoreRetry<T>(Future<T> Function() operation) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await operation();
      } on FirebaseException catch (e) {
        lastError = e;
        final retryable = e.code == 'unavailable' || e.code == 'deadline-exceeded' || e.code == 'aborted';
        if (!retryable || attempt == 2) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 350 * pow(2, attempt).toInt()));
      }
    }
    throw lastError ?? Exception('فشل الوصول إلى Firestore');
  }

  Stream<List<CallModel>> streamCallHistory({int limit = 50}) => _firestore
      .collection('calls')
      .where('participants', arrayContains: _getUserIdOrThrow())
      .orderBy('startedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => CallModel.fromFirestore(doc.id, doc.data())).toList());

  Stream<CallModel?> streamCall(String callId) => _firestore
      .collection('calls')
      .doc(callId)
      .snapshots()
      .map((doc) => doc.exists ? CallModel.fromFirestore(doc.id, doc.data()!) : null);

  Future<void> _addCallSystemMessage({required String chatId, required String callId, required String text, required String status, required CallType type}) async {
    if (chatId.trim().isEmpty) return;
    try {
      await _withFirestoreRetry(() => _chatService.sendSystemMessage(
        chatId: chatId,
        text: text,
        idempotencyKey: 'call_${callId}_$status',
        metadata: {'callId': callId, 'callType': type.name, 'status': status},
      ));
    } catch (e) {
      debugPrint('Call timeline message failed: $e');
    }
  }

  Future<CallModel?> initiateCall({required String receiverId, required String receiverName, String? receiverPhotoUrl, required CallType type, required String chatId, String? idempotencyKey}) async {
    final userId = _getUserIdOrThrow();
    final user = _auth.currentUser!;
    if (chatId.trim().isEmpty) throw Exception('معرّف المحادثة غير صالح');
    if (receiverId.trim().isEmpty || receiverId == userId) throw Exception('معرّف المستقبل غير صالح');

    final callId = idempotencyKey ?? _firestore.collection('calls').doc().id;
    final callRef = _firestore.collection('calls').doc(callId);
    final existing = await _withFirestoreRetry(() => callRef.get());
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

    await _withFirestoreRetry(() => callRef.set(data));
    _isInCall = true;
    _currentCallId = callId;
    await _addCallSystemMessage(chatId: chatId, callId: callId, text: type == CallType.video ? '📹 بدء مكالمة فيديو' : '📞 بدء مكالمة صوتية', status: CallStatus.calling.name, type: type);
    return CallModel.fromFirestore(callId, data);
  }

  Future<void> acceptCall(String callId) async {
    final result = await _updateCallState(callId, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.connected.name, 'isAnswered': true, 'connectedAt': FieldValue.serverTimestamp()}, active: true);
    if (result == null) return;
    await _addCallSystemMessage(chatId: result.chatId, callId: callId, text: result.type == CallType.video ? '📹 تم الاتصال بالفيديو' : '📞 تم الاتصال', status: CallStatus.connected.name, type: result.type);
  }

  Future<void> rejectCall(String callId) async {
    final result = await _updateCallState(callId, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.rejected.name, 'endedAt': FieldValue.serverTimestamp()}, active: false);
    if (result == null) return;
    await _addCallSystemMessage(chatId: result.chatId, callId: callId, text: '📵 تم رفض المكالمة', status: CallStatus.rejected.name, type: result.type);
  }

  Future<void> cancelCall(String callId) async {
    final result = await _updateCallState(callId, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.cancelled.name, 'endedAt': FieldValue.serverTimestamp()}, active: false);
    if (result == null) return;
    await _addCallSystemMessage(chatId: result.chatId, callId: callId, text: '📞 تم إلغاء المكالمة', status: CallStatus.cancelled.name, type: result.type);
  }

  Future<void> endCall(String callId, {int? durationSeconds}) async {
    final result = await _updateCallState(callId, allowed: const [CallStatus.calling, CallStatus.ringing, CallStatus.connected], data: {'status': CallStatus.ended.name, 'endedAt': FieldValue.serverTimestamp(), 'durationSeconds': durationSeconds}, active: false);
    if (result == null) return;
    await _addCallSystemMessage(chatId: result.chatId, callId: callId, text: durationSeconds != null && durationSeconds > 0 ? '📞 انتهت المكالمة • ${durationSeconds}s' : '📞 انتهت المكالمة', status: CallStatus.ended.name, type: result.type);
  }

  Future<void> missCall(String callId) async {
    final result = await _updateCallState(callId, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.missed.name, 'endedAt': FieldValue.serverTimestamp()}, active: false, ignoreInvalidState: true);
    if (result == null) return;
    await _addCallSystemMessage(chatId: result.chatId, callId: callId, text: '📵 مكالمة فائتة', status: CallStatus.missed.name, type: result.type);
  }

  Future<_CallContext?> _updateCallState(String callId, {required List<CallStatus> allowed, required Map<String, dynamic> data, required bool active, bool ignoreInvalidState = false}) async {
    _CallContext? context;
    await _withFirestoreRetry(() async {
      await _firestore.runTransaction((transaction) async {
        final ref = _firestore.collection('calls').doc(callId);
        final doc = await transaction.get(ref);
        if (!doc.exists) return;
        final rawStatus = doc.data()?['status'] as String?;
        final current = CallStatus.values.firstWhere((value) => value.name == rawStatus, orElse: () => CallStatus.calling);
        if (!allowed.contains(current)) {
          if (ignoreInvalidState) return;
          throw Exception('لا يمكن تغيير حالة المكالمة الحالية');
        }
        final rawType = doc.data()?['callType'] as String?;
        final type = CallType.values.firstWhere((value) => value.name == rawType, orElse: () => CallType.audio);
        context = _CallContext(chatId: doc.data()?['chatId'] as String? ?? '', type: type);
        transaction.update(ref, data);
      });
      return null;
    });
    _isInCall = active;
    _currentCallId = active ? callId : null;
    return context;
  }

  Future<String?> resolveChatId(String callId) async {
    final doc = await _withFirestoreRetry(() => _firestore.collection('calls').doc(callId).get());
    if (!doc.exists) return null;
    final value = doc.data()?['chatId']?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> handleIncomingCall(BuildContext context, RemoteMessage message) async {
    final callId = (message.data['callId'] ?? message.data['id'])?.toString();
    if (callId == null || callId.isEmpty) {
      ToastService.showError('❌ لا يمكن معالجة المكالمة');
      return;
    }

    final callerName = (message.data['callerName'] ?? 'مستخدم').toString();
    final callerId = (message.data['callerId'] ?? 'unknown').toString();
    var chatId = message.data['chatId']?.toString();
    if (chatId == null || chatId.trim().isEmpty) chatId = await resolveChatId(callId);
    if (chatId == null || chatId.trim().isEmpty) {
      ToastService.showError('❌ تعذر العثور على المحادثة المرتبطة بالمكالمة');
      return;
    }

    final isVideo = message.data['isVideo']?.toString() == 'true' || message.data['isVideoCall']?.toString() == 'true';
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => IncomingCallScreen(
        callId: callId,
        callerName: callerName,
        callerId: callerId,
        callerImage: message.data['callerPhotoUrl']?.toString(),
        isVideo: isVideo,
        chatId: chatId!,
        onCallAnswered: (_) {},
      ),
    ));
  }

  void dispose() {
    _isInCall = false;
    _currentCallId = null;
  }
}

class _CallContext {
  final String chatId;
  final CallType type;
  const _CallContext({required this.chatId, required this.type});
}
