import 'package:shared_preferences/shared_preferences.dart';

class ChatWallpapers {
  static const List<Wallpaper> wallpapers = [
    Wallpaper(id: 'default_light', name: 'افتراضي فاتح', assetPath: 'assets/images/sehatak_chat_wallpaper_light_1080x2160.png', isDark: false, type: 'image'),
    Wallpaper(id: 'default_dark', name: 'افتراضي داكن', assetPath: 'assets/images/sehatak_chat_wallpaper_dark_1080x2160.png', isDark: true, type: 'image'),
    Wallpaper(id: 'auto', name: 'تلقائي', assetPath: 'assets/images/sehatak_chat_wallpaper_auto.svg', isDark: false, type: 'svg'),
    Wallpaper(id: 'light_svg', name: 'فاتح SVG', assetPath: 'assets/images/sehatak_chat_wallpaper_light.svg', isDark: false, type: 'svg'),
    Wallpaper(id: 'dark_svg', name: 'داكن SVG', assetPath: 'assets/images/sehatak_chat_wallpaper_dark.svg', isDark: true, type: 'svg'),
  ];

  static Wallpaper? getWallpaper(String id) => wallpapers.where((w) => w.id == id).firstOrNull;
  static Wallpaper getWallpaperForTheme(bool isDark) => wallpapers.firstWhere((w) => w.isDark == isDark, orElse: () => wallpapers.first);
  static Future<void> saveSelectedWallpaper(String id) async => (await SharedPreferences.getInstance()).setString('selected_wallpaper', id);
  static Future<String> loadSelectedWallpaper() async => (await SharedPreferences.getInstance()).getString('selected_wallpaper') ?? 'default_light';
}

class Wallpaper {
  final String id, name, assetPath, type;
  final bool isDark;
  const Wallpaper({required this.id, required this.name, required this.assetPath, required this.isDark, required this.type});
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
