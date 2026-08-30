// ============================================================
// 🖼️ شاشة اختيار خلفية الدردشة
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/chat_wallpapers.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatWallpaperScreen extends StatefulWidget {
  const ChatWallpaperScreen({super.key});

  @override
  State<ChatWallpaperScreen> createState() => _ChatWallpaperScreenState();
}

class _ChatWallpaperScreenState extends State<ChatWallpaperScreen> {
  String _selectedWallpaper = 'default_light';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedWallpaper();
  }

  Future<void> _loadSelectedWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_wallpaper') ?? 'default_light';
      setState(() {
        _selectedWallpaper = saved;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveWallpaper(String id) async {
    try {
      await ChatWallpapers.saveSelectedWallpaper(id);
      setState(() => _selectedWallpaper = id);
      ToastService.showSuccess('✅ تم تغيير الخلفية بنجاح');
    } catch (e) {
      ToastService.showError('❌ فشل تغيير الخلفية: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('خلفية الدردشة'),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: ChatWallpapers.wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = ChatWallpapers.wallpapers[index];
                final isSelected = _selectedWallpaper == wallpaper.id;

                return GestureDetector(
                  onTap: () => _saveWallpaper(wallpaper.id),
                  child: Stack(
                    children: [
                      // ✅ معاينة الخلفية
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(wallpaper.assetPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ✅ اسم الخلفية
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          wallpaper.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // ✅ علامة التحديد
                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      // ✅ زر المعاينة
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'معاينة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
