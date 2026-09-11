import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/active_call_registry.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/models/call_model.dart';

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
  bool _muted = false, _speaker = false, _camera = true, _connected = false, _ending = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('يجب تسجيل الدخول');

      if (widget.isOutgoing) {
        final call = await _calls.initiateCall(
          receiverId: widget.doctorId,
          receiverName: widget.doctorName,
          receiverPhotoUrl: widget.doctorImage,
          chatId: widget.chatId,
          type: widget.isVideo ? CallType.video : CallType.audio,
        );
        if (call == null) throw Exception('تعذر إنشاء المكالمة');
        _callId = call.id;
      } else {
        _callId = widget.callId;
        if (_callId == null || _callId!.isEmpty) {
          throw Exception('معرّف المكالمة غير موجود');
        }
      }

      final id = _callId!;
      _callSubscription = _calls.streamCall(id).listen((call) {
        if (!mounted || call == null || _ending) return;
        if (call.status == CallStatus.ended ||
            call.status == CallStatus.rejected ||
            call.status == CallStatus.cancelled ||
            call.status == CallStatus.missed ||
            call.status == CallStatus.busy) {
          unawaited(_finishRemote());
        }
      }, onError: (error) {
        debugPrint('CALL SCREEN STREAM ERROR id=$id error=$error');
      });

      await _liveKit.connectRoom(
        roomName: 'call_$id',
        participantName: _auth.currentUser?.displayName ?? 'مستخدم',
      );
      if (widget.isVideo) await _liveKit.enableCamera();

      // Register immediately after LiveKit connects. This closes the race
      // where a second incoming call could arrive before Firestore updates.
      ActiveCallRegistry.instance.register(id);

      if (!mounted) return;
      setState(() => _connected = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _connected && !_ending) setState(() => _seconds++);
      });
    } catch (e) {
      ActiveCallRegistry.instance.unregister(_callId);
      await _callSubscription?.cancel();
      _callSubscription = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاتصال: $e')));
        Navigator.pop(context);
      }
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

    // Release the local guard before any Firestore/network await so a queued
    // incoming call can become eligible immediately after this call ends.
    ActiveCallRegistry.instance.unregister(id);
    await _callSubscription?.cancel();
    _callSubscription = null;

    if (id != null && id.isNotEmpty) {
      try {
        await _calls.endCall(id, durationSeconds: _seconds);
      } catch (_) {}
    }
    await _liveKit.endCall();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _ending = true;
    _timer?.cancel();
    _callSubscription?.cancel();
    ActiveCallRegistry.instance.unregister(_callId);
    unawaited(_liveKit.endCall());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primary,
                  backgroundImage: widget.doctorImage == null ? null : NetworkImage(widget.doctorImage!),
                  child: widget.doctorImage == null ? Text(widget.doctorName.isEmpty ? 'ط' : widget.doctorName[0], style: const TextStyle(fontSize: 38, color: Colors.white)) : null,
                ),
                const SizedBox(height: 16),
                Text(widget.doctorName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_connected ? _duration : (widget.isOutgoing ? 'جاري الاتصال...' : 'جاري الانضمام...'), style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _button(_muted ? Icons.mic_off : Icons.mic, () { setState(() => _muted = !_muted); _liveKit.toggleMicrophone(); }),
                _button(_speaker ? Icons.volume_up : Icons.volume_off, () { setState(() => _speaker = !_speaker); _liveKit.setSpeakerphone(_speaker); }),
                if (widget.isVideo) _button(_camera ? Icons.videocam : Icons.videocam_off, () { setState(() => _camera = !_camera); _liveKit.toggleCamera(); }),
                _button(Icons.call_end, _end, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _button(IconData icon, VoidCallback onTap, {Color color = Colors.white}) => CircleAvatar(
    backgroundColor: color == Colors.red ? Colors.red : Colors.white24,
    radius: 28,
    child: IconButton(onPressed: onTap, icon: Icon(icon, color: color)),
  );
}
