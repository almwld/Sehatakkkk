import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/services/payment_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class PaymentInvoiceScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final String paymentMethod;
  final String invoiceTitle;
  final List<Map<String, dynamic>>? items;

  const PaymentInvoiceScreen({super.key, required this.amount, required this.orderId, required this.paymentMethod, this.invoiceTitle = 'فاتورة خدمات طبية', this.items});

  @override
  State<PaymentInvoiceScreen> createState() => _PaymentInvoiceScreenState();
}

class _PaymentInvoiceScreenState extends State<PaymentInvoiceScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  String _t(String value) => AppStrings.of(context).translate(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t(widget.invoiceTitle)), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_t('تفاصيل الفاتورة'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildRow(_t('رقم الطلب'), widget.orderId),
            _buildRow(_t('طريقة الدفع'), widget.paymentMethod),
            if (widget.items != null && widget.items!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_t('المنتجات:'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ...widget.items!.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text('${item['name'] ?? _t('منتج')}')), Text(AppStrings.of(context).formatCurrency(item['price'] is num ? item['price'] as num : num.tryParse('${item['price']}') ?? 0))]))),
            ],
            const Divider(),
            _buildRow(_t('المبلغ الإجمالي'), AppStrings.of(context).formatCurrency(widget.amount), isBold: true),
          ]))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _isLoading ? null : _processPayment,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_t('تأكيد الدفع'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 10),
          Text(_t('يتم تنفيذ الخصم وتسجيل المعاملة بشكل ذري وآمن عبر النظام الموثوق.'), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])), Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))) ]),
  );

  Future<void> _processPayment() async {
    if (widget.amount <= 0) { ToastService.showError(_t('المبلغ غير صالح')); return; }
    setState(() => _isLoading = true);
    try {
      final transaction = await _paymentService.processPayment(
        amount: widget.amount,
        title: widget.invoiceTitle,
        description: '${_t('دفع للطلب')} ${widget.orderId}',
        orderId: widget.orderId,
        serviceType: widget.paymentMethod,
        metadata: {'paymentMethod': widget.paymentMethod},
        idempotencyKey: widget.orderId.isNotEmpty ? 'order_${widget.orderId}' : null,
      );
      if (!mounted) return;
      ToastService.showSuccess('${_t('تم الدفع بنجاح — رقم المعاملة:')} ${transaction.id}');
      Navigator.pop(context, transaction.id);
    } catch (e) {
      if (!mounted) return;
      ToastService.showError('${_t('تعذر إتمام الدفع:')} $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
