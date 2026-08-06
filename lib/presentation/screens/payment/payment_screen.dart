import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/booking_model.dart';

class PaymentScreen extends StatefulWidget {
  final int amount;
  final String? bookingId;
  final String? providerId;
  final String? providerName;
  final BookingType? bookingType;
  final String? packageId;
  final String? packageName;

  const PaymentScreen({
    super.key,
    required this.amount,
    this.bookingId,
    this.providerId,
    this.providerName,
    this.bookingType,
    this.packageId,
    this.packageName,
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

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // ✅ حفظ الدفع
      await FirebaseFirestore.instance.collection('payments').add({
        'userId': user.uid,
        'amount': widget.amount,
        'method': _selectedMethod,
        'bookingId': widget.bookingId,
        'providerId': widget.providerId,
        'providerName': widget.providerName,
        'bookingType': widget.bookingType?.toString().split('.').last,
        'packageId': widget.packageId,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ تحديث حالة الحجز إذا موجود
      if (widget.bookingId != null) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .update({
          'status': 'confirmed',
          'confirmedAt': FieldValue.serverTimestamp(),
        });
      }

      // ✅ إنشاء اشتراك إذا كان باقة
      if (widget.packageId != null) {
        await FirebaseFirestore.instance.collection('user_packages').add({
          'userId': user.uid,
          'packageId': widget.packageId,
          'packageName': widget.packageName,
          'providerId': widget.providerId,
          'isActive': true,
          'remainingMessages': 10,
          'startDate': FieldValue.serverTimestamp(),
          'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم الدفع بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isProcessing = false);
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ تفاصيل الدفع
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  _buildDetailRow('المبلغ', '${widget.amount} ريال'),
                  if (widget.providerName != null)
                    _buildDetailRow('المقدم', widget.providerName!),
                  if (widget.bookingType != null)
                    _buildDetailRow('النوع', _getTypeText(widget.bookingType!)),
                  if (widget.packageName != null)
                    _buildDetailRow('الباقة', widget.packageName!),
                  const Divider(),
                  _buildDetailRow('عمولة المنصة (15%)', '- ${(widget.amount * 0.15).toInt()} ريال', isTotal: true),
                  _buildDetailRow('صافي المقدم', '${(widget.amount * 0.85).toInt()} ريال', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._paymentMethods.map((method) => GestureDetector(
              onTap: () => setState(() => _selectedMethod = method['id']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMethod == method['id'] ? AppColors.primary : Colors.grey,
                    width: _selectedMethod == method['id'] ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(method['icon'], color: _selectedMethod == method['id'] ? AppColors.primary : Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        method['name'],
                        style: TextStyle(
                          fontWeight: _selectedMethod == method['id'] ? FontWeight.bold : FontWeight.normal,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (_selectedMethod == method['id'])
                      const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('تأكيد الدفع (${widget.amount} ريال)'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم خصم 15% عمولة للمنصة، وصافي المبلغ يذهب للمقدم',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
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

  String _getTypeText(BookingType type) {
    switch (type) {
      case BookingType.doctor: return 'طبيب';
      case BookingType.lab: return 'مختبر';
      case BookingType.pharmacy: return 'صيدلية';
      case BookingType.hospital: return 'مستشفى';
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ دعم الاشتراكات
final bool isSubscription;
final String? subscriptionPlanId;
final String? subscriptionPlanName;

// ✅ تحديث الـ constructor
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

// ✅ في _processPayment
if (widget.isSubscription && widget.subscriptionPlanId != null) {
  // إنشاء اشتراك
  await FirebaseFirestore.instance.collection('subscriptions').add({
    'userId': user.uid,
    'plan': widget.subscriptionPlanId,
    'status': 'active',
    'startDate': DateTime.now().toIso8601String(),
    'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    'price': widget.amount,
    'messagesLimit': 30,
    'bookingsLimit': 15,
    'adsLimit': 1,
    'commissionRate': 0.15,
    'features': ['30 رسالة', '15 حجز', '1 إعلان'],
    'isAutoRenew': true,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
