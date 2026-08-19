import 'package:flutter/material.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/core/services/payment_service.dart';

class WalletProvider extends ChangeNotifier {
  final String uid;
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  WalletProvider({required this.uid}) {
    loadWallet();
  }

  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get balance => _wallet?.balance ?? 0.0;

  Future<void> loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paymentService = PaymentService();
      _wallet = await paymentService.getWalletSnapshot();
      _transactions = await paymentService.getTransactionsStream().first;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshWallet() async {
    await loadWallet();
  }

  Future<void> topUp(double amount, String walletName, String reference) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paymentService = PaymentService();
      await paymentService.topUpWallet(
        amount: amount,
        walletName: walletName,
        referenceNumber: reference,
      );
      await loadWallet();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pay(double amount, String title, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paymentService = PaymentService();
      await paymentService.processPayment(
        amount: amount,
        title: title,
        description: description,
      );
      await loadWallet();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
