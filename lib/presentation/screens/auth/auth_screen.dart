import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/roles.dart';
import 'package:sehatak/core/constants/medical_specialties.dart';
import 'package:sehatak/core/models/user_model.dart';
import 'package:sehatak/core/services/biometric_service.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/presentation/screens/terms/terms_screen.dart';
import 'package:sehatak/presentation/screens/onboarding/role_onboarding_screen.dart';
import 'package:sehatak/presentation/screens/verification/verification_screen.dart';
import 'package:sehatak/presentation/screens/platform/dashboard/platform_dashboard.dart';
import 'package:sehatak/presentation/screens/auth/forgot_password_screen.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class AuthScreen extends StatefulWidget {
  final bool isSignUp;
  const AuthScreen({super.key, this.isSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// ... (باقي الكود كما هو)

// ✅ في build method - استخدام أيقونات السوشيال ميديا SVG
Widget _buildSocialSvgButton({
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
      child: SvgPicture.asset(
        assetPath,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          isDark ? Colors.white : Colors.black87,
          BlendMode.srcIn,
        ),
        placeholderBuilder: (_) => Container(
          width: 32,
          height: 32,
          color: Colors.grey[200],
          child: const Icon(Icons.circle, size: 32),
        ),
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image,
            color: isDark ? Colors.white70 : Colors.grey[600],
            size: 32,
          );
        },
      ),
    ),
  );
}

// ✅ استخدام الأيقونات في build
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    _buildSocialSvgButton(
      assetPath: 'assets/icons/social/google.svg',  // ✅ استخدم المسار الصحيح
      onTap: () {},
      isDark: isDark,
    ),
    const SizedBox(width: 20),
    _buildSocialSvgButton(
      assetPath: 'assets/icons/social/apple.svg',   // ✅ استخدم المسار الصحيح
      onTap: () {},
      isDark: isDark,
    ),
  ],
),

// ✅ أيقونات السوشيال ميديا الأخرى
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    _buildSocialSvgButton(
      assetPath: 'assets/icons/social/instagram.svg',
      onTap: () => _launchUrl('...'),
      isDark: isDark,
    ),
    const SizedBox(width: 14),
    _buildSocialSvgButton(
      assetPath: 'assets/icons/social/x_twitter.svg',
      onTap: () => _launchUrl('...'),
      isDark: isDark,
    ),
    const SizedBox(width: 14),
    _buildSocialSvgButton(
      assetPath: 'assets/icons/social/facebook.svg',
      onTap: () => _launchUrl('...'),
      isDark: isDark,
    ),
    const SizedBox(width: 14),
    _buildSocialSvgButton(
      assetPath: 'assets/icons/social/youtube.svg',
      onTap: () => _launchUrl('...'),
      isDark: isDark,
    ),
    const SizedBox(width: 14),
    _buildSocialSvgButton(
      assetPath: 'assets/icons/social/tiktok.svg',
      onTap: () => _launchUrl('...'),
      isDark: isDark,
    ),
  ],
),
