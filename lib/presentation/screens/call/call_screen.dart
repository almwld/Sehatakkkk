import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/active_call_registry.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String? callId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;
  final String? doctorImage;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.chatId,
    this.callId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = true,
    this.doctorImage,
    this.isOutgoing = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static const _teal = Color(0xFF0A8F83);
  static const _cyan = Color(0xFF00BCD4);
  static const _red = Color(0xFFE53935);
  static const _darkCard = Color(0xFF1A1A1A);

  final LiveKitService _live = LiveKitService();
  final CallService _calls = CallService();
  Room? _room;
  StreamSubscription<CallModel?>? _callSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _timeout;
  Timer? _timer;
  Timer? _videoSyncTimer;
  Timer? _tripleTapTimer;
  String? _callId;
  String? _roomName;
  String? _error;
  VideoTrack? _remoteTrack;
  VideoTrack? _localTrack;
  DateTime? _connectedAt;
  int _seconds = 0;
  int _localTapCount = 0;
  bool _joined = false;
  bool _ending = false;
  bool _connecting = true;
  bool _muted = false;
  bool _cameraEnabled = true;
  bool _speaker = false;
  bool _networkAvailable = true;
  bool _blocked = false;
  bool _swapped = false;

  @override
  void initState() {
    super.initState();
    final incomingId = widget.callId?.trim();
    if (incomingId != null && incomingId.isNotEmpty && ActiveCallRegistry.instance.hasActiveCall && !ActiveCallRegistry.instance.isActive(incomingId)) {
      _blocked = true;
      unawaited(_calls.markBusy(incomingId));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ToastService.showError('مشغول في مكالمة أخرى');
      });
      return;
    }
    if (incomingId != null && incomingId.isNotEmpty) ActiveCallRegistry.instance.register(incomingId);
    _watchConnectivity();
    _connect();
  }

  Future<void> _watchConnectivity() async {
    try {
      final current = await Connectivity().checkConnectivity();
      if (mounted) setState(() => _networkAvailable = _hasNetwork(current));
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
        if (!mounted) return;
        final available = _hasNetwork(result);
        setState(() => _networkAvailable = available);
        if (!available && !_ending) ToastService.showError('انقطع اتصال الإنترنت');
      });
    } catch (e) { debugPrint('Connectivity check failed: $e'); }
  }

  bool _hasNetwork(ConnectivityResult result) => result != ConnectivityResult.none;

  Future<void> _connect() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('يجب تسجيل الدخول');
      final network = await Connectivity().checkConnectivity();
      if (!_hasNetwork(network)) throw StateError('لا يوجد اتصال بالإنترنت');
      CallModel? call;
      final suppliedCallId = widget.callId?.trim();
      if (suppliedCallId != null && suppliedCallId.isNotEmpty) {
        call = await _calls.streamCall(suppliedCallId).first;
        if (call == null) throw StateError('المكالمة غير موجودة');
        if (widget.isOutgoing) {
          if (call.callerId != user.uid) throw StateError('هذه المكالمة ليست صادرة من المستخدم الحالي');
        } else if (call.receiverId != user.uid) {
          throw StateError('هذه المكالمة ليست موجهة لهذا المستخدم');
        }
      } else if (widget.isOutgoing) {
        call = await _calls.initiateCall(receiverId: widget.doctorId, receiverName: widget.doctorName, receiverPhotoUrl: widget.doctorImage, type: widget.isVideo ? CallType.video : CallType.audio, chatId: widget.chatId);
      } else {
        throw StateError('معرّف المكالمة مفقود');
      }
      if (call == null) throw StateError('تعذر العثور على المكالمة');
      if (ActiveCallRegistry.instance.hasActiveCall && !ActiveCallRegistry.instance.isActive(call.id)) {
        await _calls.markBusy(call.id);
        throw StateError('مكالمة أخرى نشطة');
      }
      _callId = call.id;
      _roomName = call.liveKitRoomName?.trim().isNotEmpty == true ? call.liveKitRoomName!.trim() : 'call_${call.id}';
      ActiveCallRegistry.instance.register(call.id);
      _callSubscription = _calls.streamCall(call.id).listen((updated) {
        if (!mounted || updated == null || _ending) return;
        debugPrint('CALL STATE id=${updated.id} status=${updated.status} connectedAt=${updated.connectedAt}');
        if (updated.status == CallStatus.connected) {
          final serverConnectedAt = updated.connectedAt?.toDate();
          if (serverConnectedAt != null) _setConnectedAt(serverConnectedAt);
          if (!_joined) unawaited(_join(updated, user));
          return;
        }
        if (_isTerminal(updated.status)) unawaited(_finishRemote());
      }, onError: (error) => debugPrint('CALL STREAM ERROR: $error'));
      if (widget.isOutgoing && call.status != CallStatus.connected) {
        _timeout = Timer(const Duration(seconds: 30), () async {
          if (_ending || _joined) return;
          try { await _calls.missCall(call!.id); } catch (e) { debugPrint('CALL TIMEOUT update failed: $e'); }
          if (mounted) await _finishRemote();
        });
      }
      if (call.status == CallStatus.connected) await _join(call, user);
      else if (mounted) setState(() => _connecting = false);
    } catch (e) {
      ActiveCallRegistry.instance.unregister(_callId ?? widget.callId);
      debugPrint('CALL CONNECT ERROR: $e');
      if (!mounted) return;
      setState(() { _connecting = false; _error = e.toString().replaceFirst('Exception: ', ''); });
      ToastService.showError('فشل تجهيز المكالمة');
    }
  }

  bool _isTerminal(CallStatus status) => status == CallStatus.cancelled || status == CallStatus.rejected || status == CallStatus.missed || status == CallStatus.ended || status == CallStatus.busy;

  void _setConnectedAt(DateTime value) {
    if (_connectedAt != null && _connectedAt!.difference(value).abs() < const Duration(seconds: 1)) return;
    _connectedAt = value;
    final elapsed = DateTime.now().difference(value).inSeconds;
    _seconds = elapsed < 0 ? 0 : elapsed;
    if (mounted) setState(() {});
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _connectedAt == null || _ending) return;
      final current = DateTime.now().difference(_connectedAt!).inSeconds;
      setState(() => _seconds = current < 0 ? 0 : current);
    });
  }

  Future<void> _join(CallModel call, User user) async {
    if (_joined || _ending || _blocked || call.status != CallStatus.connected) return;
    try {
      if (widget.isVideo) {
        final camera = await Permission.camera.request();
        if (!camera.isGranted) throw StateError('يرجى منح إذن الكاميرا');
      }
      final microphone = await Permission.microphone.request();
      if (!microphone.isGranted) throw StateError('يرجى منح إذن الميكروفون');
      if (_roomName == null || _roomName!.isEmpty) throw StateError('اسم غرفة LiveKit مفقود');
      ActiveCallRegistry.instance.register(call.id);
      _room = await _live.startCall(roomName: _roomName!, callerName: user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : widget.doctorName, isVideo: widget.isVideo);
      _joined = true;
      _timeout?.cancel();
      _setConnectedAt(call.connectedAt?.toDate() ?? DateTime.now());
      _syncTracks();
      _room!.events.on<ParticipantConnectedEvent>((event) { _syncTracks(); _bind(event.participant); });
      _room!.events.on<TrackSubscribedEvent>((event) { _syncTracks(); _bind(event.participant); });
      _room!.events.on<TrackPublishedEvent>((event) { _syncTracks(); _bind(event.participant); });
      _room!.events.on<ParticipantDisconnectedEvent>((event) { _syncTracks(); });
      _videoSyncTimer?.cancel();
      _videoSyncTimer = Timer.periodic(const Duration(milliseconds: 500), (_) { if (!_ending && mounted) _syncTracks(); });
      await _live.setSpeakerphone(_speaker);
      if (mounted) setState(() { _connecting = false; _error = null; });
    } catch (e) {
      ActiveCallRegistry.instance.unregister(call.id);
      debugPrint('CALL LIVEKIT JOIN ERROR: $e');
      if (mounted) setState(() { _connecting = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  void _syncTracks() {
    final room = _room;
    if (room == null || !mounted) return;
    VideoTrack? local;
    VideoTrack? remote;
    for (final publication in room.localParticipant.videoTracks) {
      final track = publication.track;
      if (track is VideoTrack) { local = track; break; }
    }
    for (final participant in room.remoteParticipants.values) {
      for (final publication in participant.videoTracks) {
        final track = publication.track;
        if (track is VideoTrack) { remote = track; break; }
      }
      if (remote != null) break;
    }
    if (_localTrack != local || _remoteTrack != remote) {
      setState(() { _localTrack = local; _remoteTrack = remote; });
    }
  }

  void _bind(Participant? participant) {
    if (participant == null) return;
    for (final publication in participant.videoTracks) {
      final track = publication.track;
      if (track is VideoTrack) {
        if (participant is LocalParticipant) { if (mounted) setState(() => _localTrack = track); }
        else if (mounted) setState(() => _remoteTrack = track);
      }
    }
  }

  void _onLocalPreviewTap() {
    _localTapCount++;
    _tripleTapTimer?.cancel();
    if (_localTapCount >= 3) {
      _localTapCount = 0;
      if (mounted) setState(() => _swapped = !_swapped);
      return;
    }
    _tripleTapTimer = Timer(const Duration(milliseconds: 600), () => _localTapCount = 0);
  }

  Future<void> _finishRemote() async {
    if (_ending) return;
    _ending = true;
    _timeout?.cancel(); _timer?.cancel(); _videoSyncTimer?.cancel();
    await _callSubscription?.cancel();
    _callSubscription = null;
    ActiveCallRegistry.instance.unregister(_callId ?? widget.callId);
    await _live.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _end() async {
    if (_ending) return;
    _ending = true;
    _timeout?.cancel(); _timer?.cancel(); _videoSyncTimer?.cancel();
    await _callSubscription?.cancel();
    _callSubscription = null;
    ActiveCallRegistry.instance.unregister(_callId ?? widget.callId);
    try { if (_callId != null) await _calls.endCall(_callId!, durationSeconds: _joined ? _seconds : 0); } catch (e) { debugPrint('CALL END FIRESTORE ERROR: $e'); }
    await _live.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _mute() async { try { final enabled = await _live.toggleMicrophone(); if (mounted) setState(() => _muted = !enabled); } catch (_) { ToastService.showError('تعذر تغيير حالة الميكروفون'); } }
  Future<void> _toggleCamera() async { try { final enabled = await _live.toggleCamera(); if (mounted) setState(() => _cameraEnabled = enabled); _syncTracks(); } catch (_) { ToastService.showError('تعذر تغيير الكاميرا'); } }
  Future<void> _switchCamera() async { try { await _live.switchCamera(); } catch (e) { debugPrint('CALL CAMERA SWITCH ERROR: $e'); } }
  Future<void> _toggleSpeaker() async { try { final next = !_speaker; await _live.setSpeakerphone(next); if (mounted) setState(() => _speaker = next); } catch (_) { ToastService.showError('تعذر تغيير السماعة'); } }

  @override
  void dispose() {
    _timeout?.cancel(); _timer?.cancel(); _videoSyncTimer?.cancel(); _tripleTapTimer?.cancel(); _callSubscription?.cancel(); _connectivitySubscription?.cancel();
    ActiveCallRegistry.instance.unregister(_callId ?? widget.callId);
    if (_joined) unawaited(_live.endCall());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remote = _swapped ? _localTrack : _remoteTrack;
    final local = _swapped ? _remoteTrack : _localTrack;
    final status = _error != null ? _error! : !_networkAvailable ? 'لا يوجد اتصال بالإنترنت' : _connecting ? (widget.isOutgoing ? 'جاري تجهيز المكالمة...' : 'جاري الاتصال...') : !_joined ? 'في انتظار قبول المكالمة...' : _fmt(_seconds);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0A0A), Color(0xFF0F1419), Color(0xFF0A0A0A)])),
          child: Stack(children: [
            if (widget.isVideo && remote != null) Positioned.fill(child: VideoTrackRenderer(remote, fit: VideoViewFit.cover)) else Positioned.fill(child: _waitingView(status)),
            if (widget.isVideo && local != null)
              PositionedDirectional(top: 68, end: 18, child: GestureDetector(onTap: _onLocalPreviewTap, child: _previewTile(local))),
            if (widget.isVideo && _joined && _remoteTrack == null) Positioned.fill(child: IgnorePointer(child: _remoteFallbackOverlay())),
            Positioned(top: 12, left: 12, right: 12, child: _topBar(status)),
            if (_error == null) Positioned(bottom: 18, left: 14, right: 14, child: _controls()),
          ]),
        ),
      ),
    );
  }

  Widget _previewTile(VideoTrack track) => Container(
    width: 118, height: 176,
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(.35), width: 1.5), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18, spreadRadius: 2)]),
    clipBehavior: Clip.antiAlias,
    child: Stack(fit: StackFit.expand, children: [
      VideoTrackRenderer(track, fit: VideoViewFit.cover),
      Positioned(bottom: 7, left: 7, right: 7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: const Text('اضغط 3 مرات للتبديل', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 9)))),
    ]),
  );

  Widget _remoteFallbackOverlay() => Center(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(24), border: Border.all(color: _teal.withOpacity(.3))), child: Column(mainAxisSize: MainAxisSize.min, children: [_avatar(96), const SizedBox(height: 12), Text(widget.doctorName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 6), const Text('الكاميرا غير مفعلة', style: TextStyle(color: Colors.white60, fontSize: 13))])));

  Widget _waitingView(String status) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [_avatar(140), const SizedBox(height: 22), Text(widget.doctorName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)), const SizedBox(height: 12), _statusBadge(status), const SizedBox(height: 22), Text(_fmt(_seconds), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w300))]));

  Widget _avatar(double size) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [_teal, Color(0xFF00695C)]), boxShadow: [BoxShadow(color: _teal.withOpacity(.4), blurRadius: 40, spreadRadius: 10)], image: widget.doctorImage?.trim().isNotEmpty == true ? DecorationImage(image: NetworkImage(widget.doctorImage!.trim()), fit: BoxFit.cover) : null), child: widget.doctorImage?.trim().isNotEmpty == true ? null : const Icon(Icons.person_rounded, color: Colors.white, size: 58));

  Widget _topBar(String status) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_glassIcon(Icons.close_rounded, _end), _statusBadge(_joined ? _fmt(_seconds) : status), if (widget.isVideo && _remoteTrack != null) _glassIcon(Icons.swap_vert_rounded, () => setState(() => _swapped = !_swapped)) else const SizedBox(width: 44)]);

  Widget _statusBadge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), decoration: BoxDecoration(color: _teal.withOpacity(.15), borderRadius: BorderRadius.circular(24), border: Border.all(color: _teal.withOpacity(.3), width: 1.2), boxShadow: [BoxShadow(color: _teal.withOpacity(.1), blurRadius: 16)]), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_joined ? Icons.circle : Icons.lock_outline, color: _joined ? Colors.greenAccent : _cyan, size: 14), const SizedBox(width: 7), Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))]));

  Widget _glassIcon(IconData icon, VoidCallback onTap) => Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.16)), child: Icon(icon, color: Colors.white, size: 22))));

  Widget _controls() => ClipRRect(borderRadius: BorderRadius.circular(30), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11), decoration: BoxDecoration(color: _darkCard.withOpacity(.9), border: Border.all(color: Colors.white.withOpacity(.1)), borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 25, spreadRadius: 3)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
    _controlButton(Icons.volume_up_rounded, 'سماعة', _darkCard, _toggleSpeaker, active: _speaker),
    _controlButton(_muted ? Icons.mic_off_rounded : Icons.mic_rounded, 'كتم', _cyan, _mute, active: _muted),
    if (widget.isVideo) _controlButton(_cameraEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded, 'كاميرا', _cyan, _toggleCamera, active: !_cameraEnabled),
    if (widget.isVideo) _controlButton(Icons.cameraswitch_rounded, 'تبديل', _teal, _switchCamera),
    _controlButton(Icons.call_end_rounded, 'إنهاء', _red, _end, main: true),
  ])));

  Widget _controlButton(IconData icon, String label, Color color, VoidCallback onTap, {bool active = false, bool main = false}) => Column(mainAxisSize: MainAxisSize.min, children: [Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(32), child: AnimatedContainer(duration: const Duration(milliseconds: 220), width: main ? 68 : 58, height: main ? 68 : 58, decoration: BoxDecoration(shape: BoxShape.circle, color: main ? color : (active ? color.withOpacity(.22) : color.withOpacity(.12)), border: Border.all(color: main ? color : color.withOpacity(.7), width: main ? 0 : 1.4), boxShadow: main ? [BoxShadow(color: color.withOpacity(.4), blurRadius: 20, spreadRadius: 4)] : null), child: Icon(icon, color: main ? Colors.white : color, size: main ? 30 : 25)))), const SizedBox(height: 5), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500))]);

  String _fmt(int seconds) { final h = seconds ~/ 3600; final m = (seconds % 3600) ~/ 60; final s = seconds % 60; if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'; return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'; }
}
