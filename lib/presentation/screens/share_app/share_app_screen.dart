import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_icons.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  final List<Map<String, dynamic>> _socialPlatforms = const [
    {'icon': AppIcons.socialWhatsapp, 'name': 'واتساب'},
    {'icon': AppIcons.socialFacebook, 'name': 'فيسبوك'},
    {'icon': AppIcons.socialInstagram, 'name': 'انستغرام'},
    {'icon': AppIcons.socialXTwitter, 'name': 'تويتر'},
    {'icon': AppIcons.socialLinkedin, 'name': 'لينكد إن'},
    {'icon': AppIcons.socialDiscord, 'name': 'ديسكورد'},
  ];

  void _shareApp() {
    Share.share('🌟 تطبيق صحتك - منصة الرعاية الصحية الشاملة\n📱 حمل التطبيق الآن واستفد من الخدمات الصحية المتكاملة\n🔗 https://sehatak.com/download');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('مشاركة التطبيق'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              LocalAssetIcon(AppImages.uiShareApp, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              const Text('شارك التطبيق مع أصدقائك', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('ادعم صحتك وصحة من حولك', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _shareApp,
                icon: LocalAssetIcon(AppImages.uiShareApp, color: AppColors.primary, size: 20),
                label: const Text('مشاركة الآن'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('شارك عبر منصات التواصل الاجتماعي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.0),
            itemCount: _socialPlatforms.length,
            itemBuilder: (context, index) {
              final platform = _socialPlatforms[index];
              return GestureDetector(
                onTap: _shareApp,
                child: Container(
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: LocalAssetIcon(platform['icon'] as String, size: 28))),
                    const SizedBox(height: 6),
                    Text(platform['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}
