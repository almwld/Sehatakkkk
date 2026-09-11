import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../presentation/screens/chat/incoming_call_screen.dart';
import '../models/call_model.dart';
import 'active_call_registry.dart';
import 'sound_manager.dart';

/// Owns foreground call alert audio and incoming-call routing.
///
/// It never joins LiveKit and it never opens a second call while another
/// local call is active. A second incoming call is completed as `busy` in
/// Firestore; it is not queued and no IncomingCallScreen is shown.
class CallSoundCoordinator {
  CallSoundCoordinator._();
  static final CallSoundCoordinator instance = CallSoundCoordinator._();

  static const Duration _maxCallAge = Duration(seconds: 90);

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _callsSubscription;
  final SoundManager _sounds = SoundManager();
  String? _activeCallId;
  String? _incomingUiCallId;
  bool _incomingMuted = false;

  void start() {
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen(
      (_) => _restartCallsListener(),
    );
    _restartCallsListener();
  }

  void _restartCallsListener() {
    _callsSubscription?.cancel();
    _callsSubscription = null;
    _activeCallId = null;
    _incomingUiCallId = null;
    _incomingMuted = false;
    unawaited(_sounds.stopCallAudio());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _callsSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .listen(
          _onCallsChanged,
          onError: (Object error, StackTrace stack) {
            debugPrint('CallSoundCoordinator listener error: $error');
            _activeCallId = null;
            _incomingUiCallId = null;
            unawaited(_sounds.stopCallAudio());
          },
        );
  }

  void _onCallsChanged(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      unawaited(_sounds.stopCallAudio());
      return;
    }

    QueryDocumentSnapshot<Map<String, dynamic>>? connected;
    QueryDocumentSnapshot<Map<String, dynamic>>? newestIncoming;
    DateTime? newestIncomingAt;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status']?.toString();
      if (status != CallStatus.calling.name &&
          status != CallStatus.ringing.name &&
          status != CallStatus.connected.name) {
        continue;
      }

      final startedAt = data['startedAt'];
      if (startedAt is! Timestamp) continue;
      final started = startedAt.toDate();
      final age = DateTime.now().difference(started);
      if (status != CallStatus.connected.name &&
          (age.isNegative || age > _maxCallAge)) {
        continue;
      }

      final callerId = data['callerId']?.toString() ?? '';
      final receiverId = data['receiverId']?.toString() ?? '';
      final isIncoming = receiverId == user.uid && callerId != user.uid;
      final isOutgoing = callerId == user.uid && receiverId != user.uid;
      if (!isIncoming && !isOutgoing) continue;

      if (status == CallStatus.connected.name) {
        connected ??= doc;
        continue;
      }

      if (isIncoming &&
          (newestIncomingAt == null || started.isAfter(newestIncomingAt))) {
        newestIncoming = doc;
        newestIncomingAt = started;
      }
    }

    // A locally registered call is the strongest guard. If Firestore also
    // reports a different incoming call, immediately mark that caller busy.
    final localActiveId = ActiveCallRegistry.instance.activeCallId;
    if (localActiveId != null) {
      _activeCallId = localActiveId;
      _incomingUiCallId = null;
      _incomingMuted = false;
      unawaited(_sounds.stopCallAudio());

      if (newestIncoming != null && newestIncoming.id != localActiveId) {
        unawaited(_markBusy(newestIncoming.id));
      }
      return;
    }

    // Recover the registry after process/navigation changes when Firestore
    // already knows about a connected call.
    if (connected != null) {
      final connectedId = connected.id;
      ActiveCallRegistry.instance.register(connectedId);
      _activeCallId = connectedId;
      _incomingUiCallId = null;
      _incomingMuted = false;
      unawaited(_sounds.stopCallAudio());

      if (newestIncoming != null && newestIncoming.id != connectedId) {
        unawaited(_markBusy(newestIncoming.id));
      }
      return;
    }

    if (newestIncoming == null) {
      _activeCallId = null;
      _incomingUiCallId = null;
      _incomingMuted = false;
      unawaited(_sounds.stopCallAudio());
      return;
    }

    final data = newestIncoming.data();
    final callId = newestIncoming.id;
    final callerId = data['callerId']?.toString() ?? '';
    final receiverId = data['receiverId']?.toString() ?? '';
    final isIncoming = receiverId == user.uid && callerId != user.uid;
    if (!isIncoming) return;

    final isNewCall = _activeCallId != callId;
    if (isNewCall) {
      _activeCallId = callId;
      _incomingMuted = false;
    }

    if (_incomingMuted) {
      unawaited(_sounds.stopCallAudio());
    } else {
      unawaited(_sounds.playCallRingtone().catchError((_) {}));
    }

    if (isNewCall) _showIncomingCall(data, callId);
  }

  /// Marks a second incoming call as busy without opening any UI or LiveKit
  /// session on the receiving device.
  Future<void> _markBusy(String callId) async {
    try {
      final ref = FirebaseFirestore.instance.collection('calls').doc(callId);
      final snap = await ref.get();
      if (!snap.exists) return;

      final status = snap.data()?['status']?.toString();
      if (status != CallStatus.calling.name &&
          status != CallStatus.ringing.name) {
        return;
      }

      await ref.update({
        'status': CallStatus.busy.name,
        'endedAt': FieldValue.serverTimestamp(),
        'busyReason': 'receiver_in_call',
        'metadata.busyReason': 'receiver_in_call',
      });
      debugPrint('CALL BUSY id=$callId reason=receiver_in_call');
    } catch (e) {
      debugPrint('CALL BUSY UPDATE ERROR id=$callId error=$e');
    }
  }

  void _showIncomingCall(Map<String, dynamic> data, String callId) {
    // Defense in depth: never open an incoming dialog over an active call.
    if (ActiveCallRegistry.instance.hasActiveCall) {
      unawaited(_markBusy(callId));
      return;
    }

    final nav = navigatorKey.currentState;
    if (nav == null || _incomingUiCallId == callId) return;

    final chatId = data['chatId']?.toString() ?? '';
    if (chatId.isEmpty) return;

    _incomingUiCallId = callId;
    unawaited(
      showGeneralDialog<void>(
        context: nav.context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierLabel: 'مكالمة واردة',
        barrierColor: Colors.black.withOpacity(.72),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            IncomingCallScreen(
          callId: callId,
          callerName: data['callerName']?.toString() ?? 'مستخدم',
          callerId: data['callerId']?.toString() ?? '',
          callerImage: data['callerPhotoUrl']?.toString(),
          isVideo: data['isVideoCall'] == true ||
              data['callType']?.toString() == 'video',
          chatId: chatId,
          onCallAnswered: (_) {},
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
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
    } else if (_activeCallId != null &&
        !ActiveCallRegistry.instance.hasActiveCall) {
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
    _incomingMuted = false;
    await _sounds.stopAll();
  }
}
