import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../config/livekit_config.dart';
import 'package:livekit_client/sandbox_token_source.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;

  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  // 🔑 توليد Token باستخدام API Key و Secret
  Future<String> _generateToken({
    required String roomName,
    required String participantName,
    String? participantIdentity,
  }) async {
    // ✅ استخدام Sandbox Token Source (للاختبار)
    final tokenSource = SandboxTokenSource(
      sandboxId: LiveKitConfig.sandboxId,
      roomName: roomName,
      participantName: participantName,
      participantIdentity: participantIdentity ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
    );
    return await tokenSource.getToken();
  }

  Future<Room> connectRoom({
    required String roomName,
    String? participantName,
  }) async {
    _room = Room();

    final token = await _generateToken(
      roomName: roomName,
      participantName: participantName ?? 'مستخدم',
    );

    final options = RoomOptions(
      defaultVideoPublishOptions: VideoPublishOptions(
        simulcast: false,
      ),
      defaultAudioPublishOptions: const AudioPublishOptions(),
    );

    await _room!.connect(
      LiveKitConfig.serverUrl,
      token,
      roomOptions: options,
    );

    // ✅ تشغيل الصوت
    await _room?.localParticipant?.setMicrophoneEnabled(true);

    return _room!;
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
