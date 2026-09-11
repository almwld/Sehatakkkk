import 'package:sehatak/core/services/payment_service.dart';

/// Compatibility facade for wallet UI. Financial mutations are delegated to
/// PaymentService and therefore remain server-authorized through Firebase Functions.
class WalletService {
  WalletService({PaymentService? paymentService}) : _payment = paymentService ?? PaymentService();
  final PaymentService _payment;

  static const String merchantCode = 'SEHATAK';
  static const List<String> supportedWallets = [
    'جيب', 'فلوسك', 'جوالي', 'كاش', 'كريمي جوال', 'كاش ONE', 'إيزي', 'موبايل موني', 'يمن وولت',
  ];

  Future<Map<String, dynamic>> deposit({
    required String userId,
    required double amount,
    required String walletNumber,
    required String walletType,
  }) async {
    if (_payment.currentUserId != userId) throw Exception('المستخدم غير مسجل الدخول');
    final transaction = await _payment.topUpWallet(
      amount: amount,
      walletName: walletType,
      referenceNumber: walletNumber,
      metadata: {'source': 'deposit_screen', 'merchantCode': merchantCode},
    );
    return {'success': true, 'transactionId': transaction.id, 'status': transaction.status.name};
  }
}
