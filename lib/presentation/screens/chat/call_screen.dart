import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/models/call_model.dart';

class CallScreen extends StatefulWidget {
  final String chatId, doctorName, doctorId;
  final bool isVideo;
  final String? doctorImage, callId;
  const CallScreen({super.key, required this.chatId, required this.doctorName, required this.doctorId, this.isVideo = false, this.doctorImage, this.callId});
  @override State<CallScreen> createState() => _CallScreenState();
}
class _CallScreenState extends State<CallScreen> {
  final _auth = FirebaseAuth.instance; final _calls = CallService(); final _liveKit = LiveKitService(); final _chat = ChatService();
  String? _callId; bool _muted = false, _speaker = false, _camera = true, _connected = false; int _seconds = 0; Timer? _timer;
  @override void initState() { super.initState(); _start(); }
  Future<void> _start() async { try { final uid = _auth.currentUser?.uid; if (uid == null) throw Exception('يجب تسجيل الدخول'); _callId = widget.callId ?? await _calls.initiateCall(callerId: uid, receiverId: widget.doctorId, chatId: widget.chatId, type: widget.isVideo ? CallType.video : CallType.audio); await _chat.sendSystemMessage(chatId: widget.chatId, text: 'بدأت المكالمة', metadata: {'callId': _callId, 'type': widget.isVideo ? 'video' : 'audio', 'status': 'calling'}); await _liveKit.connectRoom(roomName: widget.chatId, participantName: _auth.currentUser?.displayName ?? 'مستخدم'); if (!mounted) return; setState(() => _connected = true); _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted && _connected) setState(() => _seconds++); }); } catch (e) { if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاتصال: $e'))); Navigator.pop(context); } } }
  String get _duration => '${(_seconds ~/ 60).toString().padLeft(2,'0')}:${(_seconds % 60).toString().padLeft(2,'0')}';
  Future<void> _end() async { _timer?.cancel(); if (_callId != null) await _calls.endCall(_callId!, durationSeconds: _seconds); await _chat.sendSystemMessage(chatId: widget.chatId, text: 'انتهت المكالمة ($_duration)', metadata: {'callId': _callId, 'duration': _seconds, 'status': 'ended'}); _liveKit.endCall(); if (mounted) Navigator.pop(context); }
  @override void dispose() { _timer?.cancel(); _liveKit.endCall(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: SafeArea(child: Stack(children: [Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 52, backgroundColor: AppColors.primary, backgroundImage: widget.doctorImage == null ? null : NetworkImage(widget.doctorImage!), child: widget.doctorImage == null ? Text(widget.doctorName.isEmpty ? 'ط' : widget.doctorName[0], style: const TextStyle(fontSize: 38, color: Colors.white)) : null), const SizedBox(height: 16), Text(widget.doctorName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(_connected ? _duration : 'جاري الاتصال...', style: const TextStyle(color: Colors.white70))])), Positioned(bottom: 30, left: 12, right: 12, child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_button(_muted ? Icons.mic_off : Icons.mic, () { setState(() => _muted = !_muted); _liveKit.toggleMicrophone(); }), _button(_speaker ? Icons.volume_up : Icons.volume_off, () { setState(() => _speaker = !_speaker); _liveKit.setSpeakerphone(_speaker); }), if (widget.isVideo) _button(_camera ? Icons.videocam : Icons.videocam_off, () { setState(() => _camera = !_camera); _liveKit.toggleCamera(); }), _button(Icons.call_end, _end, color: Colors.red)]))])));
  Widget _button(IconData icon, VoidCallback onTap, {Color color = Colors.white}) => CircleAvatar(backgroundColor: color == Colors.red ? Colors.red : Colors.white24, radius: 28, child: IconButton(onPressed: onTap, icon: Icon(icon, color: color)));
}
