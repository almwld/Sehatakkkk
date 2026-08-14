import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/payment_service.dart';
import 'package:sehatak/presentation/screens/payment/payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double total;
  final String address;
  final String notes;
  final String deliveryMethod;

  const PaymentScreen({
    super.key,
    required this.total,
    required this.address,
    required this.notes,
    this.deliveryMethod = 'sehatak',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'wallet';
  bool _isLoading = false;
  double _walletBalance = 0.0;
  bool _hasEnoughBalance = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'wallet', 'name': 'المحفظة الرقمية', 'icon': Icons.account_balance_wallet, 'color': AppColors.primary},
    {'id': 'cash', 'name': 'الدفع عند الاستلام', 'icon': Icons.money, 'color': Colors.green},
    {'id': 'card', 'name': 'بطاقة ائتمان', 'icon': Icons.credit_card, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final balance = await PaymentService.getWalletBalance(user.uid);
        setState(() {
          _walletBalance = balance;
          _hasEnoughBalance = balance >= widget.total;
        });
      }
    } catch (e) {}
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ يرجى تسجيل الدخول أولاً'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (_selectedPaymentMethod == 'wallet') {
        if (!_hasEnoughBalance) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ رصيد غير كافٍ. الرصيد الحالي: $_walletBalance ر.ي'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        final result = await PaymentService.processPayment(
          userId: user.uid,
          amount: widget.total,
          orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
          notes: widget.notes,
        );

        if (result['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(
                amount: widget.total,
                orderId: result['orderId'],
                paymentMethod: 'المحفظة الرقمية',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${result['message']}'), backgroundColor: Colors.red),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              amount: widget.total,
              orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
              paymentMethod: _selectedPaymentMethod == 'cash' ? 'الدفع عند الاستلام' : 'بطاقة ائتمان',
              isCash: _selectedPaymentMethod == 'cash',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('طريقة الدفع'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('إجمالي المبلغ', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.total.toStringAsFixed(0)} ر.ي',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('رصيد المحفظة', style: TextStyle(fontSize: 14, color: Colors.grey)),
                              Text(
                                '${_walletBalance.toStringAsFixed(0)} ر.ي',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _hasEnoughBalance ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _hasEnoughBalance ? '✅ كافٍ' : '❌ غير كافٍ',
                            style: TextStyle(fontSize: 11, color: _hasEnoughBalance ? Colors.green : Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map((method) {
                    final isSelected = _selectedPaymentMethod == method['id'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2540) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!), width: isSelected ? 2 : 1),
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPaymentMethod = method['id'] as String),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: (method['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(method['icon'] as IconData, color: method['color'] as Color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                method['name'] as String,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            Radio<String>(
                              value: method['id'] as String,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('إتمام الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text('${widget.total.toStringAsFixed(0)} ر.ي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
