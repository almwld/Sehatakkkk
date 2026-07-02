import 'package:flutter_test/flutter_test.dart';
import 'package:sehatak/core/services/payment_service.dart';

void main() {
  group('اختبارات خدمة الدفع (PaymentService)', () {
    final service = PaymentService();

    test('✅ توزيع الأرباح صحيح', () {
      final distribution = service._calculateDistribution(100.0);
      
      expect(distribution['platform'], 15.0);
      expect(distribution['doctor'], 60.0);
      expect(distribution['employee'], 25.0);
    });

    test('✅ توزيع الأرباح لمبلغ 200 ريال', () {
      final distribution = service._calculateDistribution(200.0);
      
      expect(distribution['platform'], 30.0);
      expect(distribution['doctor'], 120.0);
      expect(distribution['employee'], 50.0);
    });

    test('✅ توزيع الأرباح لمبلغ 50 ريال', () {
      final distribution = service._calculateDistribution(50.0);
      
      expect(distribution['platform'], 7.5);
      expect(distribution['doctor'], 30.0);
      expect(distribution['employee'], 12.5);
    });

    test('✅ المحافظ المدعومة تحتوي على فلوسك', () {
      expect(PaymentService.supportedWallets, contains('فلوسك'));
    });

    test('✅ المحافظ المدعومة تحتوي على جوالي', () {
      expect(PaymentService.supportedWallets, contains('جوالي'));
    });

    test('✅ المحافظ المدعومة تحتوي على جيب', () {
      expect(PaymentService.supportedWallets, contains('جيب'));
    });

    test('✅ المحافظ المدعومة تحتوي على كاش', () {
      expect(PaymentService.supportedWallets, contains('كاش'));
    });

    test('✅ المحافظ المدعومة تحتوي على إيزي', () {
      expect(PaymentService.supportedWallets, contains('إيزي'));
    });

    test('✅ عدد المحافظ المدعومة هو 8', () {
      expect(PaymentService.supportedWallets.length, 8);
    });

    test('✅ مفتاح التوزيع يحتوي على platform', () {
      expect(PaymentService.profitDistribution.containsKey('platform'), true);
    });

    test('✅ مفتاح التوزيع يحتوي على doctor', () {
      expect(PaymentService.profitDistribution.containsKey('doctor'), true);
    });

    test('✅ مفتاح التوزيع يحتوي على employee', () {
      expect(PaymentService.profitDistribution.containsKey('employee'), true);
    });

    test('✅ مجموع نسب التوزيع يساوي 1.0', () {
      final total = PaymentService.profitDistribution.values.fold(0.0, (a, b) => a + b);
      expect(total, 1.0);
    });
  });
}
