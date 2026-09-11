import 'dart:async';

import 'package:flutter/foundation.dart';

/// A locally queued incoming call. Queue state is intentionally process-local;
/// Firestore remains the source of truth for the call lifecycle.
class QueuedCall {
  final String callId;
  final String callerName;
  final String callerId;
  final String? callerImage;
  final String chatId;
  final bool isVideo;
  final DateTime queuedAt;

  QueuedCall({
    required this.callId,
    required this.callerName,
    required this.callerId,
    this.callerImage,
    required this.chatId,
    required this.isVideo,
    DateTime? queuedAt,
  }) : queuedAt = queuedAt ?? DateTime.now();
}

/// Process-wide guard for the LiveKit call actually active on this device.
/// It also owns the small local waiting queue used by call-waiting UX.
class ActiveCallRegistry {
  ActiveCallRegistry._();

  static final ActiveCallRegistry instance = ActiveCallRegistry._();

  String? _activeCallId;
  DateTime? _startedAt;
  final List<QueuedCall> _queue = <QueuedCall>[];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  String? get activeCallId => _activeCallId;
  bool get hasActiveCall => _activeCallId != null;
  DateTime? get startedAt => _startedAt;
  Duration? get elapsed => _startedAt == null ? null : DateTime.now().difference(_startedAt!);
  int get queueLength => _queue.length;
  List<QueuedCall> get queue => List.unmodifiable(_queue);
  QueuedCall? get nextInQueue => _queue.isEmpty ? null : _queue.first;
  Stream<void> get changes => _changes.stream;

  void register(String callId) {
    final id = callId.trim();
    if (id.isEmpty) return;
    _activeCallId = id;
    _startedAt = DateTime.now();
    debugPrint('CALL REGISTRY register=$id');
    _emit();
  }

  void unregister([String? callId]) {
    if (callId != null && callId.trim().isNotEmpty && callId != _activeCallId) return;
    final previous = _activeCallId;
    _activeCallId = null;
    _startedAt = null;
    debugPrint('CALL REGISTRY unregister=$previous');
    _emit();
  }

  bool enqueue(QueuedCall call) {
    if (call.callId.trim().isEmpty || call.callId == _activeCallId) return false;
    if (_queue.any((item) => item.callId == call.callId)) return false;
    _queue.add(call);
    debugPrint('CALL QUEUE enqueue=${call.callId} size=${_queue.length}');
    _emit();
    return true;
  }

  bool isQueued(String callId) => _queue.any((item) => item.callId == callId);

  QueuedCall? dequeue() {
    if (_queue.isEmpty) return null;
    final call = _queue.removeAt(0);
    debugPrint('CALL QUEUE dequeue=${call.callId} size=${_queue.length}');
    _emit();
    return call;
  }

  bool removeFromQueue(String callId) {
    final before = _queue.length;
    _queue.removeWhere((item) => item.callId == callId);
    final changed = before != _queue.length;
    if (changed) _emit();
    return changed;
  }

  void reset() {
    _activeCallId = null;
    _startedAt = null;
    _queue.clear();
    _emit();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}
