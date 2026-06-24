import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  Room? _room;
  
  // ✅ استخدام ConnectionState بدلاً من RoomState
  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  // 🔗 الاتصال بالغرفة (API الجديد)
  Future<Room> connectRoom({
    required String url,
    required String token,
    String? participantName,
  }) async {
    _room = Room();

    // ✅ إعدادات الصوت والفيديو (API الجديد)
    final options = RoomOptions(
      defaultVideoPublishOptions: VideoPublishOptions(
        simulcast: false,
        // ✅ تم إزالة VideoCodec.vp8 (يستخدم VP8 افتراضياً)
      ),
      defaultAudioPublishOptions: const AudioPublishOptions(),
    );

    // ✅ connect() يتطلب url و token فقط
    await _room!.connect(
      url,
      token,
      roomOptions: options,
    );

    // ✅ تشغيل الصوت
    await _room?.localParticipant?.setMicrophoneEnabled(true);
    
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

  // 📞 بدء مكالمة (API مبسط)
  Future<void> startCall({
    required String url,
    required String token,
    required String callerName,
    bool isVideo = true,
  }) async {
    await connectRoom(
      url: url,
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
