import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/theme/app_theme.dart';

class PaymentInvoiceScreen extends StatefulWidget {
  const PaymentInvoiceScreen({super.key});

  @override
  State<PaymentInvoiceScreen> createState() => _PaymentInvoiceScreenState();
}

class _PaymentInvoiceScreenState extends State<PaymentInvoiceScreen> {
  String _selectedGateway = 'kuraimi';
  bool _isProcessing = false;

  // بوابات الدفع المحلية
  final List<Map<String, String>> _gateways = [
    {'id': 'kuraimi', 'name': 'ام فلوس / الكريمي', 'type': 'حساب بنكي محلي', 'icon': '🏦'},
    {'id': 'floosak', 'name': 'محفظة فلوسك', 'type': 'شركة الخدمات المصرفية', 'icon': '💳'},
    {'id': 'jawali', 'name': 'محفظة جوالي', 'type': 'بوابة دفع إلكترونية', 'icon': '📱'},
    {'id': 'cash', 'name': 'محفظة كاش', 'type': 'خدمات نقدية رقمية', 'icon': '💰'},
    {'id': 'yemen_wallet', 'name': 'يمن وولت', 'type': 'محفظة وطنية موحدة', 'icon': '🇾🇪'},
  ];

  // بيانات الفاتورة
  final List<Map<String, dynamic>> _cartItems = [
    {'name': 'بار.ييتامول 500mg', 'qty': 2, 'price': 150},
    {'name': 'فيتامين د 1000IU', 'qty': 1, 'price': 300},
    {'name': 'جهاز قياس ضغط', 'qty': 1, 'price': 1200},
  ];

  double get _subtotal {
    double sum = 0;
    for (var item in _cartItems) {
      sum += (item['price'] as int) * (item['qty'] as int);
    }
    return sum;
  }

  double get _deliveryFee => 50;
  double get _total => _subtotal + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1121) : AppTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0.5,
        title: const Text(
          'تأكيد الطلب',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      body: Column(
        children: [
          // المحتوى القابل للتمرير
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الفاتورة
                  const Text(
                    'تفاصيل الفاتورة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // قائمة المنتجات
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: _cartItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${item['qty']} × ${item['price']}',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // تفاصيل التوصيل والدفع
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryRow('المجموع الفرعي', '${_subtotal.toStringAsFixed(0)} ر.ي'),
                          _buildSummaryRow('رسوم التوصيل', '${_deliveryFee.toStringAsFixed(0)} ر.ي'),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            'الإجمالي',
                            '${_total.toStringAsFixed(0)} ر.ي',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // عنوان بوابات الدفع
                  const Text(
                    'اختر طريقة الدفع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // قائمة بوابات الدفع العمودية
                  ..._gateways.map((gateway) {
                    final isSelected = _selectedGateway == gateway['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGateway = gateway['id']!;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2540) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : (isDark ? Colors.grey! : AppTheme.cardBorderColor),
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              gateway['icon']!,
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gateway['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? Colors.white : AppTheme.primaryColor,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  Text(
                                    gateway['type']!,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey : Colors.grey,
                                      fontSize: 11,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: gateway['id']!,
                              groupValue: _selectedGateway,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGateway = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // زر التأكيد الثابت
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () {
                    setState(() => _isProcessing = true);
                    // محاكاة معالجة الدفع
                    Future.delayed(const Duration(seconds: 2), () {
                      setState(() => _isProcessing = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم تأكيد الطلب بنجاح!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'تأكيد الطلب ودفع',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_total.toStringAsFixed(0)} ر.ي',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.primaryColor : null,
              fontFamily: 'Tajawal',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.primaryColor : null,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
