import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String serviceType;
  final String serviceId;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.serviceType,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedWallet = 'فلوسك';
  final TextEditingController _walletNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // المبلغ
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المبلغ:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.amount} ريال',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // اختيار المحفظة
            const Text(
              'اختر المحفظة:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedWallet,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.wallet),
              ),
              items: PaymentService.supportedWallets.map((wallet) {
                return DropdownMenuItem(
                  value: wallet,
                  child: Text(wallet),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWallet = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // رقم المحفظة
            const Text(
              'رقم المحفظة:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _walletNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'أدخل رقم المحفظة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const Spacer(),

            // زر الدفع
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'دفع الآن',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_walletNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم المحفظة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final service = PaymentService();
    final result = await service.processPayment(
      userId: 'user_123', // سيتم جلبها من Auth
      amount: widget.amount,
      serviceType: widget.serviceType,
      serviceId: widget.serviceId,
      paymentMethod: _selectedWallet,
      walletNumber: _walletNumberController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم الدفع بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
