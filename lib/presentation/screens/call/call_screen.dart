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

  int _callDuration = 0;
  bool _isConnecting = true;
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  bool _isConnected = false;
  bool _ending = false;
  String _errorMessage = '';

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

    if (widget.callId != null && widget.callId!.trim().isNotEmpty) {
      final fromCall = await _callService.resolveChatId(widget.callId!.trim());
      if (fromCall != null && fromCall.trim().isNotEmpty) return fromCall.trim();
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

      final microphone = await Permission.microphone.request();
      if (!microphone.isGranted) throw Exception('إذن الميكروفون مطلوب');

      if (widget.isVideo) {
        final camera = await Permission.camera.request();
        if (!camera.isGranted) throw Exception('إذن الكاميرا مطلوب');
      }

      _resolvedChatId = await _resolveChatId();
      final outgoing = widget.isOutgoing || widget.callId == null || widget.callId!.trim().isEmpty;

      if (outgoing) {
        if (widget.callId != null && widget.callId!.trim().isNotEmpty) {
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
        _activeCallId = widget.callId?.trim();
        if (_activeCallId == null || _activeCallId!.isEmpty) {
          throw Exception('معرّف المكالمة الواردة غير صالح');
        }
        await _callService.acceptCall(_activeCallId!);
      }

      if (_activeCallId == null || _activeCallId!.isEmpty) {
        throw Exception('تعذر إنشاء المكالمة');
      }

      final roomName = 'call_$_activeCallId';
      _room = await _liveKit.connectRoom(
        roomName: roomName,
        participantName: user.displayName ?? 'مستخدم',
      );

      if (widget.isVideo) {
        await _liveKit.enableCamera();
        _isCameraOn = _liveKit.isCameraEnabled;
      } else {
        _isCameraOn = false;
      }

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isConnected = true;
        _errorMessage = '';
      });

      _startDurationTimer();
      _listenToCallStatus();
    } catch (e) {
      SoundManager().stopAll();
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isConnected = false;
        _errorMessage = _cleanError(e);
      });
      ToastService.showError('❌ فشل الاتصال: $_errorMessage');
    }
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  void _listenToCallStatus() {
    final callId = _activeCallId;
    if (callId == null || callId.isEmpty) return;
    _callSubscription?.cancel();
    _callSubscription = _callService.streamCall(callId).listen((call) {
      if (!mounted || call == null || _ending) return;
      if (call.status == CallStatus.cancelled ||
          call.status == CallStatus.rejected ||
          call.status == CallStatus.missed ||
          call.status == CallStatus.ended) {
        _finishFromRemote();
      }
    }, onError: (error) {
      debugPrint('Call status stream error: $error');
    });
  }

  Future<void> _finishFromRemote() async {
    if (_ending) return;
    _ending = true;
    _durationTimer?.cancel();
    await _liveKit.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isConnected) setState(() => _callDuration++);
    });
  }

  Future<void> _toggleMute() async {
    final enabled = await _liveKit.toggleMicrophone();
    if (mounted) setState(() => _isMuted = !enabled);
  }

  Future<void> _toggleCamera() async {
    if (!widget.isVideo) return;
    final enabled = await _liveKit.toggleCamera();
    if (mounted) setState(() => _isCameraOn = enabled);
  }

  void _toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    _liveKit.setSpeakerphone(_isSpeakerOn);
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (!widget.isVideo || !_isCameraOn) return;
    final participant = _room?.localParticipant;
    if (participant == null) return;
    for (final publication in participant.trackPublications.values) {
      final track = publication.track;
      if (track is LocalVideoTrack) {
        try {
          await track.switchCamera();
        } catch (e) {
          debugPrint('Switch camera error: $e');
        }
        return;
      }
    }
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

  Future<void> _endCall() async {
    if (_ending) return;
    _ending = true;
    _durationTimer?.cancel();
    SoundManager().stopAll();
    SoundManager().playCallEnd();

    final callId = _activeCallId;
    try {
      if (callId != null && callId.isNotEmpty) {
        if (_isConnected) {
          await _callService.endCall(callId, durationSeconds: _callDuration);
        } else {
          await _callService.cancelCall(callId);
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
    if (state == AppLifecycleState.detached && !_ending) {
      _durationTimer?.cancel();
    }
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
                  : _buildAudioSurface(),
            ),
            if (widget.isVideo && localTrack != null && _isCameraOn && _errorMessage.isEmpty)
              Positioned(
                top: 72,
                right: 16,
                width: 120,
                height: 170,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white54, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: VideoTrackRenderer(localTrack),
                ),
              ),
            if (widget.isVideo && _errorMessage.isEmpty) _topBar(),
            if (_errorMessage.isNotEmpty)
              Positioned.fill(child: _buildErrorSurface()),
            if (_errorMessage.isEmpty)
              Positioned(left: 0, right: 0, bottom: 18, child: _controls()),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSurface() {
    return Container(
      color: const Color(0xFF0B1121),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 62,
              backgroundColor: AppColors.primary.withOpacity(.18),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 62),
            ),
            const SizedBox(height: 20),
            Text(widget.doctorName,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _isConnecting ? 'جاري الاتصال...' : (_isConnected ? 'مكالمة متصلة' : 'بانتظار الاتصال'),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSurface() {
    return Container(
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
          Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _ending ? null : _endCall,
            icon: const Icon(Icons.arrow_back),
            label: const Text('رجوع'),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 12, 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(.72), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            IconButton(onPressed: _endCall, icon: const Icon(Icons.close_rounded, color: Colors.white)),
            const Spacer(),
            Text(_formatDuration(_callDuration), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (_isConnected ? Colors.green : Colors.orange).withOpacity(.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _isConnected ? 'متصل' : 'جاري الاتصال',
                style: TextStyle(color: _isConnected ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.72),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _control(icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded, label: _isMuted ? 'إلغاء الكتم' : 'كتم', onTap: _toggleMute),
          if (widget.isVideo)
            _control(icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded, label: _isCameraOn ? 'كاميرا' : 'تشغيل', onTap: _toggleCamera),
          if (widget.isVideo)
            _control(icon: Icons.flip_camera_ios_rounded, label: 'تبديل', onTap: _switchCamera),
          _control(icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded, label: 'مكبر', onTap: _toggleSpeaker),
          _control(icon: Icons.call_end_rounded, label: 'إنهاء', color: Colors.red, onTap: _endCall),
        ],
      ),
    );
  }

  Widget _control({required IconData icon, required String label, required VoidCallback onTap, Color color = Colors.white24}) {
    final isEnd = color == Colors.red;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: isEnd ? 58 : 52,
            height: isEnd ? 58 : 52,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  String _formatDuration(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}
