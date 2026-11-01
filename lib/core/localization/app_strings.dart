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

  /// Translates a literal Arabic UI label without network access. Unknown and
  /// user-generated content is intentionally preserved.
  String translate(String value) {
    const translations = <String, List<String>>{
      'صحو': ['Clear', 'Dégagé'],
      'غائم جزئياً': ['Partly cloudy', 'Partiellement nuageux'],
      'ضباب': ['Fog', 'Brouillard'],
      'أمطار': ['Rain', 'Pluie'],
      'ثلوج': ['Snow', 'Neige'],
      'زخات مطر': ['Rain showers', 'Averses'],
      'عواصف رعدية': ['Thunderstorms', 'Orages'],
      'تعذر تحديث الطقس الآن': ['Weather is currently unavailable', 'Météo indisponible pour le moment'],
      'مستشفيات مميزة': ['Featured hospitals', 'Hôpitaux à la une'],
      'مختبرات مميزة': ['Featured laboratories', 'Laboratoires à la une'],
      'صيدليات مميزة': ['Featured pharmacies', 'Pharmacies à la une'],
      'حدث خطأ غير متوقع': ['An unexpected error occurred', 'Une erreur inattendue est survenue'],
      'صباح الخير': ['Good morning', 'Bonjour'],
      'مساء الخير': ['Good evening', 'Bonsoir'],
      'مستخدم': ['User', 'Utilisateur'],
      'ابحث عن طبيب، دواء، أو خدمة...': ['Search for a doctor, medicine, or service...', 'Rechercher un médecin, un médicament ou un service...'],
      'صحتك معك كل يوم': ['Your health, every day', 'Votre santé, chaque jour'],
      'أفضل الأطباء': ['Top doctors', 'Meilleurs médecins'],
      'لا يوجد أطباء موثقون متاحون حالياً': ['No verified doctors are available right now', 'Aucun médecin vérifié n’est disponible pour le moment'],
      'طبيب': ['Doctor', 'Médecin'],
      'تخصص طبي': ['Medical specialty', 'Spécialité médicale'],
      'منتجات مميزة': ['Featured products', 'Produits à la une'],
      'لا توجد منتجات متاحة حالياً': ['No products are currently available', 'Aucun produit n’est disponible pour le moment'],
      'حجز موعد': ['Book an appointment', 'Prendre rendez-vous'],
      'طوارئ': ['Emergency', 'Urgences'],
      'خريطة': ['Map', 'Carte'],
      'باقات': ['Packages', 'Forfaits'],
      'جميع الخدمات': ['All services', 'Tous les services'],
      'اكتشف المزيد': ['Discover more', 'Découvrir plus'],
      'المزيد': ['More', 'Plus'],
      'لا توجد بيانات متاحة حالياً': ['No data is currently available', 'Aucune donnée disponible pour le moment'],
      'صيدلية': ['Pharmacy', 'Pharmacie'],
      'مقالات طبية': ['Medical articles', 'Articles médicaux'],
      'لا توجد مقالات منشورة حالياً': ['No articles have been published yet', 'Aucun article n’a encore été publié'],
      'نصائح يومية': ['Daily health tips', 'Conseils santé quotidiens'],
      'لا توجد نصائح منشورة حالياً': ['No tips have been published yet', 'Aucun conseil n’a encore été publié'],
      'الطقس': ['Weather', 'Météo'],
      'غير متوفر': ['Not available', 'Indisponible'],
      'المجتمع': ['Community', 'Communauté'],
      'لا توجد منشورات منشورة حالياً': ['No posts have been published yet', 'Aucune publication pour le moment'],
      'عام': ['General', 'Général'],
      'الكل': ['All', 'Tout'],
      'باطنية': ['Internal medicine', 'Médecine interne'],
      'قلبية': ['Cardiology', 'Cardiologie'],
      'أطفال': ['Pediatrics', 'Pédiatrie'],
      'نساء وولادة': ['Obstetrics & gynecology', 'Gynécologie-obstétrique'],
      'جلدية': ['Dermatology', 'Dermatologie'],
      'عظام': ['Orthopedics', 'Orthopédie'],
      'نفسية': ['Psychiatry', 'Psychiatrie'],
      'أنف وأذن وحنجرة': ['ENT', 'ORL'],
      'أسنان': ['Dentistry', 'Dentisterie'],
      'عيون': ['Ophthalmology', 'Ophtalmologie'],
      'الأطباء': ['Doctors', 'Médecins'],
      'ابحث عن طبيب...': ['Search for a doctor...', 'Rechercher un médecin...'],
      'حساب الطبيب غير مرتبط بحساب المستخدم': ['The doctor account is not linked to a user account', 'Le compte du médecin n’est pas associé à un compte utilisateur'],
      'لا يمكنك الاتصال بنفسك': ['You cannot call yourself', 'Vous ne pouvez pas vous appeler vous-même'],
      'دردشة': ['Chat', 'Discussion'],
      'اتصال': ['Call', 'Appeler'],
      'فيديو': ['Video', 'Vidéo'],
      'متاح': ['Available', 'Disponible'],
      'لا توجد نتائج': ['No results', 'Aucun résultat'],
      'لا يوجد أطباء متاحون': ['No doctors available', 'Aucun médecin disponible'],
      'لم يتم العثور على طبيب يطابق البحث': ['No doctor matches your search', 'Aucun médecin ne correspond à votre recherche'],
      'سيظهر الأطباء المعتمدون هنا عند توفرهم': ['Verified doctors will appear here when available', 'Les médecins vérifiés apparaîtront ici lorsqu’ils seront disponibles'],
      'تعذر تحميل الأطباء': ['Could not load doctors', 'Impossible de charger les médecins'],
      'إعادة المحاولة': ['Try again', 'Réessayer'],
      'مختبرات صحتك': ['Sehatak Laboratories', 'Laboratoires Sehatak'],
      'المختبرات': ['Laboratories', 'Laboratoires'],
      'الأفضل': ['Top rated', 'Les mieux notés'],
      'سحب منزلي': ['Home sample collection', 'Prélèvement à domicile'],
      'حجوزاتي': ['My bookings', 'Mes réservations'],
      'ابحث عن مختبر، تخصص، أو فحص...': ['Search labs, specialties, or tests...', 'Rechercher un laboratoire, une spécialité ou un examen...'],
      'لا توجد مختبرات مسجلة حاليًا.': ['No laboratories are registered yet.', 'Aucun laboratoire n’est encore enregistré.'],
      'لا توجد نتائج مطابقة للبحث.': ['No matching results found.', 'Aucun résultat correspondant.'],
      'العنوان غير متوفر': ['Address unavailable', 'Adresse indisponible'],
      'مفتوح': ['Open', 'Ouvert'],
      'مغلق': ['Closed', 'Fermé'],
      'فحص': ['test', 'analyse'],
      'سجّل الدخول لمتابعة حجوزاتك ونتائجك.': ['Sign in to track your bookings and results.', 'Connectez-vous pour suivre vos réservations et résultats.'],
      'تعذر تحميل الحجوزات الحالية.': ['Could not load current bookings.', 'Impossible de charger les réservations actuelles.'],
      'لا توجد حجوزات مختبرات حتى الآن.': ['You have no laboratory bookings yet.', 'Vous n’avez pas encore de réservation de laboratoire.'],
      'النتائج': ['Results', 'Résultats'],
      'قيد الانتظار': ['Pending', 'En attente'],
      'تم أخذ العينة': ['Sample collected', 'Échantillon prélevé'],
      'قيد التحليل': ['Processing', 'En cours d’analyse'],
      'مكتمل': ['Completed', 'Terminé'],
      'ملغي': ['Cancelled', 'Annulé'],
      'متاجر مميزة': ['Featured pharmacies', 'Pharmacies à la une'],
      'المنتجات': ['Products', 'Produits'],
      'العروض': ['Offers', 'Offres'],
      'الطلبات': ['Orders', 'Commandes'],
      'مفتوحة الآن': ['Open now', 'Ouvert maintenant'],
      'توصيل': ['Delivery', 'Livraison'],
      'جديد': ['New', 'Nouveau'],
      'قيد التجهيز': ['Preparing', 'En préparation'],
      'قيد التوصيل': ['Out for delivery', 'En cours de livraison'],
      'مكتمل': ['Completed', 'Terminé'],
      'غير محدد': ['Unspecified', 'Non spécifié'],
      'منتج': ['Product', 'Produit'],
      'تمت إضافة المنتج إلى السلة': ['Product added to cart', 'Produit ajouté au panier'],
      'صيدلية صحتك': ['Sehatak Pharmacy', 'Pharmacie Sehatak'],
      'ابحث عن دواء، منتج، أو صيدلية': ['Search for a medicine, product, or pharmacy', 'Rechercher un médicament, un produit ou une pharmacie'],
      'لا توجد صيدليات منشورة تطابق البحث حالياً': ['No published pharmacies match your search', 'Aucune pharmacie publiée ne correspond à votre recherche'],
      'الموقع غير محدد': ['Location not specified', 'Emplacement non spécifié'],
      'مفتوحة الآن': ['Open now', 'Ouvert maintenant'],
      'مغلقة': ['Closed', 'Fermé'],
      'توصيل متاح': ['Delivery available', 'Livraison disponible'],
      'التوصيل غير متاح': ['Delivery unavailable', 'Livraison indisponible'],
      'لا توجد منتجات منشورة تطابق البحث حالياً': ['No published products match your search', 'Aucun produit publié ne correspond à votre recherche'],
      'لا توجد عروض منشورة حالياً': ['No offers are currently available', 'Aucune offre n’est disponible pour le moment'],
      'متوفر': ['In stock', 'En stock'],
      'نفد المخزون': ['Out of stock', 'Rupture de stock'],
      'يتطلب وصفة': ['Prescription required', 'Ordonnance requise'],
      'سجّل الدخول لعرض طلباتك': ['Sign in to view your orders', 'Connectez-vous pour voir vos commandes'],
      'لا توجد طلبات صيدلية حالياً': ['No pharmacy orders yet', 'Aucune commande de pharmacie pour le moment'],
      'طلب صيدلية': ['Pharmacy order', 'Commande de pharmacie'],
      'الدردشة': ['Chat', 'Discussion'],
      'المحادثات': ['Chats', 'Discussions'],
      'المكالمات': ['Calls', 'Appels'],
      'تواصل صحي': ['Health connections', 'Contacts santé'],
      'ابحث في محادثاتك...': ['Search your chats...', 'Rechercher dans vos discussions...'],
      'المساعد الصحي الذكي': ['AI Health Assistant', 'Assistant santé IA'],
      'اسأل الآن عن صحتك': ['Ask about your health', 'Posez vos questions sur votre santé'],
      'لا توجد محادثات بعد\nابدأ محادثة مع طبيب من تبويب تواصل صحي': ['No chats yet\nStart a conversation with a doctor from Health Connections', 'Aucune discussion\nCommencez une conversation avec un médecin depuis Contacts santé'],
      'لا توجد نتائج مطابقة': ['No matching results', 'Aucun résultat correspondant'],
      'اضغط لفتح المحادثة': ['Tap to open the chat', 'Appuyez pour ouvrir la discussion'],
      'الحالات اليومية': ['Daily stories', 'Actualités du jour'],
      'محادثة': ['Message', 'Message'],
      'يرجى تسجيل الدخول أولاً': ['Please sign in first', 'Veuillez vous connecter d’abord'],
      'حساب الطبيب غير صالح': ['Invalid doctor account', 'Compte médecin invalide'],
      'لا يمكنك بدء محادثة مع حسابك': ['You cannot start a chat with your own account', 'Vous ne pouvez pas démarrer une discussion avec votre propre compte'],
      'تعذر فتح المحادثة: $e': ['Could not open chat: $e', 'Impossible d’ouvrir la discussion : $e'],
      'لا يوجد أطباء موثقون متاحون للمحادثة حالياً': ['No verified doctors are available to chat right now', 'Aucun médecin vérifié n’est disponible pour discuter actuellement'],
      'اختر طبيباً لبدء المحادثة': ['Choose a doctor to start a conversation', 'Choisissez un médecin pour commencer une discussion'],
    };
    final entry = translations[value];
    if (entry == null) return value;
    switch (locale.languageCode) {
      case 'en': return entry[0];
      case 'fr': return entry[1];
      default: return value;
    }
  }

  String _pick(String ar, String en, String fr) {
    switch (locale.languageCode) {
      case 'en': return en;
      case 'fr': return fr;
      default: return ar;
    }
  }
}
