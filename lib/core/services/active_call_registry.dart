import 'package:flutter/foundation.dart';

/// Process-wide guard for the single LiveKit call that may be active on this device.
///
/// The registry deliberately contains no queue. Firestore is the source of
/// truth for call lifecycle; this registry only closes the local race that
/// could otherwise open a second CallScreen/LiveKit room.
class ActiveCallRegistry {
  ActiveCallRegistry._();

  static final ActiveCallRegistry instance = ActiveCallRegistry._();

  String? _activeCallId;
  DateTime? _startedAt;

  bool get hasActiveCall => _activeCallId != null;
  String? get activeCallId => _activeCallId;
  DateTime? get startedAt => _startedAt;
  Duration? get elapsed => _startedAt == null
      ? null
      : DateTime.now().difference(_startedAt!);

  void register(String callId) {
    final id = callId.trim();
    if (id.isEmpty || _activeCallId == id) return;

    // Never silently replace another active call.
    if (_activeCallId != null) {
      debugPrint('CALL REGISTRY BLOCKED register=$id active=$_activeCallId');
      return;
    }

    _activeCallId = id;
    _startedAt = DateTime.now();
    debugPrint('CALL REGISTRY REGISTER $id');
  }

  /// Unregister only the matching call when an id is supplied.
  void unregister([String? callId]) {
    final id = callId?.trim();
    if (id != null && id.isNotEmpty && id != _activeCallId) {
      debugPrint('CALL REGISTRY IGNORE unregister=$id active=$_activeCallId');
      return;
    }

    final previous = _activeCallId;
    _activeCallId = null;
    _startedAt = null;
    if (previous != null) debugPrint('CALL REGISTRY UNREGISTER $previous');
  }

  /// Clears stale process-local state when the application starts.
  void reset() {
    debugPrint('CALL REGISTRY RESET (was=$_activeCallId)');
    _activeCallId = null;
    _startedAt = null;
  }
}
