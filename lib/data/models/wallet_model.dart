import 'package:cloud_firestore/cloud_firestore.dart';

/// 💳 نموذج المحفظة
class WalletModel {
  final double balance;
  final String currency;
  final DateTime updatedAt;

  WalletModel({
    required this.balance,
    required this.currency,
    required this.updatedAt,
  });

  factory WalletModel.fromMap(Map<String, dynamic> m) => WalletModel(
        balance: (m['balance'] ?? 0).toDouble(),
        currency: m['currency'] ?? 'YER',
        updatedAt: (m['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'balance': balance,
        'currency': currency,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  WalletModel copyWith({
    double? balance,
    String? currency,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
