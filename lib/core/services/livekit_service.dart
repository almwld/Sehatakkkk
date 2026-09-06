import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:sehatak/core/services/toast_service.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  Room? _room;
  bool _isCameraEnabled = false;
  bool _isMicrophoneEnabled = false;
  bool _isSpeakerOn = false;
  bool _isConnected = false;

  Room? get room => _room;
  bool get isConnected => _isConnected;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isMicrophoneEnabled => _isMicrophoneEnabled;

  Future<Map<String, dynamic>> _requestLiveKitToken({required String roomName, required String participantIdentity, required String participantName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول قبل إجراء المكالمة');
    if (participantIdentity != user.uid) throw Exception('هوية المشارك غير صالحة');
    final result = await _functions.httpsCallable('createLiveKitToken').call({
      'roomName': roomName,
      'participantIdentity': participantIdentity,
      'participantName': participantName,
    });
    final raw = result.data;
    if (raw is! Map) throw Exception('استجابة LiveKit غير صالحة');
    final response = Map<String, dynamic>.from(raw);
    if (response['success'] != true) throw Exception(response['message']?.toString() ?? 'فشل إنشاء توكن LiveKit');
    final data = response['data'];
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
      final tokenData = await _requestLiveKitToken(roomName: roomName, participantIdentity: user.uid, participantName: name);
      await _room?.disconnect();
      _room = Room();
      const options = RoomOptions(adaptiveStream: true, dynacast: true, defaultVideoPublishOptions: VideoPublishOptions(simulcast: false), defaultAudioPublishOptions: AudioPublishOptions());
      await _room!.connect(tokenData['url'] as String, tokenData['token'] as String, roomOptions: options);
      _isConnected = true;
      await enableMicrophone();
      return _room!;
    } catch (_) {
      _isConnected = false;
      ToastService.showError('❌ فشل الاتصال بالمكالمة');
      rethrow;
    }
  }

  Future<void> enableCamera() async { try { final p = _room?.localParticipant; if (p == null) throw Exception(); await p.setCameraEnabled(true); _isCameraEnabled = true; } catch (_) { ToastService.showError('❌ فشل تشغيل الكاميرا'); } }
  Future<void> enableMicrophone() async { try { final p = _room?.localParticipant; if (p == null) throw Exception(); await p.setMicrophoneEnabled(true); _isMicrophoneEnabled = true; } catch (_) { ToastService.showError('❌ فشل تشغيل الميكروفون'); } }
  Future<bool> toggleCamera() async { try { final p = _room?.localParticipant; if (p == null) return _isCameraEnabled; final state = !_isCameraEnabled; await p.setCameraEnabled(state); _isCameraEnabled = state; return state; } catch (_) { return _isCameraEnabled; } }
  Future<bool> toggleMicrophone() async { try { final p = _room?.localParticipant; if (p == null) return _isMicrophoneEnabled; final state = !_isMicrophoneEnabled; await p.setMicrophoneEnabled(state); _isMicrophoneEnabled = state; return state; } catch (_) { return _isMicrophoneEnabled; } }
  void setSpeakerphone(bool on) => _isSpeakerOn = on;
  Future<void> endCall() async { try { await _room?.disconnect(); } finally { _room = null; _isConnected = false; _isCameraEnabled = false; _isMicrophoneEnabled = false; _isSpeakerOn = false; } }
  void dispose() { _room?.disconnect(); _room = null; _isConnected = false; _isCameraEnabled = false; _isMicrophoneEnabled = false; _isSpeakerOn = false; }
}
