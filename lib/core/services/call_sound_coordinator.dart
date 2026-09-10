import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../presentation/screens/chat/incoming_call_screen.dart';
import 'sound_manager.dart';

/// Owns foreground call alert audio and routes incoming calls to the
/// acceptance UI. It never joins LiveKit itself.
class CallSoundCoordinator {
  CallSoundCoordinator._();
  static final CallSoundCoordinator instance = CallSoundCoordinator._();

  static const Duration _maxCallAge = Duration(seconds: 90);

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _callsSubscription;
  final SoundManager _sounds = SoundManager();
  String? _activeCallId;

  void start() {
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen((_) {
      _restartCallsListener();
    });
    _restartCallsListener();
  }

  void _restartCallsListener() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
    _activeCallId = null;
    unawaited(_sounds.stopCallAudio());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _callsSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .listen(_onCallsChanged, onError: (Object error, StackTrace stack) {
      _activeCallId = null;
      unawaited(_sounds.stopCallAudio());
    });
  }

  void _onCallsChanged(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      unawaited(_sounds.stopCallAudio());
      return;
    }

    QueryDocumentSnapshot<Map<String, dynamic>>? active;
    DateTime? newest;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status']?.toString();
      if (status != 'calling' && status != 'ringing') continue;

      final startedAt = data['startedAt'];
      if (startedAt is! Timestamp) continue;
      final started = startedAt.toDate();
      final age = DateTime.now().difference(started);
      if (age.isNegative || age > _maxCallAge) continue;

      if (active == null || newest == null || started.isAfter(newest)) {
        active = doc;
        newest = started;
      }
    }

    if (active == null) {
      _activeCallId = null;
      unawaited(_sounds.stopCallAudio());
      return;
    }

    final data = active.data();
    final callId = active.id;
    final callerId = data['callerId']?.toString() ?? '';
    final receiverId = data['receiverId']?.toString() ?? '';
    final isIncoming = receiverId == user.uid && callerId != user.uid;
    final isOutgoing = callerId == user.uid && receiverId != user.uid;

    if (!isIncoming && !isOutgoing) {
      _activeCallId = null;
      unawaited(_sounds.stopCallAudio());
      return;
    }

    final isNewCall = _activeCallId != callId;
    if (isNewCall) _activeCallId = callId;

    unawaited(
      (isIncoming ? _sounds.playCallRingtone() : _sounds.playRingback())
          .catchError((_) {}),
    );

    // Critical rule: an incoming call is NOT a LiveKit connection. The
    // receiver must see the existing IncomingCallScreen and explicitly press
    // Accept. Only IncomingCallScreen.acceptCall() changes the call to
    // connected and then opens CallScreen.
    if (isIncoming && isNewCall) {
      _showIncomingCall(data, callId);
    }
  }

  void _showIncomingCall(Map<String, dynamic> data, String callId) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      // The app may still be mounting. The FCM foreground/background handlers
      // remain responsible for their notification path; no LiveKit join occurs.
      return;
    }

    // Never stack duplicate incoming screens for the same call.
    final current = nav.context;
    final route = ModalRoute.of(current);
    if (route?.settings.name == 'incoming_call:$callId') return;

    final chatId = data['chatId']?.toString() ?? '';
    if (chatId.isEmpty) return;

    nav.push(MaterialPageRoute(
      settings: RouteSettings(name: 'incoming_call:$callId'),
      builder: (_) => IncomingCallScreen(
        callId: callId,
        callerName: data['callerName']?.toString() ?? 'مستخدم',
        callerId: data['callerId']?.toString() ?? '',
        callerImage: data['callerPhotoUrl']?.toString(),
        isVideo: data['isVideoCall'] == true || data['callType']?.toString() == 'video',
        chatId: chatId,
        onCallAnswered: (_) {},
      ),
    ));
  }

  /// Stops only the looping call audio immediately. The Firestore listener
  /// remains alive so the next call can still be detected.
  Future<void> stopForCall(String? callId) async {
    if (callId == null || _activeCallId == null || callId == _activeCallId) {
      _activeCallId = null;
      await _sounds.stopCallAudio();
    }
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _callsSubscription?.cancel();
    _authSubscription = null;
    _callsSubscription = null;
    _activeCallId = null;
    await _sounds.stopAll();
  }
}
