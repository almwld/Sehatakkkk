import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';

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
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraEnabled => _isCameraEnabled;
  bool get isMicrophoneEnabled => _isMicrophoneEnabled;

  /// جلب Firebase ID Token لإرساله إلى Backend.
  Future<String?> _getFirebaseIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      return await user.getIdToken();
    } catch (e) {
      print('⚠️ Firebase ID Token error: $e');
      return null;
    }
  }

  /// طلب LiveKit Access Token من Backend.
  ///
  /// مهم:
  /// لا يتم إنشاء JWT داخل تطبيق Flutter.
  /// الـAPI Secret يبقى داخل Backend فقط.
  Future<Map<String, dynamic>> _requestLiveKitToken({
    required String roomName,
    required String participantIdentity,
    required String participantName,
  }) async {
    final uri = Uri.parse(
      '${LiveKitConfig.apiBaseUrl}/api/livekit/token',
    );

    final firebaseToken = await _getFirebaseIdToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (firebaseToken != null && firebaseToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $firebaseToken';
    }

    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode({
            'roomName': roomName,
            'participantIdentity': participantIdentity,
            'participantName': participantName,
          }),
        )
        .timeout(const Duration(seconds: 20));

    print('📞 LiveKit token response: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ LiveKit token request failed: ${response.body}');

      throw Exception(
        'فشل الحصول على توكن LiveKit (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('استجابة LiveKit غير صالحة');
    }

    if (decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'فشل إنشاء توكن LiveKit',
      );
    }

    final data = decoded['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('بيانات توكن LiveKit غير صالحة');
    }

    final token = data['token']?.toString();
    final url = data['url']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception('توكن LiveKit فارغ');
    }

    if (url == null || url.isEmpty) {
      throw Exception('رابط LiveKit فارغ');
    }

    return {
      'token': token,
      'url': url,
      'roomName': data['roomName']?.toString() ?? roomName,
      'participantIdentity':
          data['participantIdentity']?.toString() ?? participantIdentity,
      'participantName':
          data['participantName']?.toString() ?? participantName,
    };
  }

  /// الاتصال بغرفة LiveKit.
  Future<Room> connectRoom({
    required String roomName,
    String? participantName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('يجب تسجيل الدخول قبل إجراء المكالمة');
      }

      final identity = user.uid;
      final name = participantName?.trim().isNotEmpty == true
          ? participantName!.trim()
          : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : 'مستخدم');

      print('📞 Requesting LiveKit token...');
      print('🏠 Room: $roomName');
      print('👤 Participant: $identity');

      final tokenData = await _requestLiveKitToken(
        roomName: roomName,
        participantIdentity: identity,
        participantName: name,
      );

      final token = tokenData['token'] as String;
      final serverUrl = tokenData['url'] as String;

      await _room?.disconnect();

      _room = Room();

      final options = RoomOptions(
        adaptiveStream: true,
        dynacast: true,
        defaultVideoPublishOptions: const VideoPublishOptions(
          simulcast: false,
        ),
        defaultAudioPublishOptions: const AudioPublishOptions(),
      );

      print('🔌 Connecting to LiveKit...');

      await _room!.connect(
        serverUrl,
        token,
        roomOptions: options,
      );

      _isConnected = true;

      print('✅ Connected to LiveKit room: $roomName');

      await enableMicrophone();

      return _room!;
    } catch (e) {
      print('❌ LiveKit connection failed: $e');

      _isConnected = false;

      ToastService.showError(
        '❌ فشل الاتصال بالمكالمة',
      );

      rethrow;
    }
  }

  /// تشغيل الكاميرا.
  Future<void> enableCamera() async {
    try {
      final participant = _room?.localParticipant;

      if (participant == null) {
        throw Exception('لا يوجد اتصال LiveKit');
      }

      await participant.setCameraEnabled(true);

      _isCameraEnabled = true;

      print('✅ Camera enabled');
    } catch (e) {
      print('❌ Camera error: $e');

      ToastService.showError(
        '❌ فشل تشغيل الكاميرا',
      );
    }
  }

  /// تشغيل الميكروفون.
  Future<void> enableMicrophone() async {
    try {
      final participant = _room?.localParticipant;

      if (participant == null) {
        throw Exception('لا يوجد اتصال LiveKit');
      }

      await participant.setMicrophoneEnabled(true);

      _isMicrophoneEnabled = true;

      print('✅ Microphone enabled');
    } catch (e) {
      print('❌ Microphone error: $e');

      ToastService.showError(
        '❌ فشل تشغيل الميكروفون',
      );
    }
  }

  /// بدء مكالمة صوتية أو فيديو.
  Future<void> startCall({
    required String roomName,
    required String callerName,
    bool isVideo = true,
  }) async {
    try {
      print('📞 Starting call...');
      print('🏠 Room: $roomName');
      print('👤 Caller: $callerName');
      print('🎥 Video: $isVideo');

      await connectRoom(
        roomName: roomName,
        participantName: callerName,
      );

      await enableMicrophone();

      if (isVideo) {
        await enableCamera();
      }

      print('✅ Call started successfully');

      ToastService.showSuccess(
        '📞 بدأت المكالمة بنجاح',
      );
    } catch (e) {
      print('❌ Call start failed: $e');

      ToastService.showError(
        '❌ فشل بدء المكالمة',
      );

      rethrow;
    }
  }

  /// تبديل الكاميرا.
  Future<bool> toggleCamera() async {
    try {
      final participant = _room?.localParticipant;

      if (participant == null) {
        return _isCameraEnabled;
      }

      final newState = !_isCameraEnabled;

      await participant.setCameraEnabled(newState);

      _isCameraEnabled = newState;

      ToastService.showInfo(
        newState
            ? '📷 تم تشغيل الكاميرا'
            : '📷 تم إيقاف الكاميرا',
      );

      return newState;
    } catch (e) {
      print('❌ Camera toggle error: $e');

      ToastService.showError(
        '❌ فشل تبديل الكاميرا',
      );

      return _isCameraEnabled;
    }
  }

  /// تبديل الميكروفون.
  Future<bool> toggleMicrophone() async {
    try {
      final participant = _room?.localParticipant;

      if (participant == null) {
        return _isMicrophoneEnabled;
      }

      final newState = !_isMicrophoneEnabled;

      await participant.setMicrophoneEnabled(newState);

      _isMicrophoneEnabled = newState;

      ToastService.showInfo(
        newState
            ? '🎤 تم إلغاء كتم الصوت'
            : '🎤 تم كتم الصوت',
      );

      return newState;
    } catch (e) {
      print('❌ Microphone toggle error: $e');

      ToastService.showError(
        '❌ فشل تبديل الميكروفون',
      );

      return _isMicrophoneEnabled;
    }
  }

  /// تفعيل/إلغاء مكبر الصوت.
  void setSpeakerphone(bool on) {
    try {
      _isSpeakerOn = on;

      print('🔊 Speakerphone: $on');

      ToastService.showInfo(
        on
            ? '🔊 تم تفعيل مكبر الصوت'
            : '🔇 تم إلغاء مكبر الصوت',
      );
    } catch (e) {
      print('❌ Speaker error: $e');

      ToastService.showError(
        '❌ فشل تفعيل مكبر الصوت',
      );
    }
  }

  /// إنهاء المكالمة.
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

      _room = null;
      _isConnected = false;
      _isCameraEnabled = false;
      _isMicrophoneEnabled = false;
      _isSpeakerOn = false;
    }
  }

  /// تنظيف الموارد.
  void dispose() {
    _room?.disconnect();

    _room = null;

    _isConnected = false;
    _isCameraEnabled = false;
    _isMicrophoneEnabled = false;
    _isSpeakerOn = false;
  }
}
