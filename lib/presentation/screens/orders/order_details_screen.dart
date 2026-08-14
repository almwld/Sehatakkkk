import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/order_model.dart';
import 'package:sehatak/core/services/order_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final bool isProvider;
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.isProvider = false,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = true;
  OrderModel? _order;
  String _actionMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    final order = await _orderService.getOrder(widget.orderId);
    setState(() {
      _order = order;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(OrderStatus status, {String? reason}) async {
    await _orderService.updateOrderStatus(
      orderId: widget.orderId,
      status: status,
      cancellationReason: reason,
    );
    await _loadOrder();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم تحديث حالة الطلب'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCancelDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: 'إلغاء الطلب',
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'سبب الإلغاء...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال سبب الإلغاء')),
                );
                return;
              }
              Navigator.pop(_);
              _updateStatus(OrderStatus.cancelled, reason: reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        appBar: CustomAppBar(
          title: 'تفاصيل الطلب',
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('الطلب غير موجود')),
      );
    }

    final order = _order!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'تفاصيل الطلب',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (order.status == OrderStatus.pending)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.white),
              onPressed: _showCancelDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ حالة الطلب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(order.statusIcon, color: order.statusColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة الطلب',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          order.statusText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: order.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ معلومات الطلب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'معلومات الطلب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('رقم الطلب', '#${order.id.substring(0, 8)}'),
                  _buildInfoRow('التاريخ', _formatDate(order.createdAt)),
                  _buildInfoRow('النوع', order.typeText),
                  if (order.providerName != null)
                    _buildInfoRow('المقدم', order.providerName!),
                  if (order.deliveryAddress != null)
                    _buildInfoRow('عنوان التوصيل', order.deliveryAddress!),
                  if (order.deliveryNotes != null)
                    _buildInfoRow('ملاحظات التوصيل', order.deliveryNotes!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ المنتجات
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المنتجات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B1121) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'] ?? 'منتج',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${item['quantity'] ?? 1} × ${item['price'] ?? 0}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ ملخص الدفع
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص الدفع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('المجموع الفرعي', order.subtotal),
                  _buildSummaryRow('رسوم التوصيل', order.deliveryFee),
                  _buildSummaryRow('الضريبة', order.tax),
                  if (order.discount > 0)
                    _buildSummaryRow('الخصم', -order.discount, color: Colors.green),
                  const Divider(),
                  _buildSummaryRow('الإجمالي', order.total, isTotal: true),
                  if (order.paymentMethod != null)
                    _buildSummaryRow('طريقة الدفع', order.paymentMethod!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ أزرار الإجراءات (للمقدمين)
            if (widget.isProvider)
              _buildProviderActions(order),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {Color? color, bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} ريال',
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? AppColors.primary : (isDark ? Colors.white : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderActions(OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    List<Widget> actions = [];

    switch (order.status) {
      case OrderStatus.pending:
        actions = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(OrderStatus.confirmed),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الطلب'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _showCancelDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('رفض'),
            ),
          ),
        ];
        break;
      case OrderStatus.confirmed:
        actions = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(OrderStatus.processing),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('بدء التجهيز'),
            ),
          ),
        ];
        break;
      case OrderStatus.processing:
        actions = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(OrderStatus.shipping),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
              ),
              child: const Text('توصيل'),
            ),
          ),
        ];
        break;
      case OrderStatus.shipping:
        actions = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatus(OrderStatus.delivered),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('تم التوصيل'),
            ),
          ),
        ];
        break;
      default:
        actions = [];
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات الطلب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: actions),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
