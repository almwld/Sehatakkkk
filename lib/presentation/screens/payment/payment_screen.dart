import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/cart/cart_model.dart';
import 'package:sehatak/core/services/payment_service.dart';
import 'package:sehatak/core/models/transaction_model.dart';
import 'package:sehatak/presentation/screens/payment/payment_confirmation.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> items;
  final CartSummary summary;

  const PaymentScreen({
    super.key,
    required this.items,
    required this.summary,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedMethod = 'جيب';
  bool _isLoading = false;
  double _balance = 0;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _walletNumberController = TextEditingController();

  final List<String> _paymentMethods = [
    'جيب',
    'فلوسك',
    'جوالي كاش',
    'ون كاش',
    'كاش',
    'سبأ كاش',
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await _paymentService.getWalletBalance('current_user');
    setState(() => _balance = balance);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('💳 إتمام الدفع'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(isDark),
                  const SizedBox(height: 16),
                  _buildPaymentDetails(isDark),
                  const SizedBox(height: 16),
                  _buildPaymentMethods(isDark),
                  const SizedBox(height: 24),
                  _buildSubmitButton(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('ملخص الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 16),
          _buildSummaryRow('عدد المنتجات', '${widget.summary.itemCount} منتج', isDark),
          _buildSummaryRow('المجموع الفرعي', '${widget.summary.subtotal.toStringAsFixed(0)} ريال', isDark),
          if (widget.summary.totalDiscount > 0)
            _buildSummaryRow('الخصم', '-${widget.summary.totalDiscount.toStringAsFixed(0)} ريال', isDark, color: Colors.green),
          _buildSummaryRow('رسوم التوصيل', '${widget.summary.deliveryFee.toStringAsFixed(0)} ريال', isDark),
          _buildSummaryRow('الضريبة', '${widget.summary.tax.toStringAsFixed(0)} ريال', isDark),
          const Divider(height: 16),
          _buildSummaryRow('الإجمالي', '${widget.summary.total.toStringAsFixed(0)} ريال', isDark, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
          )),
          Text(value, style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isTotal ? AppColors.primary : (isDark ? Colors.white : Colors.black87)),
          )),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('تفاصيل الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textAlign: TextAlign.right,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              hintText: 'أدخل رقم الهاتف المسجل',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _walletNumberController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              labelText: 'رقم المحفظة (${_selectedMethod})',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: const OutlineInputBorder(),
              hintText: 'أدخل رقم محفظتك في ${_selectedMethod}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wallet, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('طريقة الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('رصيد المحفظة: ${_balance.toStringAsFixed(0)} ريال',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/wallet'),
                  child: const Text('شحن'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _paymentMethods.map((method) {
              final isSelected = _selectedMethod == method;
              return ChoiceChip(
                label: Text(method, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedMethod = method),
                selectedColor: AppColors.primary,
                backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[200],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('رمز نقطة الدفع: ${_paymentService.merchantCode}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                      ),
                      Text('التحويل على حساب منصة صحتك الطبية - جيب',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle),
            const SizedBox(width: 8),
            Text('إتمام الطلب - ${widget.summary.total.toStringAsFixed(0)} ريال',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_walletNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم المحفظة'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_balance < widget.summary.total) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('⚠️ رصيد غير كافٍ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الرصيد الحالي: ${_balance.toStringAsFixed(0)} ريال'),
              Text('المبلغ المطلوب: ${widget.summary.total.toStringAsFixed(0)} ريال'),
              const SizedBox(height: 12),
              const Text('يرجى شحن المحفظة لإكمال الدفع'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/wallet');
              },
              child: const Text('شحن المحفظة'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _paymentService.processPayment(
        userId: 'current_user',
        amount: widget.summary.total,
        type: TransactionType.payment,
        method: PaymentMethod.wallet,
        description: 'طلب سلة مشتريات',
      );

      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationScreen(
            success: true,
            transactionId: result['id'],
            amount: widget.summary.total,
            message: 'تم دفع ${widget.summary.total.toStringAsFixed(0)} ريال بنجاح',
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
