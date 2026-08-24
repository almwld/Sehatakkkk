import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config/livekit_config.dart';
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

  Room? get room => _room;
  bool get isConnected => _isConnected;

  // ✅ إنشاء توكن JWT
  String _generateToken({
    required String roomName,
    required String participantName,
  }) {
    try {
      final jwt = JWT({
        'iss': LiveKitConfig.apiKey,
        'sub': participantName,
        'name': participantName,
        'video': {
          'room': roomName,
          'roomJoin': true,
          'canPublish': true,
          'canSubscribe': true,
        },
        'exp': DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch ~/ 1000,
        'nbf': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      return jwt.sign(SecretKey(LiveKitConfig.apiSecret));
    } catch (e) {
      print('❌ Token generation error: $e');
      ToastService.showError('❌ فشل إنشاء رمز المكالمة');
      rethrow;
    }
  }

  // ✅ الاتصال بالغرفة
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

      final options = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultVideoPublishOptions: const VideoPublishOptions(
          simulcast: false,
        ),
        defaultAudioPublishOptions: const AudioPublishOptions(
          bitrate: 32000,
        ),
      );

      await _room!.connect(
        LiveKitConfig.serverUrl,
        token,
        roomOptions: options,
      );

      _isConnected = true;
      print('✅ Connected to room: $roomName');
      
      // ✅ تمكين الميكروفون تلقائياً
      await _room!.localParticipant?.setMicrophoneEnabled(true);
      _isMicrophoneEnabled = true;

      return _room!;
    } catch (e) {
      print('❌ Connection failed: $e');
      _isConnected = false;
      ToastService.showError('❌ فشل الاتصال: $e');
      rethrow;
    }
  }

  // ✅ تمكين الكاميرا
  Future<void> enableCamera() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setCameraEnabled(true);
        _isCameraEnabled = true;
        print('✅ Camera enabled');
      }
    } catch (e) {
      print('❌ Camera error: $e');
      ToastService.showError('❌ فشل تشغيل الكاميرا: $e');
    }
  }

  // ✅ تمكين الميكروفون
  Future<void> enableMicrophone() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setMicrophoneEnabled(true);
        _isMicrophoneEnabled = true;
        print('✅ Microphone enabled');
      }
    } catch (e) {
      print('❌ Microphone error: $e');
      ToastService.showError('❌ فشل تشغيل الميكروفون: $e');
    }
  }

  // ✅ بدء المكالمة
  Future<void> startCall({
    required String roomName,
    required String callerName,
    bool isVideo = true,
  }) async {
    try {
      print('📞 Starting call...');
      
      // ✅ الاتصال بالغرفة
      await connectRoom(roomName: roomName, participantName: callerName);
      
      // ✅ تمكين الميكروفون
      await enableMicrophone();
      
      // ✅ تمكين الكاميرا إذا كانت مكالمة فيديو
      if (isVideo) {
        await enableCamera();
      }
      
      print('✅ Call started successfully');
      ToastService.showSuccess('📞 بدأت المكالمة بنجاح');
    } catch (e) {
      print('❌ Call start failed: $e');
      ToastService.showError('❌ فشل بدء المكالمة: $e');
      rethrow;
    }
  }

  // ✅ تبديل الكاميرا
  Future<bool> toggleCamera() async {
    try {
      if (_isCameraEnabled) {
        await _room?.localParticipant?.setCameraEnabled(false);
        _isCameraEnabled = false;
        ToastService.showInfo('📷 تم إيقاف الكاميرا');
        return false;
      } else {
        await _room?.localParticipant?.setCameraEnabled(true);
        _isCameraEnabled = true;
        ToastService.showInfo('📷 تم تشغيل الكاميرا');
        return true;
      }
    } catch (e) {
      print('❌ Camera toggle error: $e');
      ToastService.showError('❌ فشل تبديل الكاميرا');
      return _isCameraEnabled;
    }
  }

  // ✅ تبديل الميكروفون
  Future<bool> toggleMicrophone() async {
    try {
      if (_isMicrophoneEnabled) {
        await _room?.localParticipant?.setMicrophoneEnabled(false);
        _isMicrophoneEnabled = false;
        ToastService.showInfo('🎤 تم كتم الصوت');
        return false;
      } else {
        await _room?.localParticipant?.setMicrophoneEnabled(true);
        _isMicrophoneEnabled = true;
        ToastService.showInfo('🎤 تم إلغاء كتم الصوت');
        return true;
      }
    } catch (e) {
      print('❌ Microphone toggle error: $e');
      ToastService.showError('❌ فشل تبديل الميكروفون');
      return _isMicrophoneEnabled;
    }
  }

  // ✅ تفعيل مكبر الصوت
  void setSpeakerphone(bool on) {
    try {
      _isSpeakerOn = on;
      print('🔊 Speakerphone: $on');
      ToastService.showInfo(on ? '🔊 تم تفعيل مكبر الصوت' : '🔇 تم إلغاء مكبر الصوت');
    } catch (e) {
      print('❌ Speaker error: $e');
      ToastService.showError('❌ فشل تفعيل مكبر الصوت');
    }
  }

  bool get isSpeakerOn => _isSpeakerOn;

  // ✅ الحصول على حالة الكاميرا
  bool get isCameraEnabled => _isCameraEnabled;

  // ✅ الحصول على حالة الميكروفون
  bool get isMicrophoneEnabled => _isMicrophoneEnabled;

  // ✅ إنهاء المكالمة
  Future<void> endCall() async {
    try {
      await _room?.disconnect();
      _room = null;
      _isConnected = false;
      _isCameraEnabled = false;
      _isMicrophoneEnabled = false;
      _isSpeakerOn = false;
      print('✅ Call ended');
    } catch (e) {
      print('❌ End call error: $e');
    }
  }

  // ✅ تنظيف الموارد
  void dispose() {
    _room?.disconnect();
    _room = null;
    _isConnected = false;
  }
}
