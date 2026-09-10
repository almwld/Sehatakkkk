import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/call_sound_coordinator.dart';
import 'package:sehatak/presentation/screens/chat/incoming_call_screen.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _chat = ChatService();
  bool _inCall = false;
  String? _current;

  bool get isInCall => _inCall;
  String? get currentCallId => _current;
  String? get currentUserId => _auth.currentUser?.uid;

  String _uid() {
    final u = currentUserId;
    if (u == null || u.isEmpty) throw Exception('يجب تسجيل الدخول');
    return u;
  }

  Future<T> _retry<T>(Future<T> Function() op) async {
    Object? last;
    for (var i = 0; i < 3; i++) {
      try {
        return await op();
      } on FirebaseException catch (e) {
        last = e;
        if (!['unavailable', 'deadline-exceeded', 'aborted'].contains(e.code) || i == 2) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 350 * pow(2, i).toInt()));
      }
    }
    throw last ?? Exception('فشل الوصول إلى Firestore');
  }

  Stream<List<CallModel>> streamCallHistory({int limit = 50}) =>
      _firestore.collection('calls').where('participants', arrayContains: _uid()).orderBy('startedAt', descending: true).limit(limit).snapshots().map((s) => s.docs.map((d) => CallModel.fromFirestore(d.id, d.data())).toList());

  Stream<CallModel?> streamCall(String id) =>
      _firestore.collection('calls').doc(id).snapshots().map((d) => d.exists ? CallModel.fromFirestore(d.id, d.data()!) : null);

  Future<void> _timeline({required String chatId, required String callId, required String text, required String status, required CallType type}) async {
    if (chatId.isEmpty) return;
    try {
      await _chat.sendSystemMessage(chatId: chatId, text: text, idempotencyKey: 'call_${callId}_$status', metadata: {'callId': callId, 'callType': type.name, 'status': status});
    } catch (e) {
      debugPrint('call timeline: $e');
    }
  }

  Future<CallModel?> initiateCall({required String receiverId, required String receiverName, String? receiverPhotoUrl, required CallType type, required String chatId, String? idempotencyKey}) async {
    final uid = _uid();
    final user = _auth.currentUser!;
    if (receiverId.isEmpty || receiverId == uid) throw Exception('معرّف المستقبل غير صالح');
    final id = idempotencyKey ?? _firestore.collection('calls').doc().id;
    final ref = _firestore.collection('calls').doc(id);
    final old = await _retry(() => ref.get());
    if (old.exists) return CallModel.fromFirestore(id, old.data()!);
    final room = 'call_$id';
    await _retry(() => ref.set({'id': id, 'chatId': chatId, 'callerId': uid, 'callerName': user.displayName ?? 'مستخدم', 'callerPhotoUrl': user.photoURL, 'receiverId': receiverId, 'receiverName': receiverName, 'receiverPhotoUrl': receiverPhotoUrl, 'callType': type.name, 'status': CallStatus.calling.name, 'startedAt': FieldValue.serverTimestamp(), 'isAnswered': false, 'participants': [uid, receiverId], 'liveKitRoomName': room, 'roomName': room, 'isVideoCall': type == CallType.video}));
    _inCall = true;
    _current = id;
    await _timeline(chatId: chatId, callId: id, text: type == CallType.video ? '📹 بدء مكالمة فيديو' : '📞 بدء مكالمة صوتية', status: CallStatus.calling.name, type: type);
    final saved = await _retry(() => ref.get());
    if (!saved.exists) throw Exception('تعذر حفظ المكالمة');
    return CallModel.fromFirestore(id, saved.data()!);
  }

  Future<_Ctx?> _state(String id, {required List<CallStatus> allowed, required Map<String, dynamic> data, required bool active, bool ignore = false}) async {
    _Ctx? c;
    await _retry(() async {
      await _firestore.runTransaction((tx) async {
        final ref = _firestore.collection('calls').doc(id);
        final d = await tx.get(ref);
        if (!d.exists) return;
        final currentStatus = CallStatus.values.firstWhere((x) => x.name == d.data()?['status'], orElse: () => CallStatus.calling);
        if (!allowed.contains(currentStatus)) {
          if (ignore) return;
          throw Exception('لا يمكن تغيير حالة المكالمة الحالية');
        }
        final t = CallType.values.firstWhere((x) => x.name == d.data()?['callType'], orElse: () => CallType.audio);
        final rawChatId = d.data()?['chatId'];
        c = _Ctx(rawChatId == null ? '' : rawChatId.toString(), t);
        tx.update(ref, data);
      });
      return null;
    });
    _inCall = active;
    _current = active ? id : null;
    if (!active) unawaited(CallSoundCoordinator.instance.stopForCall(id));
    return c;
  }

  Future<void> acceptCall(String id) async {
    final c = await _state(id, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.connected.name, 'isAnswered': true, 'connectedAt': FieldValue.serverTimestamp()}, active: true);
    await CallSoundCoordinator.instance.stopForCall(id);
    if (c != null) await _timeline(chatId: c.chatId, callId: id, text: c.type == CallType.video ? '📹 تم الاتصال بالفيديو' : '📞 تم الاتصال', status: CallStatus.connected.name, type: c.type);
  }

  Future<void> rejectCall(String id) async {
    final c = await _state(id, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.rejected.name, 'endedAt': FieldValue.serverTimestamp()}, active: false);
    await CallSoundCoordinator.instance.stopForCall(id);
    if (c != null) await _timeline(chatId: c.chatId, callId: id, text: '📵 تم رفض المكالمة', status: CallStatus.rejected.name, type: c.type);
  }

  Future<void> cancelCall(String id) async {
    final c = await _state(id, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.cancelled.name, 'endedAt': FieldValue.serverTimestamp()}, active: false);
    await CallSoundCoordinator.instance.stopForCall(id);
    if (c != null) await _timeline(chatId: c.chatId, callId: id, text: '📞 تم إلغاء المكالمة', status: CallStatus.cancelled.name, type: c.type);
  }

  Future<void> endCall(String id, {int? durationSeconds}) async {
    final c = await _state(id, allowed: const [CallStatus.calling, CallStatus.ringing, CallStatus.connected], data: {'status': CallStatus.ended.name, 'endedAt': FieldValue.serverTimestamp(), 'durationSeconds': durationSeconds}, active: false);
    await CallSoundCoordinator.instance.stopForCall(id);
    if (c != null) await _timeline(chatId: c.chatId, callId: id, text: durationSeconds != null && durationSeconds > 0 ? '📞 انتهت المكالمة • ${durationSeconds}s' : '📞 انتهت المكالمة', status: CallStatus.ended.name, type: c.type);
  }

  Future<void> missCall(String id) async {
    final c = await _state(id, allowed: const [CallStatus.calling, CallStatus.ringing], data: {'status': CallStatus.missed.name, 'endedAt': FieldValue.serverTimestamp()}, active: false, ignore: true);
    await CallSoundCoordinator.instance.stopForCall(id);
    if (c != null) await _timeline(chatId: c.chatId, callId: id, text: '📵 مكالمة فائتة', status: CallStatus.missed.name, type: c.type);
  }

  Future<String?> resolveChatId(String id) async {
    final snapshot = await _retry(() => _firestore.collection('calls').doc(id).get());
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    final chatId = data['chatId'];
    return chatId == null ? null : chatId.toString();
  }

  Future<void> handleIncomingCallById(BuildContext context, String id) async {
    final snap = await _retry(() => _firestore.collection('calls').doc(id).get());
    if (!snap.exists || !context.mounted) return;
    final data = snap.data() ?? {};
    final receiverId = data['receiverId']?.toString();
    if (receiverId != null && receiverId.isNotEmpty && receiverId != currentUserId) return;
    final status = data['status']?.toString();
    if (status != CallStatus.calling.name && status != CallStatus.ringing.name) return;
    final chatId = data['chatId']?.toString() ?? '';
    if (chatId.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => IncomingCallScreen(callId: id, callerName: data['callerName']?.toString() ?? 'مستخدم', callerId: data['callerId']?.toString() ?? '', callerImage: data['callerPhotoUrl']?.toString(), isVideo: data['isVideoCall'] == true || data['callType']?.toString() == 'video', chatId: chatId, onCallAnswered: (_) {})));
  }

  Future<void> handleIncomingCall(BuildContext context, RemoteMessage message) async {
    final id = (message.data['callId'] ?? message.data['id'])?.toString();
    if (id == null || id.isEmpty) return;
    final callerId = (message.data['callerId'] ?? '').toString();
    var chatId = message.data['chatId']?.toString();
    chatId = (chatId == null || chatId.isEmpty) ? await resolveChatId(id) : chatId;
    if (chatId == null || chatId.isEmpty) {
      ToastService.showError('تعذر العثور على المحادثة المرتبطة بالمكالمة');
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => IncomingCallScreen(callId: id, callerName: (message.data['callerName'] ?? 'مستخدم').toString(), callerId: callerId, callerImage: message.data['callerPhotoUrl']?.toString(), isVideo: message.data['isVideo']?.toString() == 'true' || message.data['isVideoCall']?.toString() == 'true', chatId: chatId!, onCallAnswered: (_) {})));
  }

  void dispose() {
    _inCall = false;
    _current = null;
  }
}

class _Ctx {
  final String chatId;
  final CallType type;
  const _Ctx(this.chatId, this.type);
}
