import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/sound_manager.dart';
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

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  final LiveKitService _liveKit = LiveKitService();
  final CallService _callService = CallService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _durationTimer;
  StreamSubscription<CallModel?>? _callSubscription;
  Room? _room;
  String? _activeCallId;
  String? _resolvedChatId;

  int _duration = 0;
  bool _connecting = true;
  bool _muted = false;
  bool _cameraOn = true;
  bool _speakerOn = false;
  bool _connected = false;
  bool _ending = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCall();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _durationTimer?.cancel();
    _callSubscription?.cancel();
    SoundManager().stopAll();
    _liveKit.endCall();
    super.dispose();
  }

  Future<String> _resolveChatId() async {
    if (widget.chatId.trim().isNotEmpty && !widget.chatId.startsWith('call_')) {
      return widget.chatId.trim();
    }
    if (widget.callId?.trim().isNotEmpty == true) {
      final chatId = await _callService.resolveChatId(widget.callId!.trim());
      if (chatId?.trim().isNotEmpty == true) return chatId!.trim();
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');
    final snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .limit(100)
        .get();
    for (final doc in snapshot.docs) {
      final raw = doc.data()['participants'];
      final participants = raw is Iterable
          ? raw.map((e) => e.toString()).toList()
          : const <String>[];
      if (participants.contains(widget.doctorId) && doc.data()['isGroup'] != true) {
        return doc.id;
      }
    }
    throw Exception('تعذر العثور على المحادثة المرتبطة بالمكالمة');
  }

  Future<void> _startCall() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      if (!(await Permission.microphone.request()).isGranted) {
        throw Exception('إذن الميكروفون مطلوب');
      }
      if (widget.isVideo && !(await Permission.camera.request()).isGranted) {
        throw Exception('إذن الكاميرا مطلوب');
      }

      _resolvedChatId = await _resolveChatId();
      final outgoing = widget.isOutgoing || widget.callId?.trim().isNotEmpty != true;

      if (outgoing) {
        if (widget.callId?.trim().isNotEmpty == true) {
          _activeCallId = widget.callId!.trim();
        } else {
          final call = await _callService.initiateCall(
            receiverId: widget.doctorId,
            receiverName: widget.doctorName,
            type: widget.isVideo ? CallType.video : CallType.audio,
            chatId: _resolvedChatId!,
          );
          _activeCallId = call?.id;
        }
      } else {
        _activeCallId = widget.callId!.trim();
        await _callService.acceptCall(_activeCallId!);
      }

      if (_activeCallId == null || _activeCallId!.isEmpty) {
        throw Exception('تعذر إنشاء المكالمة');
      }

      _room = await _liveKit.connectRoom(
        roomName: 'call_$_activeCallId',
        participantName: user.displayName ?? 'مستخدم',
      );
      if (widget.isVideo) {
        await _liveKit.enableCamera();
        _cameraOn = _liveKit.isCameraEnabled;
      } else {
        _cameraOn = false;
      }

      if (!mounted) return;
      setState(() {
        _connecting = false;
        _connected = true;
        _error = '';
      });
      _startTimer();
      _listenToCall();
    } catch (e) {
      debugPrint('Call start error: $e');
      SoundManager().stopAll();
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _connected = false;
        _error = _cleanError(e);
      });
      ToastService.showError('❌ فشل الاتصال: $_error');
    }
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  void _listenToCall() {
    final id = _activeCallId;
    if (id == null || id.isEmpty) return;
    _callSubscription?.cancel();
    _callSubscription = _callService.streamCall(id).listen((call) {
      if (!mounted || call == null || _ending) return;
      if (call.status == CallStatus.cancelled ||
          call.status == CallStatus.rejected ||
          call.status == CallStatus.missed ||
          call.status == CallStatus.ended) {
        _finishRemote();
      }
    });
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _connected) setState(() => _duration++);
    });
  }

  Future<void> _toggleMute() async {
    final enabled = await _liveKit.toggleMicrophone();
    if (mounted) setState(() => _muted = !enabled);
  }

  Future<void> _toggleCamera() async {
    if (!widget.isVideo) return;
    final enabled = await _liveKit.toggleCamera();
    if (mounted) setState(() => _cameraOn = enabled);
  }

  Future<void> _switchCamera() async {
    if (!widget.isVideo || !_cameraOn) return;
    final participant = _room?.localParticipant;
    if (participant == null) return;
    LocalVideoTrack? track;
    for (final publication in participant.trackPublications.values) {
      if (publication.track is LocalVideoTrack) {
        track = publication.track as LocalVideoTrack;
        break;
      }
    }
    if (track == null) return;

    try {
      final devices = await Hardware.instance.videoInputs();
      if (devices.length < 2) {
        ToastService.showInfo('لا توجد كاميرا أخرى متاحة');
        return;
      }
      final current = Hardware.instance.selectedVideoInput?.deviceId;
      final target = devices.firstWhere(
        (device) => device.deviceId != current,
        orElse: () => devices.first,
      );
      await track.switchCamera(target.deviceId);
      Hardware.instance.selectedVideoInput = target;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Switch camera error: $e');
      ToastService.showError('تعذر تبديل الكاميرا');
    }
  }

  void _toggleSpeaker() {
    _speakerOn = !_speakerOn;
    _liveKit.setSpeakerphone(_speakerOn);
    setState(() {});
  }

  LocalVideoTrack? _localTrack() {
    final participant = _room?.localParticipant;
    if (participant == null) return null;
    for (final publication in participant.trackPublications.values) {
      if (publication.track is LocalVideoTrack) return publication.track as LocalVideoTrack;
    }
    return null;
  }

  RemoteVideoTrack? _remoteTrack() {
    final room = _room;
    if (room == null) return null;
    for (final participant in room.participants.values) {
      for (final publication in participant.trackPublications.values) {
        if (publication.track is RemoteVideoTrack) {
          return publication.track as RemoteVideoTrack;
        }
      }
    }
    return null;
  }

  Future<void> _finishRemote() async {
    if (_ending) return;
    _ending = true;
    _durationTimer?.cancel();
    await _liveKit.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _endCall() async {
    if (_ending) return;
    _ending = true;
    _durationTimer?.cancel();
    SoundManager().stopAll();
    final id = _activeCallId;
    try {
      if (id != null && id.isNotEmpty) {
        if (_connected) {
          await _callService.endCall(id, durationSeconds: _duration);
        } else {
          await _callService.cancelCall(id);
        }
      }
    } catch (e) {
      debugPrint('Call end error: $e');
    } finally {
      await _liveKit.endCall();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) _durationTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final remote = _remoteTrack();
    final local = _localTrack();
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.isVideo && remote != null
                  ? VideoTrackRenderer(remote)
                  : _audioSurface(),
            ),
            if (widget.isVideo && local != null && _cameraOn && _error.isEmpty)
              Positioned(
                top: 70,
                right: 16,
                width: 120,
                height: 170,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: VideoTrackRenderer(local),
                ),
              ),
            if (_error.isEmpty) _topBar(),
            if (_error.isNotEmpty) Positioned.fill(child: _errorSurface()),
            if (_error.isEmpty)
              Positioned(left: 0, right: 0, bottom: 18, child: _controls()),
          ],
        ),
      ),
    );
  }

  Widget _audioSurface() => Container(
        color: const Color(0xFF0B1121),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 62,
              backgroundColor: AppColors.primary.withOpacity(.18),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 62),
            ),
            const SizedBox(height: 20),
            Text(widget.doctorName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _connecting ? 'جاري الاتصال...' : (_connected ? 'مكالمة متصلة' : 'بانتظار الاتصال'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );

  Widget _errorSurface() => Container(
        color: const Color(0xFF0B1121),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            const Text('تعذر الاتصال', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: _ending ? null : _endCall, icon: const Icon(Icons.arrow_back), label: const Text('رجوع')),
          ],
        ),
      );

  Widget _topBar() => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 20),
          decoration: BoxDecoration(color: Colors.black.withOpacity(.38)),
          child: Row(
            children: [
              IconButton(onPressed: _endCall, icon: const Icon(Icons.close_rounded, color: Colors.white)),
              const Spacer(),
              Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text(_connected ? 'متصل' : 'جاري الاتصال', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _controls() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(color: Colors.black.withOpacity(.72), borderRadius: BorderRadius.circular(28)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _control(Icons.mic_off_rounded, _muted ? 'إلغاء الكتم' : 'كتم', _toggleMute),
            if (widget.isVideo) _control(_cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded, _cameraOn ? 'كاميرا' : 'تشغيل', _toggleCamera),
            if (widget.isVideo) _control(Icons.flip_camera_ios_rounded, 'تبديل', _switchCamera),
            _control(_speakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded, 'مكبر', _toggleSpeaker),
            _control(Icons.call_end_rounded, 'إنهاء', _endCall, color: Colors.red),
          ],
        ),
      );

  Widget _control(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white24}) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: color == Colors.red ? 58 : 52,
              height: color == Colors.red ? 58 : 52,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      );

  String _formatDuration(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
