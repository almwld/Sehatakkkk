import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SvgIcon extends StatelessWidget {
  final String path;
  final double size;
  final Color? color;

  const SvgIcon({
    super.key,
    required this.path,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => Container(
        width: size,
        height: size,
        color: Colors.grey[300],
      ),
    );
  }
}

/// ✅ أيقونات جاهزة للاستخدام
class AppIcons {
  // ========== Navigation ==========

  // ========== Services ==========
  static const String chat = 'assets/icons/services/chat.svg';
  static const String audioCall = 'assets/icons/services/audio_call.svg';
  static const String videoCall = 'assets/icons/services/video_call.svg';
  static const String emergency = 'assets/icons/services/emergency.svg';
  static const String homeVisit = 'assets/icons/services/home_visit.svg';
  static const String checkup = 'assets/icons/services/checkup.svg';

  // ========== Specialties ==========
  static const String pediatric = 'assets/icons/specialties/pediatric.svg';
  static const String orthopedic = 'assets/icons/specialties/orthopedic.svg';
  static const String neurology = 'assets/icons/specialties/neurology.svg';
  static const String pulmonology = 'assets/icons/specialties/pulmonology.svg';

  // ========== Lab ==========

  // ========== Social ==========
  static const String facebook = 'assets/icons/social/facebook.svg';
  static const String whatsapp = 'assets/icons/social/whatsapp.svg';
  static const String instagram = 'assets/icons/social/instagram.svg';
  static const String twitter = 'assets/icons/social/twitter.svg';

  // ========== Plans ==========
  static const String free = 'assets/icons/plans/free.svg';
  static const String silver = 'assets/icons/plans/silver.svg';
  static const String gold = 'assets/icons/plans/gold.svg';
  static const String family = 'assets/icons/plans/family.svg';

  // ========== Consultations ==========

  // ========== Offers ==========
  static const String discount = 'assets/icons/offers/discount.svg';
  static const String familyOffer = 'assets/icons/offers/family_offer.svg';
  static const String healthCheck = 'assets/icons/offers/health_check.svg';
}
