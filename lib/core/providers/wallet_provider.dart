import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/data/models/transaction_model.dart';
import 'package:sehatak/core/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final String uid;
  double balance = 0.0;
  bool loadingBalance = false;

  List<TransactionModel> transactions = [];
  bool loadingTransactions = false;
  bool hasMore = true;
  DocumentSnapshot? lastDoc;
  final int pageSize = 20;

  WalletProvider({required this.uid}) {
    init();
  }

  Future<void> init() async {
    await loadBalance();
    await refreshTransactions();
    
    // ✅ الاستماع لتحديثات المحفظة في الوقت الفعلي
    WalletService.walletStream(uid).listen((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        balance = (data['balance'] ?? 0).toDouble();
        notifyListeners();
      }
    });
  }

  Future<void> loadBalance() async {
    loadingBalance = true;
    notifyListeners();
    balance = await WalletService.getBalanceFirestore(uid);
    loadingBalance = false;
    notifyListeners();
  }

  Future<void> refreshTransactions() async {
    transactions = [];
    lastDoc = null;
    hasMore = true;
    await loadMoreTransactions();
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMore || loadingTransactions) return;
    loadingTransactions = true;
    notifyListeners();

    final page = await WalletService.getTransactionsFirestore(
      uid: uid,
      limit: pageSize,
      startAfter: lastDoc,
    );

    if (page.docs.isEmpty) {
      hasMore = false;
    } else {
      lastDoc = page.docs.last;
      transactions.addAll(
        page.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TransactionModel.fromMap(data);
        }).toList()
      );
    }

    loadingTransactions = false;
    notifyListeners();
  }

  // ✅ تحديث الرصيد بعد الدفع أو الشحن
  Future<void> refreshBalance() async {
    await loadBalance();
  }
}
