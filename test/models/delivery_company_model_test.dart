import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/core/models/delivery/delivery_company_model.dart';

void main() {
  group('DeliveryCompanyModel localization', () {
    test('prefers sibling language fields', () {
      final company = DeliveryCompanyModel.fromMap({
        'name': 'شركة التوصيل',
        'nameEn': 'Delivery Company',
        'nameFr': 'Société de livraison',
      }, 'provider-1');

      expect(company.localizedName('ar'), 'شركة التوصيل');
      expect(company.localizedName('en'), 'Delivery Company');
      expect(company.localizedName('fr'), 'Société de livraison');
    });

    test('supports translations map and falls back to Arabic', () {
      final company = DeliveryCompanyModel.fromMap({
        'name': 'شركة محلية',
        'translations': {
          'en': {'name': 'Local Company'},
          'fr': 'Entreprise locale',
        },
      }, 'provider-2');

      expect(company.localizedName('en'), 'Local Company');
      expect(company.localizedName('fr'), 'Entreprise locale');
      expect(company.localizedName('ar'), 'شركة محلية');
      expect(company.localizedName('de'), 'شركة محلية');
    });

    test('falls back to Arabic when a localized value is empty', () {
      final company = DeliveryCompanyModel.fromMap({
        'name': 'شركة التوصيل',
        'nameEn': '  ',
      }, 'provider-3');

      expect(company.localizedName('en'), 'شركة التوصيل');
    });
  });
}
