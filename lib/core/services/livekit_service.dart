import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  bool get isConnected => _room?.state == RoomState.connected;

  // 🔗 الاتصال بالغرفة
  Future<Room> connectRoom({
    required String roomName,
    required String token,
    String? participantName,
  }) async {
    _room = Room();
    
    // إعدادات الصوت والفيديو
    final options = RoomOptions(
      defaultVideoPublishOptions: VideoPublishOptions(
        simulcast: false,
        videoCodec: VideoCodec.vp8,
      ),
      defaultAudioPublishOptions: AudioPublishOptions(
        bitrate: AudioBitrate.bitrate32,
      ),
    );

    await _room!.connect(
      url: 'wss://your-livekit-server.com',
      token: token,
      roomOptions: options,
    );

    // إعدادات الصوت
    await _room!.localParticipant?.setMicrophoneEnabled(true);
    
    return _room!;
  }

  // 🎥 تشغيل الكاميرا
  Future<void> enableCamera() async {
    await _room?.localParticipant?.setCameraEnabled(true);
  }

  // 🎤 تشغيل الميكروفون
  Future<void> enableMicrophone() async {
    await _room?.localParticipant?.setMicrophoneEnabled(true);
  }

  // 📹 مشاركة الشاشة
  Future<void> shareScreen() async {
    await _room?.localParticipant?.setScreenShareEnabled(true);
  }

  // 📞 بدء مكالمة
  Future<void> startCall({
    required String roomName,
    required String token,
    required String callerName,
    bool isVideo = true,
  }) async {
    await connectRoom(
      roomName: roomName,
      token: token,
      participantName: callerName,
    );
    if (isVideo) {
      await enableCamera();
    }
    await enableMicrophone();
  }

  // 📞 إنهاء المكالمة
  Future<void> endCall() async {
    await _room?.disconnect();
    _room = null;
  }

  // 🗑️ التخلص من الموارد
  void dispose() {
    _room?.disconnect();
    _room = null;
  }
}
