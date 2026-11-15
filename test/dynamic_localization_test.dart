import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';

void main() {
  test('localizedField reads field-specific values from nested translations', () {
    const data = <String, dynamic>{
      'name': 'مستشفى',
      'translations': {
        'en': {
          'name': 'City Hospital',
          'description': 'General medical care',
        },
        'fr': {
          'name': 'Hôpital de la ville',
          'description': 'Soins médicaux généraux',
        },
      },
    };

    expect(localizedField(data, 'name', const Locale('en')), 'City Hospital');
    expect(localizedField(data, 'description', const Locale('en')), 'General medical care');
    expect(localizedField(data, 'name', const Locale('fr')), 'Hôpital de la ville');
    expect(localizedField(data, 'description', const Locale('fr')), 'Soins médicaux généraux');
  });

  test('localizedField keeps supporting flat language translations', () {
    const data = <String, dynamic>{
      'name': 'مستشفى',
      'translations': {
        'en': 'Hospital',
        'fr': 'Hôpital',
      },
    };

    expect(localizedField(data, 'name', const Locale('en')), 'Hospital');
    expect(localizedField(data, 'name', const Locale('fr')), 'Hôpital');
  });
}
