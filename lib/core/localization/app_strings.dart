import 'package:flutter/widgets.dart';

/// Small, deterministic UI dictionary. Add keys here before migrating screens
/// so translations never depend on network translation at runtime.
class AppStrings {
  AppStrings(this.locale);
  final Locale locale;

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context));

  String get language => _pick('اللغة', 'Language', 'Langue');
  String get settings => _pick('الإعدادات', 'Settings', 'Paramètres');
  String get chooseLanguage => _pick(
    'اختر لغة التطبيق', 'Choose your app language', 'Choisissez la langue de l’application');
  String get languageSaved => _pick(
    'تم حفظ اللغة', 'Language preference saved', 'Préférence linguistique enregistrée');
  String get arabic => _pick('العربية', 'Arabic', 'Arabe');
  String get english => _pick('الإنجليزية', 'English', 'Anglais');
  String get french => _pick('الفرنسية', 'French', 'Français');
  String get home => _pick('الرئيسية', 'Home', 'Accueil');
  String get doctors => _pick('الأطباء', 'Doctors', 'Médecins');
  String get pharmacy => _pick('الصيدلية', 'Pharmacy', 'Pharmacie');
  String get chat => _pick('الدردشة', 'Chat', 'Discussion');
  String get laboratories => _pick('المختبرات', 'Laboratories', 'Laboratoires');
  String get myHealth => _pick('صحتي', 'My Health', 'Ma santé');
  String get more => _pick('المزيد', 'More', 'Plus');
  String get search => _pick('بحث', 'Search', 'Rechercher');
  String get cancel => _pick('إلغاء', 'Cancel', 'Annuler');
  String get save => _pick('حفظ', 'Save', 'Enregistrer');
  String get done => _pick('تم', 'Done', 'Terminé');
  String get retry => _pick('إعادة المحاولة', 'Try again', 'Réessayer');
  String get noResults => _pick('لا توجد نتائج', 'No results found', 'Aucun résultat');

  String _pick(String ar, String en, String fr) {
    switch (locale.languageCode) {
      case 'en': return en;
      case 'fr': return fr;
      default: return ar;
    }
  }
}
