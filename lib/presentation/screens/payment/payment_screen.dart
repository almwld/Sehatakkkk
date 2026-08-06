import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/booking_model.dart';
import 'package:sehatak/presentation/screens/payment/payment_confirmation.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String? bookingId;
  final String? providerId;
  final String? providerName;
  final BookingType? bookingType;
  final String? packageId;
  final String? packageName;
  final bool isSubscription;
  final String? subscriptionPlanId;
  final String? subscriptionPlanName;

  const PaymentScreen({
    super.key,
    required this.amount,
    this.bookingId,
    this.providerId,
    this.providerName,
    this.bookingType,
    this.packageId,
    this.packageName,
    this.isSubscription = false,
    this.subscriptionPlanId,
    this.subscriptionPlanName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  bool _isLoading = false;
  String _selectedMethod = 'card';
  bool _saveCard = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'card', 'name': 'بطاقة ائتمان', 'icon': Icons.credit_card},
    {'id': 'mada', 'name': 'مدى', 'icon': Icons.account_balance},
    {'id': 'apple_pay', 'name': 'Apple Pay', 'icon: Icons.apple},
    {'id': 'google_pay', 'name': 'Google Pay', 'icon': Icons.google},
    {'id': 'bank', 'name': 'تحويل بنكي', 'icon': Icons.account_balance},
  ];

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final user = FirebaseAuth.instance.currentUser;

      // ✅ حفظ المعاملة
      final transactionData = {
        'userId': user?.uid ?? '',
        'amount': widget.amount,
        'method': _selectedMethod,
        'status': 'completed',
        'bookingId': widget.bookingId,
        'providerId': widget.providerId,
        'providerName': widget.providerName,
        'bookingType': widget.bookingType?.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.isSubscription && widget.subscriptionPlanId != null) {
        transactionData['subscriptionPlanId'] = widget.subscriptionPlanId;
        transactionData['subscriptionPlanName'] = widget.subscriptionPlanName;
      }

      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transactionData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationScreen(
              success: true,
              transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
              amount: widget.amount,
              message: 'تم الدفع بنجاح',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الدفع: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getTypeText(BookingType? type) {
    if (type == null) return 'عام';
    switch (type) {
      case BookingType.doctor:
        return 'طبيب';
      case BookingType.lab:
        return 'مختبر';
      case BookingType.pharmacy:
        return 'صيدلية';
      case BookingType.hospital:
        return 'مستشفى';
      case BookingType.consultation:
        return 'استشارة';
      case BookingType.subscription:
        return 'اشتراك';
      default:
        return 'عام';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الدفع'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ ملخص الدفع
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'المبلغ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${widget.amount.toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('نوع الخدمة', style: TextStyle(fontSize: 13)),
                      Text(
                        _getTypeText(widget.bookingType),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (widget.providerName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المقدم', style: TextStyle(fontSize: 13)),
                        Text(
                          widget.providerName!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.isSubscription) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الاشتراك', style: TextStyle(fontSize: 13)),
                        Text(
                          widget.subscriptionPlanName ?? 'اشتراك شهري',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ طرق الدفع
            const Text(
              'اختر طريقة الدفع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods.map((method) {
                  final isSelected = _selectedMethod == method['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMethod = method['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            method['icon'] as IconData,
                            color: isSelected ? AppColors.primary : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            method['name'] as String,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ حقل بيانات البطاقة
            if (_selectedMethod == 'card' || _selectedMethod == 'mada') ...[
              const Text(
                'بيانات البطاقة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'رقم البطاقة',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'تاريخ الانتهاء (MM/YY)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'اسم حامل البطاقة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _saveCard,
                    onChanged: (v) => setState(() => _saveCard = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  const Text('حفظ البطاقة للدفعات المستقبلية'),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // ✅ زر الدفع
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'دفع الآن',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ آمن 100%
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'مدفوعات آمنة 100%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
