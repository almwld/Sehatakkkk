import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final TransactionModel transaction;

  const PaymentSuccessScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'إيصال الدفع',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تمت العملية بنجاح',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.title,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  _buildReceiptRow(
                    'رقم المعاملة',
                    transaction.id.substring(0, 8),
                    isDark,
                  ),
                  const Divider(height: 24),
                  _buildReceiptRow(
                    'المبلغ المدفوع',
                    '${NumberFormat('#,##0.00', 'ar').format(transaction.amount)} ر.ي',
                    isDark,
                    isBold: true,
                  ),
                  const Divider(height: 24),
                  _buildReceiptRow(
                    'نوع العملية',
                    transaction.typeText,
                    isDark,
                  ),
                  const Divider(height: 24),
                  _buildReceiptRow(
                    'تاريخ العملية',
                    DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(
                      transaction.createdAt,
                    ),
                    isDark,
                  ),
                  if (transaction.referenceNumber != null) ...[
                    const Divider(height: 24),
                    _buildReceiptRow(
                      'رقم الإشعار',
                      transaction.referenceNumber!,
                      isDark,
                    ),
                  ],
                  if (transaction.walletName != null) ...[
                    const Divider(height: 24),
                    _buildReceiptRow(
                      'المحفظة المستخدمة',
                      transaction.walletName!,
                      isDark,
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'العودة للرئيسية',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
