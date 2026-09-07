// إعدادات LiveKit العامة لتطبيق صحتك.
// مفتاح LiveKit السري لا يدخل التطبيق أبداً؛ يتم إصدار التوكن عبر خادم صغير مستقل.
class LiveKitConfig {
  static const String serverUrl = 'wss://platformsehatak-z73p6n5m.livekit.cloud';

  // خادم إصدار التوكن الإنتاجي المستضاف على Railway.
  // يمكن استبداله في بيئات التطوير عبر --dart-define=LIVEKIT_TOKEN_SERVER_URL=...
  static const String tokenServerUrl = String.fromEnvironment(
    'LIVEKIT_TOKEN_SERVER_URL',
    defaultValue: 'https://miraculous-compassion-production-1d54.up.railway.app',
  );

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

  static bool get isValid =>
      serverUrl.startsWith('wss://') && tokenServerUrl.startsWith('https://');
}
