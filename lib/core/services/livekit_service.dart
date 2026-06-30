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

  Room? get room => _room;
  bool get isConnected => _room?.connectionState == ConnectionState.connected;

  String _generateToken({
    required String roomName,
    required String participantName,
  }) {
    try {
      final jwt = JWT(
        {
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
        },
      );
      return jwt.sign(SecretKey(LiveKitConfig.apiSecret));
    } catch (e) {
      print('❌ Token generation error: $e');
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
      
      await _room!.localParticipant?.setMicrophoneEnabled(true);
      
      return _room!;
    } catch (e) {
      print('❌ Connection failed: $e');
      rethrow;
    }
  }

  // ✅ الدالة المحدثة - خالية من الأخطاء
  Future<void> enableCamera() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setCameraEnabled(true);
        _isCameraEnabled = true;
        print('✅ Camera enabled');
        
        // ✅ الطريقة الصحيحة للوصول إلى Tracks في الإصدار 1.5.6
        final tracks = _room!.localParticipant!.videoTracks;
        if (tracks.isNotEmpty) {
          final publication = tracks.first;
          final track = publication.track;
          if (track != null && track is VideoTrack) {
            // ✅ استخدام .sid بدلاً من .id
            print('✅ VideoTrack available: ${track.sid}');
          }
        }
      }
    } catch (e) {
      print('❌ Camera error: $e');
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await _room!.localParticipant!.setCameraEnabled(true);
        _isCameraEnabled = true;
      } catch (_) {}
    }
  }

  Future<void> enableMicrophone() async {
    try {
      if (_room?.localParticipant != null) {
        await _room!.localParticipant!.setMicrophoneEnabled(true);
        _isMicrophoneEnabled = true;
        print('✅ Microphone enabled');
      }
    } catch (e) {
      print('❌ Microphone error: $e');
    }
  }

  Future<void> startCall({
    required String roomName,
    required String callerName,
    bool isVideo = true,
  }) async {
    try {
      await connectRoom(roomName: roomName, participantName: callerName);
      await enableMicrophone();
      if (isVideo) {
        await enableCamera();
      }
      print('✅ Call started successfully');
    } catch (e) {
      print('❌ Call start failed: $e');
      rethrow;
    }
  }

  Future<bool> toggleCamera() async {
    if (_isCameraEnabled) {
      await _room?.localParticipant?.setCameraEnabled(false);
      _isCameraEnabled = false;
      return false;
    } else {
      await _room?.localParticipant?.setCameraEnabled(true);
      _isCameraEnabled = true;
      return true;
    }
  }

  Future<void> endCall() async {
    await _room?.disconnect();
    _room = null;
    _isCameraEnabled = false;
    _isMicrophoneEnabled = false;
    print('✅ Call ended');
  }

  void dispose() {
    _room?.disconnect();
    _room = null;
  }
}
