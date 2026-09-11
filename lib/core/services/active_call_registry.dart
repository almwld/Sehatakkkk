/// Process-wide registry for the LiveKit call that is actually active on
/// this device. It prevents a second CallScreen/LiveKit session from being
/// created while an existing call is connected.
class ActiveCallRegistry {
  ActiveCallRegistry._();

  static final ActiveCallRegistry instance = ActiveCallRegistry._();

  String? _activeCallId;

  String? get activeCallId => _activeCallId;
  bool get hasActiveCall => _activeCallId != null;

  void register(String callId) {
    final id = callId.trim();
    if (id.isEmpty) return;
    _activeCallId = id;
  }

  void unregister([String? callId]) {
    if (callId == null || callId.trim().isEmpty || callId == _activeCallId) {
      _activeCallId = null;
    }
  }

  void reset() {
    _activeCallId = null;
  }
}
