import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../config/livekit_config.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;

  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  // 🔑 توليد Token باستخدام API Key و Secret مباشرة
  String _generateToken({
    required String roomName,
    required String participantName,
  }) {
    try {
      // ✅ AccessToken من livekit_client
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
      
      // ✅ تمكين الصوت
      await _room?.localParticipant?.setMicrophoneEnabled(true);

      return _room!;
    } catch (e) {
      print('❌ فشل الاتصال: $e');
      rethrow;
    }
  }

  Future<void> enableCamera() async {
    await _room?.localParticipant?.setCameraEnabled(true);
  }

  Future<void> enableMicrophone() async {
    await _room?.localParticipant?.setMicrophoneEnabled(true);
  }

  Future<void> startCall({
    required String roomName,
    required String callerName,
    bool isVideo = true,
  }) async {
    await connectRoom(
      roomName: roomName,
      participantName: callerName,
    );
    if (isVideo) {
      await enableCamera();
    }
    await enableMicrophone();
  }

  Future<void> endCall() async {
    await _room?.disconnect();
    _room = null;
  }

  void dispose() {
    _room?.disconnect();
    _room = null;
  }
}
