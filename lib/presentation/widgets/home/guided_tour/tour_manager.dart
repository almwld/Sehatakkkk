import 'package:shared_preferences/shared_preferences.dart';

/// مدير مركزي لحالة ظهور الجولات التعريفية.
abstract final class TourManager {
  static const String homeKey = 'has_seen_home_tour';
  static const String doctorsKey = 'has_seen_doctors_tour';
  static const String pharmacyKey = 'has_seen_pharmacy_tour';
  static const String labsKey = 'has_seen_labs_tour';
  static const String profileKey = 'has_seen_profile_tour';
  static const String moreKey = 'has_seen_more_tour';

  static const List<String> allKeys = [
    homeKey,
    doctorsKey,
    pharmacyKey,
    labsKey,
    profileKey,
    moreKey,
  ];

  static Future<bool> hasSeen(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(tourKey) ?? false;
  }

  static Future<void> markAsSeen(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(tourKey, true);
  }

  static Future<void> reset(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tourKey);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in allKeys) {
      await prefs.remove(key);
    }
  }
}
