import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/livekit_config.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  bool _isCameraEnabled = false;
  bool _isMicrophoneEnabled = false;

  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  // 🔑 توليد Token باستخدام JWT
  String _generateToken({
    required String roomName,
    required String participantName,
  }) {
    try {
      final jwt = JWT(
        {
          'sub': participantName,
          'iss': LiveKitConfig.apiKey,
          'name': participantName,
          'video': {
            'room': roomName,
            'roomJoin': true,
            'canPublish': true,
            'canSubscribe': true,
          },
          'exp': DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch ~/ 1000,
          'nbf': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      );

      final token = jwt.sign(SecretKey(LiveKitConfig.apiSecret));
      print('✅ Token generated successfully');
      return token;
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

      print('🔑 Token: $token');

      final options = RoomOptions(
        defaultVideoPublishOptions: const VideoPublishOptions(
          simulcast: false,
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

  // ✅ تفعيل الكاميرا
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

  // ✅ تفعيل الميكروفون
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

  // ✅ إيقاف الميكروفون
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

  // ✅ تبديل الكاميرا
  Future<bool> toggleCamera() async {
    if (_isCameraEnabled) {
      await disableCamera();
      return false;
    } else {
      await enableCamera();
      return true;
    }
  }

  // ✅ تبديل الميكروفون
  Future<bool> toggleMicrophone() async {
    if (_isMicrophoneEnabled) {
      await disableMicrophone();
      return false;
    } else {
      await enableMicrophone();
      return true;
    }
  }

  // ✅ بدء المكالمة
  Future<void> startCall({
    required String roomName,
    required String callerName,
    bool isVideo = true,
  }) async {
    try {
      await connectRoom(
        roomName: roomName,
        participantName: callerName,
      );
      
      await enableMicrophone();
      
      if (isVideo) {
        await enableCamera();
      }
      
      print('✅ Call started successfully');
    } catch (e) {
      print('❌ Failed to start call: $e');
      rethrow;
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
