import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../config/livekit_config.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  bool _isCameraEnabled = false;
  bool _isMicrophoneEnabled = false;

  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  // 🔑 توليد Token
  String _generateToken({
    required String roomName,
    required String participantName,
  }) {
    try {
      final token = AccessToken(
        LiveKitConfig.apiKey,
        LiveKitConfig.apiSecret,
        identity: participantName,
        ttl: const Duration(minutes: 10),
      );
      
      token.addGrant(
        roomJoin: true,
        room: roomName,
        canPublish: true,
        canSubscribe: true,
      );
      
      return token.toJwt();
    } catch (e) {
      print('❌ خطأ في توليد التوكن: $e');
      rethrow;
    }
  }

  Future<Room> connectRoom({
    required String roomName,
    String? participantName,
  }) async {
    try {
      _room = Room();

      final token = _generateToken(
        roomName: roomName,
        participantName: participantName ?? 'مستخدم',
      );

      print('✅ Token generated successfully');

      final options = RoomOptions(
        defaultVideoPublishOptions: VideoPublishOptions(
          simulcast: false,
          videoCodec: VideoCodec.vp8,
        ),
        defaultAudioPublishOptions: const AudioPublishOptions(),
      );

      await _room!.connect(
        LiveKitConfig.serverUrl,
        token,
        roomOptions: options,
      );

      print('✅ Connected to room: $roomName');
      
      return _room!;
    } catch (e) {
      print('❌ فشل الاتصال: $e');
      rethrow;
    }
  }

  // ✅ تفعيل الكاميرا مع معالجة الأخطاء
  Future<void> enableCamera() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setCameraEnabled(true);
        _isCameraEnabled = true;
        print('✅ Camera enabled successfully');
      } else {
        print('⚠️ No local participant found');
      }
    } catch (e) {
      print('❌ Failed to enable camera: $e');
      rethrow;
    }
  }

  // ✅ تفعيل الميكروفون مع معالجة الأخطاء
  Future<void> enableMicrophone() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setMicrophoneEnabled(true);
        _isMicrophoneEnabled = true;
        print('✅ Microphone enabled successfully');
      } else {
        print('⚠️ No local participant found');
      }
    } catch (e) {
      print('❌ Failed to enable microphone: $e');
      rethrow;
    }
  }

  // ✅ بدء المكالمة مع تفعيل الكاميرا والميكروفون
  Future<void> startCall({
    required String roomName,
    required String callerName,
    bool isVideo = true,
  }) async {
    try {
      // 1. الاتصال بالغرفة
      await connectRoom(
        roomName: roomName,
        participantName: callerName,
      );
      
      // 2. تفعيل الميكروفون دائماً
      await enableMicrophone();
      
      // 3. تفعيل الكاميرا إذا كانت مكالمة فيديو
      if (isVideo) {
        await enableCamera();
      }
      
      print('✅ Call started successfully');
    } catch (e) {
      print('❌ Failed to start call: $e');
      rethrow;
    }
  }

  // ✅ إيقاف الكاميرا
  Future<void> disableCamera() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setCameraEnabled(false);
        _isCameraEnabled = false;
        print('✅ Camera disabled');
      }
    } catch (e) {
      print('❌ Failed to disable camera: $e');
    }
  }

  // ✅ إيقاف الميكروفون (كتم الصوت)
  Future<void> disableMicrophone() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setMicrophoneEnabled(false);
        _isMicrophoneEnabled = false;
        print('✅ Microphone disabled');
      }
    } catch (e) {
      print('❌ Failed to disable microphone: $e');
    }
  }

  // ✅ تبديل حالة الكاميرا
  Future<bool> toggleCamera() async {
    if (_isCameraEnabled) {
      await disableCamera();
      return false;
    } else {
      await enableCamera();
      return true;
    }
  }

  // ✅ تبديل حالة الميكروفون
  Future<bool> toggleMicrophone() async {
    if (_isMicrophoneEnabled) {
      await disableMicrophone();
      return false;
    } else {
      await enableMicrophone();
      return true;
    }
  }

  Future<void> endCall() async {
    try {
      await _room?.disconnect();
      _room = null;
      _isCameraEnabled = false;
      _isMicrophoneEnabled = false;
      print('✅ Call ended');
    } catch (e) {
      print('❌ Failed to end call: $e');
    }
  }

  void dispose() {
    _room?.disconnect();
    _room = null;
    _isCameraEnabled = false;
    _isMicrophoneEnabled = false;
  }
}
