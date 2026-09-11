import 'dart:async';

import 'package:flutter/foundation.dart';

import 'active_call_registry.dart';
import 'call_sound_coordinator.dart';

/// Coordinates the local waiting queue. Firestore remains the call source of truth;
/// this manager only releases the next queued call after the active LiveKit call ends.
class CallQueueManager {
  CallQueueManager._();
  static final CallQueueManager instance = CallQueueManager._();

  StreamSubscription<void>? _subscription;
  bool _started = false;
  bool _processing = false;

  void start() {
    if (_started) return;
    _started = true;
    _subscription = ActiveCallRegistry.instance.changes.listen((_) {
      if (!ActiveCallRegistry.instance.hasActiveCall) {
        unawaited(_processNext());
      }
    });
    debugPrint('CALL QUEUE MANAGER started');
  }

  Future<void> _processNext() async {
    if (_processing || ActiveCallRegistry.instance.hasActiveCall) return;
    _processing = true;
    try {
      final next = ActiveCallRegistry.instance.nextInQueue;
      if (next == null) return;
      await CallSoundCoordinator.instance.showQueuedCall(next.callId);
    } finally {
      _processing = false;
    }
  }

  Future<void> dispose() async {
    _started = false;
    await _subscription?.cancel();
    _subscription = null;
  }
}
