// إعدادات LiveKit العامة لتطبيق صحتك.
// مفاتيح LiveKit السرية لا تدخل التطبيق أبداً؛ إصدار التوكن يتم عبر Firebase Functions.
class LiveKitConfig {
  static const String serverUrl = 'wss://platformsehatak-z73p6n5m.livekit.cloud';

  static const int videoBitrate = 1000000;
  static const int videoFps = 30;
  static const int videoWidth = 640;
  static const int videoHeight = 480;
  static const int audioBitrate = 32000;
  static const int audioSampleRate = 44100;
  static const int roomTimeout = 300;
  static const int maxParticipants = 10;
  static const int connectionTimeout = 30;
  static const int reconnectAttempts = 3;

  static bool get isValid => serverUrl.startsWith('wss://');
}
