import 'package:flutter/material.dart';
import 'package:sehatak/core/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final String uid;
  double _balance = 0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  WalletProvider({required this.uid}) {
    loadWallet();
  }

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadWallet() async {
    _isLoading = true;
    notifyListeners();

    try {
      final wallet = await WalletService().getWallet(uid);
      if (wallet != null) {
        _balance = wallet.balance;
        _transactions = wallet.transactions;
      }
    } catch (e) {
      print('❌ Error loading wallet: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBalance(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      await WalletService().addBalance(uid, amount);
      await loadWallet();
    } catch (e) {
      print('❌ Error adding balance: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
