import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/toast_service.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;
  final String? callId;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = true,
    this.callId,
    this.isOutgoing = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  final LiveKitService _liveKitService = LiveKitService();
  Timer? _timer;
  Timer? _roomRefreshTimer;
  Room? _room;
  String? _activeCallId;
  int _seconds = 0;
  bool _starting = true;
  bool _connected = false;
  bool _muted = false;
  bool _speaker = false;
  bool _cameraOff = false;
  bool _outgoing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final mic = await Permission.microphone.request();
      if (!mic.isGranted) throw Exception('إذن الميكروفون مطلوب');

      if (widget.isVideo) {
        final camera = await Permission.camera.request();
        if (!camera.isGranted) throw Exception('إذن الكاميرا مطلوب');
      }

      _outgoing = widget.isOutgoing || widget.callId == null || widget.callId!.isEmpty;
      if (_outgoing) {
        if (widget.callId != null && widget.callId!.isNotEmpty) {
          _activeCallId = widget.callId;
        } else {
          final call = await _callService.initiateCall(
            receiverId: widget.doctorId,
            receiverName: widget.doctorName,
            type: widget.isVideo ? CallType.video : CallType.audio,
            chatId: widget.chatId,
          );
          _activeCallId = call?.id;
          if (_activeCallId == null || _activeCallId!.isEmpty) throw Exception('تعذر إنشاء المكالمة');
        }
      } else {
        _activeCallId = widget.callId;
        await _callService.acceptCall(_activeCallId!);
      }

      _room = await _liveKitService.connectRoom(
        roomName: 'call_${_activeCallId!}',
        participantName: user.displayName ?? 'مستخدم',
      );
      if (widget.isVideo) await _liveKitService.enableCamera();

      if (!mounted) return;
      setState(() {
        _starting = false;
        _connected = true;
        _error = null;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
      _roomRefreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _connected = false;
        _error = e.toString();
      });
      ToastService.showError('❌ فشل الاتصال بالمكالمة');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _roomRefreshTimer?.cancel();
    _liveKitService.endCall();
    super.dispose();
  }

  Future<void> _endCall() async {
    final callId = _activeCallId;
    try {
      if (callId != null && callId.isNotEmpty) {
        if (_connected) {
          await _callService.endCall(callId, durationSeconds: _seconds);
        } else if (_outgoing) {
          await _callService.cancelCall(callId);
        }
      }
    } catch (e) {
      debugPrint('Call end error: $e');
    } finally {
      await _liveKitService.endCall();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _toggleMute() async {
    final enabled = await _liveKitService.toggleMicrophone();
    if (mounted) setState(() => _muted = !enabled);
  }

  Future<void> _toggleCamera() async {
    if (!widget.isVideo) return;
    final enabled = await _liveKitService.toggleCamera();
    if (mounted) setState(() => _cameraOff = !enabled);
  }

  void _toggleSpeaker() {
    _speaker = !_speaker;
    _liveKitService.setSpeakerphone(_speaker);
    setState(() {});
  }

  LocalVideoTrack? _localVideoTrack() {
    final participant = _room?.localParticipant;
    if (participant == null) return null;
    for (final publication in participant.trackPublications.values) {
      final track = publication.track;
      if (track is LocalVideoTrack) return track;
    }
    return null;
  }

  RemoteVideoTrack? _remoteVideoTrack() {
    final room = _room;
    if (room == null) return null;
    for (final participant in room.remoteParticipants.values) {
      for (final publication in participant.trackPublications.values) {
        final track = publication.track;
        if (track is RemoteVideoTrack) return track;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final remoteTrack = _remoteVideoTrack();
    final localTrack = _localVideoTrack();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.isVideo && remoteTrack != null
                  ? VideoTrackRenderer(remoteTrack)
                  : Container(color: Colors.black, child: _audioCenter()),
            ),
            if (widget.isVideo && localTrack != null && !_cameraOff)
              Positioned(
                top: 70,
                right: 16,
                width: 120,
                height: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: VideoTrackRenderer(localTrack),
                ),
              ),
            Positioned(top: 0, left: 0, right: 0, child: _topBar()),
            if (_error != null)
              Positioned(
                left: 20,
                right: 20,
                top: 130,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            Positioned(left: 0, right: 0, bottom: 24, child: _controls()),
          ],
        ),
      ),
    );
  }

  Widget _audioCenter() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 58,
              backgroundColor: AppColors.primary.withOpacity(.2),
              child: const Icon(Icons.person, color: Colors.white, size: 58),
            ),
            const SizedBox(height: 16),
            Text(
              widget.doctorName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _starting ? 'جاري الاتصال...' : (_connected ? 'مكالمة صوتية متصلة' : 'بانتظار الاتصال'),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );

  Widget _topBar() => Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(.65), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            IconButton(onPressed: _endCall, icon: const Icon(Icons.close, color: Colors.white)),
            const Spacer(),
            Text(_formatDuration(_seconds), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (_connected ? Colors.green : Colors.orange).withOpacity(.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _connected ? 'متصل' : 'جاري الاتصال',
                style: TextStyle(color: _connected ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11),
              ),
            ),
          ],
        ),
      );

  Widget _controls() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.65),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _control(icon: _muted ? Icons.mic_off : Icons.mic, label: _muted ? 'إلغاء الكتم' : 'كتم', onTap: _toggleMute),
            if (widget.isVideo)
              _control(icon: _cameraOff ? Icons.videocam_off : Icons.videocam, label: _cameraOff ? 'تشغيل' : 'كاميرا', onTap: _toggleCamera),
            _control(icon: _speaker ? Icons.volume_up : Icons.volume_down, label: 'مكبر', onTap: _toggleSpeaker),
            _control(icon: Icons.call_end, label: 'إنهاء', color: Colors.red, onTap: _endCall),
          ],
        ),
      );

  Widget _control({required IconData icon, required String label, required VoidCallback onTap, Color color = Colors.white24}) => Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      );

  String _formatDuration(int seconds) => '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
