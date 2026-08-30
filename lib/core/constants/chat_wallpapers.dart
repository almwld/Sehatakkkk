// ============================================================
// 🖼️ خلفيات الدردشة
// ============================================================

class ChatWallpapers {
  // ✅ قائمة الخلفيات المتاحة
  static const List<Wallpaper> wallpapers = [
    Wallpaper(
      id: 'default_light',
      name: 'افتراضي فاتح',
      assetPath: 'assets/images/sehatak_chat_wallpaper_light_1080x2160.png',
      isDark: false,
      type: 'image',
    ),
    Wallpaper(
      id: 'default_dark',
      name: 'افتراضي داكن',
      assetPath: 'assets/images/sehatak_chat_wallpaper_dark_1080x2160.png',
      isDark: true,
      type: 'image',
    ),
    Wallpaper(
      id: 'auto',
      name: 'تلقائي',
      assetPath: 'assets/images/sehatak_chat_wallpaper_auto.svg',
      isDark: false,
      type: 'svg',
    ),
    Wallpaper(
      id: 'light_svg',
      name: 'فاتح SVG',
      assetPath: 'assets/images/sehatak_chat_wallpaper_light.svg',
      isDark: false,
      type: 'svg',
    ),
    Wallpaper(
      id: 'dark_svg',
      name: 'داكن SVG',
      assetPath: 'assets/images/sehatak_chat_wallpaper_dark.svg',
      isDark: true,
      type: 'svg',
    ),
    // ✅ خلفيات إضافية يمكن إضافتها
    Wallpaper(
      id: 'nature',
      name: 'طبيعة',
      assetPath: 'assets/images/chat/backgrounds/nature.jpg',
      isDark: false,
      type: 'image',
    ),
    Wallpaper(
      id: 'ocean',
      name: 'بحر',
      assetPath: 'assets/images/chat/backgrounds/ocean.jpg',
      isDark: false,
      type: 'image',
    ),
    Wallpaper(
      id: 'mountains',
      name: 'جبال',
      assetPath: 'assets/images/chat/backgrounds/mountains.jpg',
      isDark: false,
      type: 'image',
    ),
    Wallpaper(
      id: 'abstract',
      name: 'تجريدي',
      assetPath: 'assets/images/chat/backgrounds/abstract.jpg',
      isDark: false,
      type: 'image',
    ),
  ];

  // ✅ الحصول على الخلفية حسب المعرف
  static Wallpaper? getWallpaper(String id) {
    try {
      return wallpapers.firstWhere((w) => w.id == id);
    } catch (e) {
      return wallpapers.first;
    }
  }

  // ✅ الحصول على الخلفية المناسبة حسب الوضع
  static Wallpaper getWallpaperForTheme(bool isDark) {
    return wallpapers.firstWhere(
      (w) => w.isDark == isDark || w.id == 'auto',
      orElse: () => wallpapers.first,
    );
  }

  // ✅ حفظ الخلفية المختارة
  static Future<void> saveSelectedWallpaper(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_wallpaper', id);
  }

  // ✅ تحميل الخلفية المختارة
  static Future<String> loadSelectedWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_wallpaper') ?? 'default_light';
  }
}

// ✅ نموذج الخلفية
class Wallpaper {
  final String id;
  final String name;
  final String assetPath;
  final bool isDark;
  final String type; // 'image' or 'svg'

  const Wallpaper({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.isDark,
    required this.type,
  });
}
