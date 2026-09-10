import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:sehatak/core/config/livekit_config.dart';
import 'package:sehatak/core/services/toast_service.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  bool _isCameraEnabled = false;
  bool _isMicrophoneEnabled = false;
  bool _isSpeakerOn = false;
  bool _isConnected = false;
  bool _isFrontCamera = true;

  Room? get room => _room;
  bool get isConnected => _isConnected;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isMicrophoneEnabled => _isMicrophoneEnabled;

  Future<Map<String, dynamic>> _requestLiveKitToken({required String roomName, required String participantName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول قبل إجراء المكالمة');
    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) throw Exception('تعذر الحصول على رمز مصادقة Firebase');
    final base = LiveKitConfig.tokenServerUrl.replaceFirst(RegExp(r'/$'), '');
    final response = await http.post(Uri.parse('$base/token'), headers: {'Authorization': 'Bearer $idToken', 'Content-Type': 'application/json'}, body: jsonEncode({'roomName': roomName, 'participantName': participantName})).timeout(const Duration(seconds: 15));
    Map<String, dynamic> payload = {};
    try { final decoded = jsonDecode(response.body); if (decoded is Map) payload = Map<String, dynamic>.from(decoded); } catch (_) {}
    if (response.statusCode != 200 || payload['success'] != true) throw Exception(payload['message']?.toString() ?? 'تعذر إنشاء توكن LiveKit (${response.statusCode})');
    final data = payload['data'];
    if (data is! Map) throw Exception('بيانات LiveKit غير صالحة');
    final value = Map<String, dynamic>.from(data);
    if ((value['token']?.toString() ?? '').isEmpty) throw Exception('توكن LiveKit فارغ');
    if ((value['url']?.toString() ?? '').isEmpty) throw Exception('رابط LiveKit فارغ');
    return value;
  }

  Future<Room> connectRoom({required String roomName, String? participantName}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول قبل إجراء المكالمة');
      final name = participantName?.trim().isNotEmpty == true ? participantName!.trim() : (user.displayName?.trim().isNotEmpty == true ? user.displayName!.trim() : 'مستخدم');
      final tokenData = await _requestLiveKitToken(roomName: roomName, participantName: name);
      await _room?.disconnect();
      _room = Room();
      const options = RoomOptions(adaptiveStream: true, dynacast: true, defaultVideoPublishOptions: VideoPublishOptions(simulcast: false), defaultAudioPublishOptions: AudioPublishOptions());
      await _room!.connect(tokenData['url'] as String, tokenData['token'] as String, roomOptions: options);
      _isConnected = true;
      await enableMicrophone();
      await setSpeakerphone(_isSpeakerOn);
      return _room!;
    } catch (_) {
      _isConnected = false;
      ToastService.showError('❌ فشل الاتصال بالمكالمة');
      rethrow;
    }
  }

  Future<Room> startCall({required String roomName, String? callerName, bool isVideo = true}) async {
    final result = await connectRoom(roomName: roomName, participantName: callerName);
    if (isVideo) await enableCamera();
    return result;
  }

  Future<void> enableCamera() async { try { final p = _room?.localParticipant; if (p == null) throw Exception(); await p.setCameraEnabled(true); _isCameraEnabled = true; } catch (_) { ToastService.showError('❌ فشل تشغيل الكاميرا'); } }
  Future<void> enableMicrophone() async { try { final p = _room?.localParticipant; if (p == null) throw Exception(); await p.setMicrophoneEnabled(true); _isMicrophoneEnabled = true; } catch (_) { ToastService.showError('❌ فشل تشغيل الميكروفون'); } }
  Future<bool> toggleCamera() async { try { final p = _room?.localParticipant; if (p == null) return _isCameraEnabled; final state = !_isCameraEnabled; await p.setCameraEnabled(state); _isCameraEnabled = state; return state; } catch (_) { return _isCameraEnabled; } }
  Future<bool> toggleMicrophone() async { try { final p = _room?.localParticipant; if (p == null) return _isMicrophoneEnabled; final state = !_isMicrophoneEnabled; await p.setMicrophoneEnabled(state); _isMicrophoneEnabled = state; return state; } catch (_) { return _isMicrophoneEnabled; } }
  Future<void> switchCamera() async { final participant = _room?.localParticipant; if (participant == null) return; for (final publication in participant.videoTracks) { final track = publication.track; if (track is LocalVideoTrack) { _isFrontCamera = !_isFrontCamera; await track.setCameraPosition(_isFrontCamera ? CameraPosition.front : CameraPosition.back); return; } } }
  Future<void> setSpeakerphone(bool on) async { try { await Helper.setSpeakerphoneOn(on); _isSpeakerOn = on; } catch (e) { debugPrint('LiveKit speaker route failed: $e'); } }
  Future<void> endCall() async { try { await _room?.disconnect(); } finally { try { await Helper.setSpeakerphoneOn(false); } catch (_) {} _room = null; _isConnected = false; _isCameraEnabled = false; _isMicrophoneEnabled = false; _isSpeakerOn = false; _isFrontCamera = true; } }
  void dispose() { _room?.disconnect(); _room = null; _isConnected = false; _isCameraEnabled = false; _isMicrophoneEnabled = false; _isSpeakerOn = false; _isFrontCamera = true; }
}
