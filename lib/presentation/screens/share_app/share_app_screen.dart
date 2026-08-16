import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  final List<Map<String, dynamic>> _socialPlatforms = const [
    {'icon': Icons.chat, 'name': 'واتساب', 'color': Color(0xFF25D366)},
    {'icon': Icons.facebook, 'name': 'فيسبوك', 'color': Color(0xFF1877F2)},
    {'icon': Icons.photo_camera, 'name': 'انستغرام', 'color': Color(0xFFE4405F)},
    {'icon': Icons.timeline, 'name': 'تويتر', 'color': Color(0xFF1DA1F2)},
    {'icon': Icons.people, 'name': 'لينكد إن', 'color': Color(0xFF0A66C2)},
    {'icon': Icons.games, 'name': 'ديسكورد', 'color': Color(0xFF5865F2)},
  ];

  void _shareApp() {
    Share.share(
      '🌟 تطبيق صحتك - منصة الرعاية الصحية الشاملة\n'
      '📱 حمل التطبيق الآن واستفد من الخدمات الصحية المتكاملة\n'
      '🔗 https://sehatak.com/download',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('مشاركة التطبيق'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'شارك التطبيق مع أصدقائك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ادعم صحتك وصحة من حولك',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _shareApp,
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('مشاركة الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'شارك عبر منصات التواصل الاجتماعي',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _socialPlatforms.length,
              itemBuilder: (context, index) {
                final platform = _socialPlatforms[index];
                return GestureDetector(
                  onTap: _shareApp,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (platform['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            platform['icon'] as IconData,
                            color: platform['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          platform['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
