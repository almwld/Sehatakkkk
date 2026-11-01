import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/core/localization/app_strings.dart';

void main() {
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

    test('preserves unknown and user-provided content', () {
      final strings = AppStrings(const Locale('en', 'US'));
      expect(strings.translate('A patient supplied note'), 'A patient supplied note');
    });
  });
}
