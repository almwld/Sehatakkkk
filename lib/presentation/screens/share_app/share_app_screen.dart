import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  final String _appLink = 'https://github.com/almwld/Sehatakkkk';
  final String _shareMessage = 'مرحباً! أدعوك لتجربة تطبيق "صحتك" - منصة الرعاية الصحية الشاملة في اليمن. احجز مواعيدك، استشر الأطباء، واطلب أدويتك بكل سهولة. حمل التطبيق الآن من الرابط التالي:\n';

  final List<Map<String, dynamic>> _shareMethods = const [
    {'icon': Icons.chat, 'name': 'واتساب', 'color': Color(0xFF25D366), 'url': 'https://wa.me/?text='},
    {'icon': Icons.telegram, 'name': 'تيليجرام', 'color': Color(0xFF0088CC), 'url': 'https://t.me/share/url?url='},
    {'icon': Icons.facebook, 'name': 'فيسبوك', 'color': Color(0xFF1877F2), 'url': 'https://www.facebook.com/sharer/sharer.php?u='},
    {'icon': Icons.timeline, 'name': 'تويتر', 'color': Color(0xFF1DA1F2), 'url': 'https://twitter.com/intent/tweet?url='},
    {'icon': Icons.email, 'name': 'بريد إلكتروني', 'color': Color(0xFFEA4335), 'url': 'mailto:?subject=تطبيق صحتك&body='},
    {'icon': Icons.link, 'name': 'نسخ الرابط', 'color': AppColors.primary, 'url': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'مشاركة التطبيق',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildShareIcon(),
            const SizedBox(height: 24),
            _buildShareText(),
            const SizedBox(height: 32),
            _buildShareMethods(context, isDark),
            const SizedBox(height: 24),
            _buildGeneralShareButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShareIcon() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.share_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'شارك التطبيق مع أصدقائك',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'انشر الخير وشارك منصة صحتك مع الآخرين',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildShareText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Text(
        _shareMessage,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildShareMethods(BuildContext context, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _shareMethods.length,
      itemBuilder: (context, index) {
        final method = _shareMethods[index];
        return _buildShareMethod(
          context,
          icon: method['icon'] as IconData,
          name: method['name'] as String,
          color: method['color'] as Color,
          url: method['url'] as String,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildShareMethod(
    BuildContext context, {
    required IconData icon,
    required String name,
    required Color color,
    required String url,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _shareVia(context, url, name),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _generalShare(context),
        icon: const Icon(Icons.share_rounded),
        label: const Text(
          'مشاركة عبر...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _shareVia(BuildContext context, String url, String name) {
    if (name == 'نسخ الرابط') {
      _copyLink(context);
      return;
    }

    final fullUrl = '$url$_appLink';
    _launchUrl(context, fullUrl);
  }

  void _copyLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 تم نسخ رابط التطبيق'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _generalShare(BuildContext context) async {
    try {
      await Share.share(
        '$_shareMessage\n$_appLink',
        subject: 'تطبيق صحتك - منصة الرعاية الصحية',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل المشاركة: $e'),
        ),
      );
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
  }
}
