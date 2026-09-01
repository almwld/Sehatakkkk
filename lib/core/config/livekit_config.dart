// ============================================================
// 📁 lib/core/config/livekit_config.dart
// 🔧 إعدادات LiveKit للعميل
//
// ⚠️ لا تضع LIVEKIT_API_KEY أو LIVEKIT_API_SECRET هنا.
// الأسرار يجب أن تبقى داخل Backend فقط.
// ============================================================

class LiveKitConfig {
  /// عنوان خادم LiveKit العام.
  /// هذا ليس Secret ويمكن استخدامه من تطبيق Flutter.
  static const String serverUrl =
      'wss://platformsehatak-z73p6n5m.livekit.cloud';

  /// عنوان Backend API.
  ///
  /// يمكن تغييره أثناء Build باستخدام:
  /// --dart-define=API_BASE_URL=https://your-api-domain.com
  ///
  /// Android Emulator:
  /// 10.0.2.2 يشير إلى جهاز التطوير.
  ///
  /// الجهاز الحقيقي:
  /// استخدم عنوان Backend القابل للوصول من الجهاز.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // ============================================================
  // 🎥 إعدادات جودة الفيديو
  // ============================================================

  static const int videoBitrate = 1000000; // 1 Mbps
  static const int videoFps = 30;
  static const int videoWidth = 640;
  static const int videoHeight = 480;

  // ============================================================
  // 🎤 إعدادات جودة الصوت
  // ============================================================

  static const int audioBitrate = 32000; // 32 kbps
  static const int audioSampleRate = 44100;

  // ============================================================
  // 🏠 إعدادات الغرفة
  // ============================================================

  static const int roomTimeout = 300;
  static const int maxParticipants = 10;

  // ============================================================
  // 🔌 إعدادات الاتصال
  // ============================================================

  static const int connectionTimeout = 30;
  static const int reconnectAttempts = 3;

  // ============================================================
  // ✅ التحقق من الإعدادات
  // ============================================================

  static bool get isValid {
    return serverUrl.isNotEmpty && apiBaseUrl.isNotEmpty;
  }
}
