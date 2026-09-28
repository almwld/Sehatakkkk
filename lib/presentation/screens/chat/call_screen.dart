import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/active_call_registry.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/notification_service.dart';

class CallScreen extends StatefulWidget {
  final String chatId, doctorName, doctorId;
  final bool isVideo, isOutgoing;
  final String? doctorImage, callId;
  const CallScreen({super.key, required this.chatId, required this.doctorName, required this.doctorId, this.isVideo = false, this.isOutgoing = true, this.doctorImage, this.callId});
  @override State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _auth = FirebaseAuth.instance;
  final _calls = CallService();
  final _liveKit = LiveKitService();
  String? _callId;
  StreamSubscription<CallModel?>? _callSubscription;
  Room? _room;
  bool _muted = false, _speaker = true, _camera = true, _connected = false, _mediaStarting = false, _ending = false;
  double _volume = .75;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() { super.initState(); _start(); }

  Future<void> _start() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('يجب تسجيل الدخول');
      if (widget.isOutgoing) {
        final call = await _calls.initiateCall(receiverId: widget.doctorId, receiverName: widget.doctorName, receiverPhotoUrl: widget.doctorImage, chatId: widget.chatId, type: widget.isVideo ? CallType.video : CallType.audio);
        if (call == null) throw Exception('تعذر إنشاء المكالمة');
        _callId = call.id;
      } else {
        _callId = widget.callId;
        if (_callId == null || _callId!.isEmpty) throw Exception('معرّف المكالمة غير موجود');
      }

      final id = _callId!;
      _callSubscription = _calls.streamCall(id).listen((call) {
        if (!mounted || call == null || _ending) return;
        if (call.status == CallStatus.ended || call.status == CallStatus.rejected || call.status == CallStatus.cancelled || call.status == CallStatus.missed || call.status == CallStatus.busy) {
          unawaited(_finishRemote());
          return;
        }
        // For outgoing calls, do not touch microphone/camera while ringing.
        // The receiver's answer changes the call to connected and becomes
        // the single media-session boundary.
        if (call.status == CallStatus.connected && !_connected && !_mediaStarting) {
          unawaited(_connectMedia(id));
        }
      }, onError: (error) {
        debugPrint('CALL SCREEN STREAM ERROR id=$id error=$error');
      });

      // Incoming calls have already crossed the answer boundary before this
      // screen is pushed, so they can start media immediately. Outgoing calls
      // wait for the receiver to answer.
      final current = await _calls.streamCall(id).first;
      if (current?.status == CallStatus.connected) {
        await _connectMedia(id);
      }
    } catch (e) {
      await _handleStartupFailure(e);
    }
  }

  Future<void> _connectMedia(String id) async {
    if (_ending || _connected || _mediaStarting) return;
    _mediaStarting = true;
    if (mounted) setState(() {});
    try {
      final room = await _liveKit.connectRoom(
        roomName: 'call_$id',
        participantName: _auth.currentUser?.displayName ?? 'مستخدم',
      );
      _room = room;
      room.addListener(_onRoomChanged);
      if (widget.isVideo) {
        // The call UI is already visible. Camera startup happens only after
        // answer and may take a short moment; keep the video surface black.
        await _liveKit.enableCamera();
      }
      await _liveKit.setSpeakerphone(widget.isVideo || _speaker);
      _volume = await _liveKit.getCallVolume();
      ActiveCallRegistry.instance.register(id);
      if (!mounted) return;
      setState(() {
        _connected = true;
        _mediaStarting = false;
      });
      _startTimer();
      _onRoomChanged();
    } catch (e) {
      _mediaStarting = false;
      await _handleMediaFailure(e);
    }
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _connected && !_ending) setState(() => _seconds++);
    });
  }

  void _onRoomChanged() {
    if (!mounted) return;
    setState(() {});
  }

  VideoTrack? _localVideoTrack() {
    final participant = _room?.localParticipant;
    if (participant == null) return null;
    for (final publication in participant.videoTracks) {
      final track = publication.track;
      if (track is VideoTrack && publication.source == TrackSource.camera) return track;
    }
    return null;
  }

  VideoTrack? _remoteVideoTrack() {
    final participants = _room?.remoteParticipants.values ?? const <RemoteParticipant>[];
    for (final participant in participants) {
      for (final publication in participant.videoTracks) {
        final track = publication.track;
        if (track is VideoTrack && publication.source == TrackSource.camera) return track;
      }
    }
    return null;
  }

  Future<void> _handleMediaFailure(Object error) async {
    debugPrint('CALL MEDIA START FAILED: $error');
    final id = _callId;
    ActiveCallRegistry.instance.unregister(id);
    try { await _liveKit.endCall(); } catch (_) {}
    _room = null;
    if (mounted) {
      setState(() {
        _connected = false;
        _mediaStarting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تشغيل وسائط المكالمة. حاول مرة أخرى.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleStartupFailure(Object error) async {
    debugPrint('CALL SCREEN START FAILED: $error');
    final failedCallId = _callId;
    ActiveCallRegistry.instance.unregister(failedCallId);
    await _callSubscription?.cancel();
    _callSubscription = null;
    if (failedCallId != null && failedCallId.isNotEmpty) {
      try {
        final current = await _calls.streamCall(failedCallId).first;
        if (current != null && (current.status == CallStatus.calling || current.status == CallStatus.ringing || current.status == CallStatus.connected)) {
          await _calls.endCall(failedCallId);
        }
      } catch (_) {}
      await NotificationService().cancelIncomingCallNotification(failedCallId);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر الاتصال بالمكالمة. حاول مرة أخرى.')));
      Navigator.pop(context);
    }
  }

  String get _duration => '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';

  Future<void> _finishRemote() async {
    if (_ending) return;
    _ending = true;
    _timer?.cancel();
    await _callSubscription?.cancel();
    _callSubscription = null;
    ActiveCallRegistry.instance.unregister(_callId);
    await _liveKit.endCall();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _end() async {
    if (_ending) return;
    _ending = true;
    _timer?.cancel();
    final id = _callId;
    ActiveCallRegistry.instance.unregister(id);
    await _callSubscription?.cancel();
    _callSubscription = null;
    if (id != null && id.isNotEmpty) { try { await _calls.endCall(id, durationSeconds: _seconds); } catch (_) {} }
    await _liveKit.endCall();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _ending = true;
    _timer?.cancel();
    _callSubscription?.cancel();
    _room?.removeListener(_onRoomChanged);
    ActiveCallRegistry.instance.unregister(_callId);
    unawaited(_liveKit.endCall());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      _button(_muted ? Icons.mic_off : Icons.mic, () { setState(() => _muted = !_muted); _liveKit.toggleMicrophone(); }),
      _button(_speaker ? Icons.volume_up : Icons.hearing_rounded, () { setState(() => _speaker = !_speaker); _liveKit.setSpeakerphone(_speaker); }),
      if (widget.isVideo) _button(_camera ? Icons.videocam : Icons.videocam_off, () { setState(() => _camera = !_camera); _liveKit.toggleCamera(); }),
      _button(Icons.call_end, _end, color: Colors.red),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.isVideo && _connected)
              Positioned.fill(child: _buildVideoSurface())
            else
              _buildAudioSurface(),
            if (widget.isVideo && _connected)
              Positioned(top: 18, left: 18, right: 18, child: _callHeader()),
            if (widget.isVideo && _connected)
              Positioned(
                right: 18,
                top: 82,
                width: 110,
                height: 156,
                child: _buildLocalPreview(),
              ),
            if (_mediaStarting)
              const Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                ),
              ),
            if (!widget.isVideo || !_connected)
              Positioned(bottom: 18, left: 12, right: 12, child: _buildControls(controls)),
            if (widget.isVideo && _connected)
              Positioned(bottom: 18, left: 12, right: 12, child: _buildControls(controls)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSurface() {
    final remote = _remoteVideoTrack();
    if (remote != null) {
      return VideoTrackRenderer(remote, fit: VideoViewFit.cover);
    }
    return const ColoredBox(color: Colors.black);
  }

  Widget _buildLocalPreview() {
    final local = _localVideoTrack();
    if (local == null) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white54)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: VideoTrackRenderer(local, fit: VideoViewFit.cover),
    );
  }

  Widget _buildAudioSurface() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 52, backgroundColor: AppColors.primary, backgroundImage: widget.doctorImage == null ? null : NetworkImage(widget.doctorImage!), child: widget.doctorImage == null ? Text(widget.doctorName.isEmpty ? 'ط' : widget.doctorName[0], style: const TextStyle(fontSize: 38, color: Colors.white)) : null),
          const SizedBox(height: 16),
          Text(widget.doctorName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_connected ? _duration : (widget.isOutgoing ? 'في انتظار الرد...' : 'جارٍ تجهيز المكالمة...'), style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _callHeader() => Row(
    children: [
      Expanded(child: Text(widget.doctorName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      Text(_duration, style: const TextStyle(color: Colors.white70)),
    ],
  );

  Widget _buildControls(List<Widget> controls) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (_connected) Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(children: [
          const Icon(Icons.volume_down_rounded, color: Colors.white70, size: 18),
          Expanded(child: Slider(value: _volume, min: 0, max: 1, divisions: 20, onChanged: (v) { setState(() => _volume = v); _liveKit.setCallVolume(v); })),
          const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 18),
        ]),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: controls),
    ],
  );

  Widget _button(IconData icon, VoidCallback onTap, {Color color = Colors.white}) => CircleAvatar(backgroundColor: color == Colors.red ? Colors.red : Colors.white24, radius: 28, child: IconButton(onPressed: onTap, icon: Icon(icon, color: color)));
}
