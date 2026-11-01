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


  String get appearance => _pick('المظهر', 'Appearance', 'Apparence');
  String get darkMode => _pick('الوضع المظلم', 'Dark mode', 'Mode sombre');
  String get darkModeDescription => _pick('تفعيل الوضع المظلم للتطبيق', 'Use the app in dark mode', 'Utiliser l’application en mode sombre');
  String get automaticMode => _pick('الوضع التلقائي', 'System default', 'Mode système');
  String get systemModeDescription => _pick('متابعة إعدادات النظام', 'Follow system appearance settings', 'Suivre les réglages du système');
  String get locationAndDelivery => _pick('الموقع والتوصيل', 'Location & delivery', 'Localisation et livraison');
  String get security => _pick('الأمان', 'Security', 'Sécurité');
  String get fontSize => _pick('حجم الخط', 'Text size', 'Taille du texte');
  String get account => _pick('الحساب', 'Account', 'Compte');
  String get appSection => _pick('التطبيق', 'App', 'Application');
  String get changeLanguage => _pick('تغيير لغة التطبيق', 'Change the app language', 'Changer la langue de l’application');
  String get profile => _pick('الملف الشخصي', 'Profile', 'Profil');
  String get editPersonalInfo => _pick('تعديل بياناتك الشخصية', 'Edit your personal information', 'Modifier vos informations personnelles');
  String get notifications => _pick('الإشعارات', 'Notifications', 'Notifications');
  String get helpSupport => _pick('المساعدة والدعم', 'Help & support', 'Aide et assistance');
  String get privacy => _pick('الخصوصية', 'Privacy', 'Confidentialité');
  String get about => _pick('عن التطبيق', 'About', 'À propos');
  String get logout => _pick('تسجيل الخروج', 'Sign out', 'Se déconnecter');
  String get currentFontSize => _pick('حجم الخط الحالي', 'Current text size', 'Taille actuelle du texte');
  String get small => _pick('صغير', 'Small', 'Petit');
  String get medium => _pick('متوسط', 'Medium', 'Moyen');
  String get large => _pick('كبير', 'Large', 'Grand');
  String get extraLarge => _pick('كبير جداً', 'Extra large', 'Très grand');
  String get backExitHint => _pick('انقر مرتين للخروج النهائي', 'Press back again to exit', 'Appuyez à nouveau pour quitter');

  String _pick(String ar, String en, String fr) {
    switch (locale.languageCode) {
      case 'en': return en;
      case 'fr': return fr;
      default: return ar;
    }
  }
}
