import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../presentation/screens/chat/incoming_call_screen.dart';
import 'active_call_registry.dart';
import 'call_service.dart';
import 'sound_manager.dart';

/// Sole owner of foreground call alert audio and incoming-call routing.
/// It never joins LiveKit and never owns call state transitions.
class CallSoundCoordinator {
  CallSoundCoordinator._();
  static final CallSoundCoordinator instance = CallSoundCoordinator._();

  static const Duration _maxCallAge = Duration(seconds: 90);

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _callsSubscription;
  final SoundManager _sounds = SoundManager();
  final CallService _calls = CallService();
  String? _activeCallId;
  String? _incomingUiCallId;
  final Set<String> _busyHandledCallIds = <String>{};
  bool _incomingMuted = false;

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
    _incomingUiCallId = null;
    _busyHandledCallIds.clear();
    _incomingMuted = false;
    ActiveCallRegistry.instance.reset();
    unawaited(_sounds.stopCallAudio());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _callsSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .listen(_onCallsChanged, onError: (Object error, StackTrace stack) {
      debugPrint('CallSoundCoordinator calls listener error: $error');
      _activeCallId = null;
      _incomingUiCallId = null;
      ActiveCallRegistry.instance.reset();
      unawaited(_sounds.stopCallAudio());
    });
  }

  void _onCallsChanged(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _incomingUiCallId = null;
      ActiveCallRegistry.instance.reset();
      unawaited(_sounds.stopCallAudio());
      return;
    }

    QueryDocumentSnapshot<Map<String, dynamic>>? active;
    DateTime? newest;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status']?.toString();
      if (status != 'calling' && status != 'ringing' && status != 'connected') continue;
      final startedAt = data['startedAt'];
      if (startedAt is! Timestamp) continue;
      final started = startedAt.toDate();
      final age = DateTime.now().difference(started);
      // Ringing/calling calls are time-bounded. A connected call must never
      // expire from the registry just because it lasts longer than 90s.
      if (status != CallStatus.connected.name && (age.isNegative || age > _maxCallAge)) continue;
      if (active == null || newest == null || started.isAfter(newest)) {
        active = doc;
        newest = started;
      }
    }

    if (active == null) {
      _activeCallId = null;
      _incomingUiCallId = null;
      _incomingMuted = false;
      ActiveCallRegistry.instance.reset();
      unawaited(_sounds.stopCallAudio());
      return;
    }

    final data = active.data();
    final callId = active.id;
    final status = data['status']?.toString() ?? '';
    final callerId = data['callerId']?.toString() ?? '';
    final receiverId = data['receiverId']?.toString() ?? '';
    final isIncoming = receiverId == user.uid && callerId != user.uid;
    final isOutgoing = callerId == user.uid && receiverId != user.uid;
    if (!isIncoming && !isOutgoing) return;

    // A connected call is the authoritative signal that this device is in an
    // active call. Register it globally so a second incoming call is handled
    // as busy instead of creating another CallScreen/LiveKit session.
    if (status == CallStatus.connected.name) {
      ActiveCallRegistry.instance.register(callId);
      _activeCallId = callId;
      _incomingUiCallId = null;
      _incomingMuted = false;
      unawaited(_sounds.stopCallAudio());
      return;
    }

    final isNewCall = _activeCallId != callId;
    if (isNewCall) {
      _activeCallId = callId;
      _incomingMuted = false;
    }

    if (isIncoming && ActiveCallRegistry.instance.hasActiveCall) {
      unawaited(_sounds.stopCallAudio());
      if (!_busyHandledCallIds.contains(callId)) {
        _busyHandledCallIds.add(callId);
        unawaited(_calls.markBusy(callId).catchError((Object error) {
          debugPrint('CALL BUSY update failed id=$callId error=$error');
        }));
      }
      debugPrint('CALL BUSY uid=${user.uid} activeCall=${ActiveCallRegistry.instance.activeCallId} incoming=$callId');
      return;
    }

    if (isIncoming) {
      if (_incomingMuted) {
        unawaited(_sounds.stopCallAudio());
      } else {
        unawaited(_sounds.playCallRingtone().catchError((_) {}));
      }
    } else {
      unawaited(_sounds.playRingback().catchError((_) {}));
    }

    if (isIncoming && isNewCall) {
      _showIncomingCall(data, callId);
    }
  }

  void _showIncomingCall(Map<String, dynamic> data, String callId) {
    final nav = navigatorKey.currentState;
    if (nav == null || _incomingUiCallId == callId) return;

    final chatId = data['chatId']?.toString() ?? '';
    if (chatId.isEmpty) {
      debugPrint('Incoming call $callId has no chatId; UI not shown');
      return;
    }

    _incomingUiCallId = callId;
    unawaited(
      showGeneralDialog<void>(
        context: nav.context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierLabel: 'مكالمة واردة',
        barrierColor: Colors.black.withOpacity(.72),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return IncomingCallScreen(
            callId: callId,
            callerName: data['callerName']?.toString() ?? 'مستخدم',
            callerId: data['callerId']?.toString() ?? '',
            callerImage: data['callerPhotoUrl']?.toString(),
            isVideo: data['isVideoCall'] == true || data['callType']?.toString() == 'video',
            chatId: chatId,
            onCallAnswered: (_) {},
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: .96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ).whenComplete(() {
        if (_incomingUiCallId == callId) _incomingUiCallId = null;
      }),
    );
  }

  Future<void> setIncomingMuted(bool muted) async {
    _incomingMuted = muted;
    if (muted) {
      await _sounds.stopCallAudio();
    } else if (_activeCallId != null && !ActiveCallRegistry.instance.hasActiveCall) {
      await _sounds.playCallRingtone();
    }
  }

  Future<void> stopForCall(String? callId) async {
    if (callId == null || _activeCallId == null || callId == _activeCallId) {
      _activeCallId = null;
      _incomingMuted = false;
      await _sounds.stopCallAudio();
    }
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _callsSubscription?.cancel();
    _authSubscription = null;
    _callsSubscription = null;
    _activeCallId = null;
    _incomingUiCallId = null;
    _busyHandledCallIds.clear();
    _incomingMuted = false;
    ActiveCallRegistry.instance.reset();
    await _sounds.stopAll();
  }
}
