// ============================================================
// 📁 lib/core/config/livekit_config.dart
// 🔧 إعدادات LiveKit للمكالمات الصوتية والفيديو
// ============================================================

class LiveKitConfig {
  // ✅ عنوان خادم LiveKit
  static const String serverUrl = 'wss://platformsehatak-z73p6n5m.livekit.cloud';
  
  // ✅ مفتاح API
  static const String apiKey = 'APIFJ6EUBRkJgJF';
  
  // ✅ سر API
  static const String apiSecret = 'CS8wQ0bRiZLOrtfb0SpflcNbtVNcUp7mWeTWuAhA8OfD';
  
  // ✅ إعدادات جودة الفيديو
  static const int videoBitrate = 1000000; // 1 Mbps
  static const int videoFps = 30;
  static const int videoWidth = 640;
  static const int videoHeight = 480;
  
  // ✅ إعدادات جودة الصوت
  static const int audioBitrate = 32000; // 32 kbps
  static const int audioSampleRate = 44100;
  
  // ✅ إعدادات الغرفة
  static const int roomTimeout = 300; // 5 دقائق
  static const int maxParticipants = 10;
  
  // ✅ إعدادات الاتصال
  static const int connectionTimeout = 30; // 30 ثانية
  static const int reconnectAttempts = 3;
  
  // ✅ التحقق من صحة الإعدادات
  static bool get isValid {
    return apiKey.isNotEmpty && 
           apiSecret.isNotEmpty && 
           serverUrl.isNotEmpty;
  }
}
