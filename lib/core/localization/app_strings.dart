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


  String get confirmLogout => _pick('هل أنت متأكد من رغبتك في تسجيل الخروج؟', 'Are you sure you want to sign out?', 'Voulez-vous vraiment vous déconnecter ?');
  String get locationTitle => _pick('تحديد منطقتك', 'Set your location', 'Définir votre emplacement');
  String get chooseLocation => _pick('اختر محافظتك وحدد موقعك بالتفصيل أو عبر GPS', 'Choose your governorate and set your location or use GPS', 'Choisissez votre gouvernorat et définissez votre emplacement ou utilisez le GPS');
  String get biometricLogin => _pick('تسجيل الدخول بالبصمة', 'Biometric sign-in', 'Connexion biométrique');
  String get biometricEnabled => _pick('تم التفعيل - استخدم بصمتك للدخول', 'Enabled — use your fingerprint to sign in', 'Activé — utilisez votre empreinte pour vous connecter');
  String get enableBiometric => _pick('تفعيل تسجيل الدخول باستخدام بصمة الإصبع', 'Enable fingerprint sign-in', 'Activer la connexion par empreinte');
  String get securityDevices => _pick('الأمان والأجهزة', 'Security & devices', 'Sécurité et appareils');
  String get manageSessions => _pick('إدارة الجلسات وتسجيل الخروج وحذف الحساب', 'Manage sessions, sign out, and delete your account', 'Gérer les sessions, se déconnecter et supprimer votre compte');
  String get changePassword => _pick('تغيير كلمة المرور', 'Change password', 'Modifier le mot de passe');
  String get updatePassword => _pick('تحديث كلمة المرور الخاصة بك', 'Update your password', 'Mettre à jour votre mot de passe');
  String get notificationsDescription => _pick('إدارة الإشعارات الفورية والأنواع والتفضيلات', 'Manage push notifications, types, and preferences', 'Gérer les notifications push, les types et les préférences');
  String get helpDescription => _pick('الأسئلة الشائعة والدعم الفني', 'FAQs and technical support', 'FAQ et assistance technique');
  String get privacyDescription => _pick('سياسة الخصوصية والأمان', 'Privacy and security policy', 'Politique de confidentialité et de sécurité');
  String get signOutError => _pick('خطأ في تسجيل الخروج', 'Sign-out error', 'Erreur de déconnexion');
  String get biometricFailure => _pick('فشل التحقق من البصمة، حاول مرة أخرى', 'Fingerprint verification failed. Try again.', 'Échec de la vérification de l’empreinte. Réessayez.');
  String get biometricUpdateFailure => _pick('تعذر تحديث إعداد البصمة', 'Could not update biometric settings', 'Impossible de mettre à jour les paramètres biométriques');

  String _pick(String ar, String en, String fr) {
    switch (locale.languageCode) {
      case 'en': return en;
      case 'fr': return fr;
      default: return ar;
    }
  }
}
