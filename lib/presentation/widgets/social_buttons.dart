import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_icons.dart';
import 'app_icon.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(
          icon: AppIcons.whatsapp,
          url: 'https://wa.me/967777123456',
          label: 'واتساب',
        ),
        const SizedBox(width: 16),
        _socialButton(
          icon: AppIcons.facebook,
          url: 'https://facebook.com/sehatak',
          label: 'فيسبوك',
        ),
        const SizedBox(width: 16),
        _socialButton(
          icon: AppIcons.instagram,
          url: 'https://instagram.com/sehatak',
          label: 'إنستجرام',
        ),
      ],
    );
  }

  Widget _socialButton({
    required String icon,
    required String url,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              path: icon,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
