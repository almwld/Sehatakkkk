import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final int amount;
  final String? bookingId;
  final String? providerId;
  final String? providerName;
  final String? packageName;
  final String? bookingType;
  final bool isSubscription;

  const PaymentScreen({
    super.key,
    required this.amount,
    this.bookingId,
    this.providerId,
    this.providerName,
    this.packageName,
    this.bookingType,
    this.isSubscription = false,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'jeeb';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'jeeb', 'name': 'جيب', 'icon': Icons.account_balance_wallet},
    {'id': 'jawali', 'name': 'جوالي كاش', 'icon': Icons.phone_android},
    {'id': 'floosak', 'name': 'فلوسك', 'icon': Icons.money},
    {'id': 'yemen_wallet', 'name': 'يمن وولت', 'icon': Icons.wallet},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الدفع الإلكتروني'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'قيد التطوير',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة نظام الدفع قريباً',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
