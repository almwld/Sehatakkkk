import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/core/services/payment_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/payment/payment_success_screen.dart';
import 'package:sehatak/presentation/screens/wallet/top_up_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class PaymentInvoiceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String invoiceTitle;
  final String? orderId;

  const PaymentInvoiceScreen({
    super.key,
    required this.items,
    this.invoiceTitle = 'فاتورة خدمات طبية',
    this.orderId,
  });

  @override
  State<PaymentInvoiceScreen> createState() => _PaymentInvoiceScreenState();
}

class _PaymentInvoiceScreenState extends State<PaymentInvoiceScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  double get totalAmount {
    double sum = 0.0;
    for (var item in widget.items) {
      final price = ((item['price'] ?? 0) as num).toDouble();
      final qty = ((item['qty'] ?? 1) as num).toInt();
      sum += price * qty;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: widget.invoiceTitle,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<WalletModel>(
        stream: _paymentService.getWalletStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('حدث خطأ: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final balance = snapshot.data?.balance ?? 0.0;
          final canPay = balance >= totalAmount;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        'تفاصيل الفاتورة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.items.map((item) {
                        final price = ((item['price'] ?? 0) as num).toDouble();
                        final qty = ((item['qty'] ?? 1) as num).toInt();
                        return ListTile(
                          title: Text(
                            item['title'] ?? 'منتج/خدمة',
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          ),
                          subtitle: Text(
                            'الكمية: $qty',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            '${(price * qty).toStringAsFixed(2)} ر.ي',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      }),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'الإجمالي الكلي',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: Text(
                          '${NumberFormat('#,##0.00', 'ar').format(totalAmount)} ر.ي',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // عرض الرصيد وحالة الدفع
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.cardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: canPay ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'رصيد المحفظة الحالي:',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${balance.toStringAsFixed(2)} ر.ي',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: canPay ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (!canPay)
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TopUpScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[800],
                                ),
                                child: const Text(
                                  'تغذية الرصيد',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // زر الدفع
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isProcessing || !canPay) ? null : _executePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            canPay ? 'خصم من المحفظة وتأكيد الدفع' : 'الرصيد غير كافٍ',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _executePayment() async {
    setState(() => _isProcessing = true);

    try {
      final transaction = await _paymentService.processPayment(
        amount: totalAmount,
        title: widget.invoiceTitle,
        description: 'دفعة سداد خدمات عبر المحفظة الرقمية',
        orderId: widget.orderId ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
        metadata: {
          'items': widget.items,
          'totalAmount': totalAmount,
        },
      );

      if (mounted) {
        ToastService.showSuccess(
          context,
          'تم الدفع بنجاح بقيمة ${totalAmount.toStringAsFixed(0)} ر.ي',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              transaction: transaction,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('خطأ في عملية الدفع: $e');
        setState(() => _isProcessing = false);
      }
    }
  }
}
