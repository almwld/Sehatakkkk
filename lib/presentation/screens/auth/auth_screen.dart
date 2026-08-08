// ✅ في _buildSocialImageButton - استخدام Image.asset بدلاً من Image.network
Widget _buildSocialImageButton({
  required String assetPath,
  required VoidCallback onTap,
  required bool isDark,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white30 : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Image.asset(
        assetPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image,
            size: 32,
            color: isDark ? Colors.white70 : Colors.grey[600],
          );
        },
      ),
    ),
  );
}

// ✅ استخدام المسارات المحلية
_buildSocialImageButton(
  assetPath: 'assets/images/social/google.png',
  onTap: () {},
  isDark: isDark,
),

_buildSocialImageButton(
  assetPath: 'assets/images/social/apple.png',
  onTap: () {},
  isDark: isDark,
),

// السوشيال ميديا
_buildSocialImageButton(
  assetPath: 'assets/images/social/instagram.png',
  onTap: () => _launchUrl('...'),
  isDark: isDark,
),

_buildSocialImageButton(
  assetPath: 'assets/images/social/x_twitter.png',
  onTap: () => _launchUrl('...'),
  isDark: isDark,
),

_buildSocialImageButton(
  assetPath: 'assets/images/social/facebook.png',
  onTap: () => _launchUrl('...'),
  isDark: isDark,
),

_buildSocialImageButton(
  assetPath: 'assets/images/social/youtube.png',
  onTap: () => _launchUrl('...'),
  isDark: isDark,
),

_buildSocialImageButton(
  assetPath: 'assets/images/social/tiktok.png',
  onTap: () => _launchUrl('...'),
  isDark: isDark,
),
