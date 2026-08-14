import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '1.1.0';
  String _buildNumber = '2';

  // ✅ روابط السوشيال ميديا الفعلية
  final Map<String, String> _socialLinks = {
    'facebook': 'https://www.facebook.com/sehatak',
    'instagram': 'https://www.instagram.com/sehatak',
    'tiktok': 'https://www.tiktok.com/@sehatak',
    'x_twitter': 'https://twitter.com/sehatak',
    'youtube': 'https://www.youtube.com/@sehatak',
  };

  // ✅ أيقونات السوشيال ميديا (PNG)
  final List<Map<String, dynamic>> _socialIcons = [
    {'icon': 'assets/images/social/facebook.png', 'label': 'فيسبوك', 'url': 'https://www.facebook.com/sehatak'},
    {'icon': 'assets/images/social/instagram.png', 'label': 'انستغرام', 'url': 'https://www.instagram.com/sehatak'},
    {'icon': 'assets/images/social/tiktok.png', 'label': 'تيك توك', 'url': 'https://www.tiktok.com/@sehatak'},
    {'icon': 'assets/images/social/x_twitter.png', 'label': 'تويتر', 'url': 'https://twitter.com/sehatak'},
    {'icon': 'assets/images/social/youtube.png', 'label': 'يوتيوب', 'url': 'https://www.youtube.com/@sehatak'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('⚠️ Error loading package info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'عن التطبيق',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // ✅ شعار التطبيق
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.health_and_safety,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ اسم التطبيق
            const Text(
              'صحتك',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sehatak',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ الإصدار
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'الإصدار $_appVersion+$_buildNumber',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // ✅ الوصف
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'منصة الرعاية الصحية الشاملة في اليمن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تطبيق "صحتك" هو منصة طبية متكاملة تهدف إلى تسهيل الوصول إلى الخدمات الصحية في اليمن. نوفر لك إمكانية حجز المواعيد، والاستشارات الطبية، وطلب الأدوية، ومتابعة حالتك الصحية بكل سهولة وأمان.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ الميزات
            _buildFeatureSection(isDark),
            const SizedBox(height: 24),

            // ✅ روابط التواصل (باستخدام PNG)
            _buildSocialLinks(isDark),
            const SizedBox(height: 30),

            // ✅ حقوق النشر
            Text(
              '© 2026 Sehatak Platform',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'جميع الحقوق محفوظة',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎯 قسم الميزات
  // ============================================================
  Widget _buildFeatureSection(bool isDark) {
    final features = [
      {'icon': Icons.medical_services_rounded, 'title': 'أطباء', 'desc': 'استشر أفضل الأطباء'},
      {'icon': Icons.local_pharmacy_rounded, 'title': 'صيدلية', 'desc': 'اطلب أدويتك أونلاين'},
      {'icon': Icons.videocam_rounded, 'title': 'مكالمات', 'desc': 'مكالمات صوت وفيديو'},
      {'icon': Icons.chat_rounded, 'title': 'دردشة', 'desc': 'تواصل فوري مع الأطباء'},
      {'icon': Icons.calendar_month_rounded, 'title': 'مواعيد', 'desc': 'إدارة مواعيدك'},
      {'icon': Icons.folder_rounded, 'title': 'ملف صحي', 'desc': 'سجلك الطبي متكامل'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الميزات الرئيسية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      feature['desc'] as String,
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🌐 روابط التواصل الاجتماعي (باستخدام PNG)
  // ============================================================
  Widget _buildSocialLinks(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تواصل معنا',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: _socialIcons.map((social) {
              return GestureDetector(
                onTap: () => _launchUrl(social['url'] as String),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          social['icon'] as String,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.circle,
                              color: AppColors.primary,
                              size: 28,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      social['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔗 فتح الروابط
  // ============================================================
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
        ),
      );
    }
  }
}
