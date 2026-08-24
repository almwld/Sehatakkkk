// ============================================================
// 📁 lib/core/config/livekit_config.dart
// 🔧 إعدادات LiveKit للمكالمات الصوتية والفيديو
// ============================================================

class LiveKitConfig {
  // ✅ عنوان خادم LiveKit
  // استخدم عنوان الخادم الخاص بك أو الخادم التجريبي
  static const String serverUrl = 'wss://platformsehatak-z73p6n5m.livekit.cloud';
  
  // ✅ مفتاح API (استخدم مفاتيحك الخاصة)
  static const String apiKey = 'API_4UJpBWExd72';
  
  // ✅ سر API (استخدم مفتاحك الخاص)
  static const String apiSecret = 'your-api-secret-here';
  
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
  
  // ✅ إعدادات جودة البث (متعددة)
  static const List<VideoQuality> videoQualities = [
    VideoQuality(
      width: 1280,
      height: 720,
      bitrate: 1500000, // 1.5 Mbps
      fps: 30,
    ),
    VideoQuality(
      width: 640,
      height: 480,
      bitrate: 800000, // 800 kbps
      fps: 30,
    ),
    VideoQuality(
      width: 320,
      height: 240,
      bitrate: 300000, // 300 kbps
      fps: 15,
    ),
  ];
  
  // ✅ التحقق من صحة الإعدادات
  static bool get isValid {
    return apiKey.isNotEmpty && 
           apiSecret.isNotEmpty && 
           serverUrl.isNotEmpty;
  }
  
  // ✅ الحصول على عنوان الخادم مع البروتوكول
  static String get fullServerUrl {
    if (serverUrl.startsWith('wss://') || serverUrl.startsWith('ws://')) {
      return serverUrl;
    }
    return 'wss://$serverUrl';
  }
}

// ============================================================
// 📦 نموذج جودة الفيديو
// ============================================================

class VideoQuality {
  final int width;
  final int height;
  final int bitrate;
  final int fps;
  
  const VideoQuality({
    required this.width,
    required this.height,
    required this.bitrate,
    required this.fps,
  });
  
  // ✅ نسبة العرض إلى الارتفاع
  double get aspectRatio => width / height;
  
  // ✅ دقة الفيديو بالبكسل
  int get resolution => width * height;
  
  // ✅ هل الجودة عالية الدقة؟
  bool get isHD => width >= 1280 && height >= 720;
  
  // ✅ هل الجودة منخفضة الدقة؟
  bool get isSD => width < 640 || height < 480;
}
