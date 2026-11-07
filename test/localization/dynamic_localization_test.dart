import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';

void main() {
  group('localizedField', () {
    test('prefers language-specific sibling fields', () {
      final data = {
        'name': 'اسم عربي',
        'nameEn': 'English name',
        'nameFr': 'Nom français',
      };

      expect(localizedField(data, 'name', const Locale('ar')), 'اسم عربي');
      expect(localizedField(data, 'name', const Locale('en')), 'English name');
      expect(localizedField(data, 'name', const Locale('fr')), 'Nom français');
    });

    test('reads translations maps and falls back to the source value', () {
      final data = {
        'title': 'عنوان عربي',
        'translations': {
          'en': 'English title',
          'fr': {'title': 'Titre français'},
        },
      };

      expect(localizedField(data, 'title', const Locale('en')), 'English title');
      expect(localizedField(data, 'title', const Locale('fr')), 'Titre français');
      expect(localizedField(data, 'title', const Locale('ar')), 'عنوان عربي');
    });

    test('uses explicit fallback when the field is absent', () {
      expect(
        localizedField({}, 'name', const Locale('en'), fallback: 'Unknown'),
        'Unknown',
      );
    });
  });
}
