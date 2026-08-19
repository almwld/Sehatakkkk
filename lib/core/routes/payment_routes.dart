import 'package:flutter/material.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/presentation/screens/payment/payment_invoice_screen.dart';
import 'package:sehatak/presentation/screens/payment/payment_methods_screen.dart';
import 'package:sehatak/presentation/screens/payment/payment_success_screen.dart';
import 'package:sehatak/presentation/screens/wallet/top_up_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';

class PaymentRoutes {
  static const String wallet = '/wallet';
  static const String topUp = '/wallet/top-up';
  static const String paymentMethods = '/payment/methods';
  static const String invoice = '/payment/invoice';
  static const String success = '/payment/success';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());

      case topUp:
        return MaterialPageRoute(builder: (_) => const TopUpScreen());

      case paymentMethods:
        return MaterialPageRoute(
          builder: (_) => PaymentMethodsScreen(
            onSelectWallet: settings.arguments as Function(LocalWalletOption)?,
          ),
        );

      case invoice:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentInvoiceScreen(
            items: args['items'] as List<Map<String, dynamic>>? ?? [],
            invoiceTitle: args['title'] as String? ?? 'فاتورة خدمات طبية',
          ),
        );

      case success:
        final transaction = settings.arguments as TransactionModel;
        return MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(transaction: transaction),
        );

      default:
        return null;
    }
  }
}
