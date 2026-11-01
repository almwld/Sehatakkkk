import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/providers/app_locale_controller.dart';
import 'package:sehatak/core/localization/app_strings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists the selected language across controller instances', () async {
    final controller = AppLocaleController();
    await controller.setLanguage('fr');
    expect(controller.locale, const Locale('fr', 'FR'));

    final restored = AppLocaleController();
    await restored.load();
    expect(restored.locale, const Locale('fr', 'FR'));
  });

  test('restores Arabic when no supported language is saved', () async {
    final controller = AppLocaleController();
    await controller.load();
    expect(controller.locale, const Locale('ar', 'SA'));
  });

  group('AppStrings locale translations', () {
    test('translates common healthcare labels to English', () {
      final strings = AppStrings(const Locale('en', 'US'));
      expect(strings.translate('الأطباء'), 'Doctors');
      expect(strings.translate('الصيدلية'), 'Pharmacy');
      expect(strings.translate('المختبرات'), 'Laboratories');
    });

    test('translates common healthcare labels to French', () {
      final strings = AppStrings(const Locale('fr', 'FR'));
      expect(strings.translate('الأطباء'), 'Médecins');
      expect(strings.translate('الصيدلية'), 'Pharmacie');
      expect(strings.translate('المختبرات'), 'Laboratoires');
    });

    test('keeps Arabic labels in Arabic locale', () {
      final strings = AppStrings(const Locale('ar', 'SA'));
      expect(strings.translate('الأطباء'), 'الأطباء');
    });


    test('translates medication and laboratory workflows to English', () {
      final strings = AppStrings(const Locale('en', 'US'));
      expect(strings.translate('تذكير الأدوية'), 'Medication reminders');
      expect(strings.translate('إضافة دواء'), 'Add medication');
      expect(strings.translate('حجز الفحوصات'), 'Book laboratory tests');
      expect(strings.translate('نتائج الفحوصات'), 'Test results');
    });

    test('translates medication and laboratory workflows to French', () {
      final strings = AppStrings(const Locale('fr', 'FR'));
      expect(strings.translate('تذكير الأدوية'), 'Rappels de médicaments');
      expect(strings.translate('إضافة دواء'), 'Ajouter un médicament');
      expect(strings.translate('حجز الفحوصات'), 'Réserver des analyses');
      expect(strings.translate('نتائج الفحوصات'), 'Résultats des analyses');
    });

    test('translates cart and chat actions', () {
      final strings = AppStrings(const Locale('en', 'US'));
      expect(strings.translate('سلة المشتريات'), 'Shopping cart');
      expect(strings.translate('الرسائل المثبتة'), 'Pinned messages');
      expect(strings.translate('متصل الآن'), 'Online now');
    });

    test('translates home and permission prompts to English and French', () {
      final english = AppStrings(const Locale('en', 'US'));
      final french = AppStrings(const Locale('fr', 'FR'));
      expect(english.translate('تفعيل المكالمات الواردة'), 'Enable incoming calls');
      expect(english.translate('لاحقاً'), 'Later');
      expect(english.translate('فتح إعدادات النظام'), 'Open system settings');
      expect(french.translate('تفعيل المكالمات الواردة'), 'Activer les appels entrants');
      expect(french.translate('لاحقاً'), 'Plus tard');
      expect(french.translate('فتح إعدادات النظام'), 'Ouvrir les paramètres système');
    });

    test('formats Yemeni rial consistently for each locale', () {
      expect(AppStrings(const Locale('ar', 'SA')).formatCurrency(1250), '1250 ر.ي');
      expect(AppStrings(const Locale('en', 'US')).formatCurrency(1250), '1250 YER');
      expect(AppStrings(const Locale('fr', 'FR')).formatCurrency(1250), '1250 YER');
      expect(AppStrings(const Locale('en', 'US')).formatCurrency(1250.5), '1250.50 YER');
    });

    test('translates biometric settings feedback', () {
      final english = AppStrings(const Locale('en', 'US'));
      final french = AppStrings(const Locale('fr', 'FR'));
      expect(english.translate('سجل باستخدام بصمة الإصبع لتأكيد الهوية'),
          'Use your fingerprint to verify your identity');
      expect(english.translate('فشل التحقق من البصمة، حاول مرة أخرى'),
          'Fingerprint verification failed. Please try again.');
      expect(french.translate('تسجيل الدخول بالبصمة'),
          'Connexion par empreinte');
    });

    test('translates laboratory dashboard actions and statuses', () {
      final english = AppStrings(const Locale('en', 'US'));
      final french = AppStrings(const Locale('fr', 'FR'));
      expect(english.translate('لوحة المختبر'), 'Laboratory dashboard');
      expect(english.translate('إضافة فحص جديد'), 'Add new test');
      expect(english.translate('تم تحديث حالة الحجز'), 'Booking status updated');
      expect(french.translate('حالة التوثيق'), 'Statut de vérification');
    });

    test('preserves unknown and user-provided content', () {
      final strings = AppStrings(const Locale('en', 'US'));
      expect(strings.translate('A patient supplied note'), 'A patient supplied note');
    });
  });
}
