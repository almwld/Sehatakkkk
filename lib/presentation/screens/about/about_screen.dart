import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_icons.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/core/constants/app_assets.dart';
import 'package:sehatak/presentation/widgets/common/local_asset_icon.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '1.1.0';
  String _buildNumber = '2';
  @override void initState() { super.initState(); _loadAppInfo(); }
  Future<void> _loadAppInfo() async { try { final packageInfo = await PackageInfo.fromPlatform(); setState(() { _appVersion = packageInfo.version; _buildNumber = packageInfo.buildNumber; }); } catch (e) { print('⚠️ Error loading package info: $e'); } }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(title: const Text('عن التطبيق', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(height: 20),
          Container(width: 120, height: 120, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]), child: Padding(padding: const EdgeInsets.all(20), child: Image.asset('android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png', width: 60, height: 60, fit: BoxFit.contain))),
          const SizedBox(height: 20),
          const Text('صحتك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4), Text('Sehatak', style: TextStyle(fontSize: 16, color: AppColors.grey, letterSpacing: 2)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text('الإصدار $_appVersion+$_buildNumber', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600))),
          const SizedBox(height: 30),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]), child: Column(children: [const Text('منصة الرعاية الصحية الشاملة في اليمن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 12), Text('تطبيق "صحتك" هو منصة طبية متكاملة تهدف إلى تسهيل الوصول إلى الخدمات الصحية في اليمن. نوفر لك إمكانية حجز المواعيد، والاستشارات الطبية، وطلب الأدوية، ومتابعة حالتك الصحية بكل سهولة وأمان.', style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6), textAlign: TextAlign.center)])),
          const SizedBox(height: 24), _buildFeatureSection(isDark), const SizedBox(height: 24), _buildSocialLinks(isDark), const SizedBox(height: 30),
          Text('© 2026 Sehatak Platform', style: TextStyle(fontSize: 12, color: AppColors.grey)), const SizedBox(height: 4), Text('جميع الحقوق محفوظة', style: TextStyle(fontSize: 11, color: AppColors.grey.withOpacity(0.7))), const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _buildFeatureSection(bool isDark) {
    final features = [
      {'icon': AppIcons.doctor, 'title': 'أطباء', 'desc': 'استشر أفضل الأطباء'},
      {'icon': AppIcons.pharmacy, 'title': 'صيدلية', 'desc': 'اطلب أدويتك أونلاين'},
      {'icon': AppImages.videoCall, 'title': 'مكالمات', 'desc': 'مكالمات صوت وفيديو'},
      {'icon': AppImages.chatBubble, 'title': 'دردشة', 'desc': 'تواصل فوري مع الأطباء'},
      {'icon': AppAssets.calendarIcon, 'title': 'مواعيد', 'desc': 'إدارة مواعيدك'},
      {'icon': AppIcons.healthRecord, 'title': 'ملف صحي', 'desc': 'سجلك الطبي متكامل'},
    ];
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('الميزات الرئيسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12), GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: features.length, itemBuilder: (context, index) { final feature = features[index]; return Container(decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [LocalAssetIcon(feature['icon'] as String, color: AppColors.primary, size: 28), const SizedBox(height: 4), Text(feature['title'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), Text(feature['desc'] as String, style: TextStyle(fontSize: 9, color: AppColors.grey), textAlign: TextAlign.center)])); })]));
  }

  Widget _buildSocialLinks(bool isDark) {
    final socials = [
      {'icon': AppImages.socialFacebook, 'label': 'فيسبوك', 'url': 'https://www.facebook.com/'},
      {'icon': AppImages.socialInstagram, 'label': 'انستغرام', 'url': 'https://www.instagram.com/'},
      {'icon': AppIcons.socialXTwitter, 'label': 'تويتر', 'url': 'https://x.com/'},
      {'icon': AppImages.socialYoutube, 'label': 'يوتيوب', 'url': 'https://youtube.com/'},
      {'icon': AppIcons.socialLinkedin, 'label': 'لينكد إن', 'url': 'https://linkedin.com/'},
    ];
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('تواصل معنا', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: socials.map((social) => GestureDetector(onTap: () => _launchUrl(social['url'] as String), child: Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: LocalAssetIcon(social['icon'] as String, size: social['label'] == 'لينكد إن' ? 24 : 28))), const SizedBox(height: 6), Text(social['label'] as String, style: TextStyle(fontSize: 11, color: AppColors.grey))]))).toList())]));
  }

  Future<void> _launchUrl(String url) async { try { final uri = Uri.parse(url); if (await canLaunchUrl(uri)) { await launchUrl(uri); } else { ToastService.showSuccess('لا يمكن فتح الرابط'); } } catch (e) { ToastService.showError('حدث خطأ: $e'); } }
}
