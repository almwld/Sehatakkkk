import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/sound_manager.dart';
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
  final LiveKitService _live = LiveKitService();
  final CallService _calls = CallService();

  Room? _room;
  StreamSubscription<CallModel?>? _callSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _timeout;
  Timer? _timer;

  String? _callId;
  String? _roomName;
  String? _error;
  VideoTrack? _remoteTrack;
  VideoTrack? _localTrack;

  DateTime? _connectedAt;
  int _seconds = 0;

  bool _joined = false;
  bool _ending = false;
  bool _connecting = true;
  bool _muted = false;
  bool _cameraEnabled = true;
  bool _speaker = false;
  bool _networkAvailable = true;

  @override
  void initState() {
    super.initState();
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
        if (!available && !_ending) {
          ToastService.showError('انقطع اتصال الإنترنت');
        }
      });
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
    }
  }

  bool _hasNetwork(List<ConnectivityResult> result) {
    return result.any((item) => item != ConnectivityResult.none);
  }

  Future<void> _connect() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('يجب تسجيل الدخول');

      final network = await Connectivity().checkConnectivity();
      if (!_hasNetwork(network)) throw StateError('لا يوجد اتصال بالإنترنت');

      CallModel? call;
      if (widget.isOutgoing) {
        call = await _calls.initiateCall(
          receiverId: widget.doctorId,
          receiverName: widget.doctorName,
          receiverPhotoUrl: widget.doctorImage,
          type: widget.isVideo ? CallType.video : CallType.audio,
          chatId: widget.chatId,
        );
      } else {
        if (widget.callId == null || widget.callId!.trim().isEmpty) {
          throw StateError('معرّف المكالمة مفقود');
        }
        call = await _calls.streamCall(widget.callId!).first;
        if (call == null || call.receiverId != user.uid) {
          throw StateError('هذه المكالمة ليست موجهة لهذا المستخدم');
        }
      }

      if (call == null) throw StateError('تعذر العثور على المكالمة');

      _callId = call.id;
      _roomName = (call.liveKitRoomName?.trim().isNotEmpty == true)
          ? call.liveKitRoomName!.trim()
          : 'call_${call.id}';

      debugPrint(
        'CALL READY uid=${user.uid} callId=$_callId chatId=${widget.chatId} '
        'room=$_roomName outgoing=${widget.isOutgoing}',
      );

      _callSubscription = _calls.streamCall(call.id).listen(
        (updated) {
          if (!mounted || updated == null || _ending) return;

          debugPrint(
            'CALL STATE id=${updated.id} status=${updated.status} '
            'connectedAt=${updated.connectedAt}',
          );

          if (updated.status == CallStatus.connected && !_joined) {
            unawaited(_join(updated, user));
            return;
          }

          if (_isTerminal(updated.status)) {
            unawaited(_finishRemote());
          }
        },
        onError: (error) => debugPrint('CALL STREAM ERROR: $error'),
      );

      // The caller waits here until the receiver accepts. No LiveKit room is
      // joined before Firestore reaches connected.
      if (widget.isOutgoing && call.status != CallStatus.connected) {
        _timeout = Timer(const Duration(seconds: 30), () async {
          if (_ending || _joined) return;
          try {
            await _calls.missCall(call!.id);
          } catch (e) {
            debugPrint('CALL TIMEOUT update failed: $e');
          }
          if (mounted) await _finishRemote();
        });
      }

      if (call.status == CallStatus.connected) {
        await _join(call, user);
      } else if (mounted) {
        setState(() => _connecting = false);
      }
    } catch (e) {
      debugPrint('CALL CONNECT ERROR: $e');
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
      ToastService.showError('فشل تجهيز المكالمة');
    }
  }

  bool _isTerminal(CallStatus status) {
    return status == CallStatus.cancelled ||
        status == CallStatus.rejected ||
        status == CallStatus.missed ||
        status == CallStatus.ended;
  }

  Future<void> _join(CallModel call, User user) async {
    if (_joined || _ending) return;

    try {
      if (widget.isVideo) {
        final camera = await Permission.camera.request();
        if (!camera.isGranted) throw StateError('يرجى منح إذن الكاميرا');
      }

      final microphone = await Permission.microphone.request();
      if (!microphone.isGranted) throw StateError('يرجى منح إذن الميكروفون');

      if (_roomName == null || _roomName!.isEmpty) {
        throw StateError('اسم غرفة LiveKit مفقود');
      }

      _room = await _live.startCall(
        roomName: _roomName!,
        callerName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : widget.doctorName,
        isVideo: widget.isVideo,
      );

      _joined = true;
      _timeout?.cancel();

      // connectedAt is the authoritative start of the billable/visible call
      // duration. Fallback is only for an already-connected call where the
      // server timestamp has not arrived yet.
      _connectedAt = call.connectedAt?.toDate() ?? DateTime.now();
      _seconds = DateTime.now().difference(_connectedAt!).inSeconds.clamp(0, 86400);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _connectedAt == null) return;
        final elapsed = DateTime.now().difference(_connectedAt!).inSeconds;
        setState(() => _seconds = elapsed < 0 ? 0 : elapsed);
      });

      _bind(_room!.localParticipant);
      for (final participant in _room!.remoteParticipants.values) {
        _bind(participant);
      }

      _room!.events.on<ParticipantConnectedEvent>((event) {
        _bind(event.participant);
      });
      _room!.events.on<TrackSubscribedEvent>((event) {
        _bind(event.participant);
      });
      _room!.events.on<TrackPublishedEvent>((event) {
        _bind(event.participant);
      });
      _room!.events.on<ParticipantDisconnectedEvent>((event) {
        if (!mounted) return;
        setState(() => _remoteTrack = null);
      });

      // Incoming call starts in earpiece mode; the user can explicitly switch
      // to loudspeaker. Keep the real native route synchronized.
      await _live.setSpeakerphone(_speaker);

      if (mounted) {
        setState(() {
          _connecting = false;
          _error = null;
        });
      }
    } catch (e) {
      debugPrint('CALL LIVEKIT JOIN ERROR: $e');
      if (mounted) {
        setState(() {
          _connecting = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _bind(Participant? participant) {
    if (participant == null) return;

    for (final publication in participant.videoTracks) {
      final track = publication.track;
      if (track is VideoTrack && mounted) {
        setState(() {
          if (participant is LocalParticipant) {
            _localTrack = track;
          } else {
            _remoteTrack = track;
          }
        });
      }
    }
  }

  Future<void> _finishRemote() async {
    if (_ending) return;
    _ending = true;
    _timeout?.cancel();
    _timer?.cancel();
    await _callSubscription?.cancel();
    _callSubscription = null;
    SoundManager().stopAll();
    await _live.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _end() async {
    if (_ending) return;
    _ending = true;
    _timeout?.cancel();
    _timer?.cancel();
    await _callSubscription?.cancel();
    _callSubscription = null;
    SoundManager().stopAll();

    try {
      if (_callId != null) {
        await _calls.endCall(
          _callId!,
          durationSeconds: _joined ? _seconds : 0,
        );
      }
    } catch (e) {
      debugPrint('CALL END FIRESTORE ERROR: $e');
    }

    await _live.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _mute() async {
    final enabled = await _live.toggleMicrophone();
    if (mounted) setState(() => _muted = !enabled);
  }

  Future<void> _toggleCamera() async {
    final enabled = await _live.toggleCamera();
    if (mounted) setState(() => _cameraEnabled = enabled);
  }

  Future<void> _switchCamera() async {
    try {
      await _live.switchCamera();
    } catch (e) {
      debugPrint('CALL CAMERA SWITCH ERROR: $e');
    }
  }

  Future<void> _toggleSpeaker() async {
    final next = !_speaker;
    await _live.setSpeakerphone(next);
    if (mounted) setState(() => _speaker = next);
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _timer?.cancel();
    _callSubscription?.cancel();
    _connectivitySubscription?.cancel();
    SoundManager().stopAll();
    if (_joined) unawaited(_live.endCall());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _error != null
        ? _error!
        : !_networkAvailable
            ? 'لا يوجد اتصال بالإنترنت'
            : _connecting
                ? (widget.isOutgoing ? 'جاري تجهيز المكالمة...' : 'جاري الاتصال...')
                : !_joined
                    ? 'في انتظار قبول المكالمة...'
                    : _fmt(_seconds);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.isVideo && _remoteTrack != null
                  ? VideoTrackRenderer(_remoteTrack!)
                  : _waitingView(status),
            ),
            if (widget.isVideo && _localTrack != null)
              PositionedDirectional(
                top: 18,
                end: 18,
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: VideoTrackRenderer(_localTrack!),
                ),
              ),
            if (_joined && _remoteTrack != null)
              Positioned(
                top: 18,
                left: 18,
                child: _statusChip(_fmt(_seconds)),
              ),
            if (_error == null)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: _controls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _waitingView(String status) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 58,
            backgroundImage: widget.doctorImage?.trim().isNotEmpty == true
                ? NetworkImage(widget.doctorImage!.trim())
                : null,
            backgroundColor: const Color(0xFF263238),
            child: widget.doctorImage?.trim().isNotEmpty == true
                ? null
                : const Icon(Icons.person, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 18),
          Text(
            widget.doctorName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isVideo ? 'مكالمة فيديو' : 'مكالمة صوتية',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _error != null ? Colors.redAccent : Colors.white70,
              fontSize: 14,
            ),
          ),
          if (_joined) ...[
            const SizedBox(height: 8),
            Text(
              _fmt(_seconds),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
          const SizedBox(width: 7),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _controls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn(_muted ? Icons.mic_off : Icons.mic, _mute),
        if (widget.isVideo)
          _btn(
            _cameraEnabled ? Icons.videocam : Icons.videocam_off,
            _toggleCamera,
          ),
        _btn(
          _speaker ? Icons.volume_up : Icons.volume_down,
          _toggleSpeaker,
        ),
        if (widget.isVideo) _btn(Icons.flip_camera_android, _switchCamera),
        _btn(Icons.call_end, _end, red: true),
      ],
    );
  }

  Widget _btn(IconData icon, Future<void> Function() onPressed, {bool red = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FloatingActionButton(
        heroTag: '${icon.codePoint}_${red ? 'red' : 'normal'}',
        mini: true,
        backgroundColor: red ? Colors.red : Colors.white12,
        onPressed: () => unawaited(onPressed()),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  String _fmt(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
}
