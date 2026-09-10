import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sound_manager.dart';

/// Owns looping call audio while the app is in the foreground.
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

    if (_activeCallId == callId) return;

    _activeCallId = callId;
    unawaited(
      (isIncoming ? _sounds.playCallRingtone() : _sounds.playRingback())
          .catchError((_) {}),
    );
  }

  /// Stops only the looping call audio immediately. The Firestore listener
  /// remains alive so the next call can still be detected without restarting
  /// the notification subsystem.
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
