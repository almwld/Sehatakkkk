import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/transaction_model.dart';
import 'package:sehatak/core/services/payment_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedFilter = 'الكل';
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];

  final List<String> _filters = ['الكل', 'مكتمل', 'قيد المعالجة', 'فشل', 'مسترد'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final stream = _paymentService.getUserTransactions(user.uid);
    stream.listen((transactions) {
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    });
  }

  List<TransactionModel> get _filteredTransactions {
    if (_selectedFilter == 'الكل') return _transactions;
    
    switch (_selectedFilter) {
      case 'مكتمل':
        return _transactions.where((t) => t.status == TransactionStatus.completed).toList();
      case 'قيد المعالجة':
        return _transactions.where((t) => t.status == TransactionStatus.processing || 
                                        t.status == TransactionStatus.pending).toList();
      case 'فشل':
        return _transactions.where((t) => t.status == TransactionStatus.failed).toList();
      case 'مسترد':
        return _transactions.where((t) => t.status == TransactionStatus.refunded).toList();
      default:
        return _transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'سجل المعاملات',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ مرشحات
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // ✅ قائمة المعاملات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: isDark ? Colors.grey[600] : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد معاملات',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ستظهر المعاملات هنا عند إجراء أي عملية دفع',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          return _buildTransactionCard(transaction);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        border: Border.all(
          color: transaction.statusColor.withOpacity(0.3),
          width: transaction.status == TransactionStatus.failed ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // ✅ الأيقونة
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.typeIcon.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.typeIcon,
              color: transaction.typeIcon.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // ✅ التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.typeText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: transaction.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.statusText,
                        style: TextStyle(
                          fontSize: 8,
                          color: transaction.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.description ?? 'عملية دفع',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      transaction.methodText,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(transaction.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ المبلغ
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.amount.toStringAsFixed(0)} ريال',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: transaction.status == TransactionStatus.completed
                      ? Colors.green
                      : transaction.status == TransactionStatus.failed
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
              if (transaction.platformFee > 0)
                Text(
                  'العمولة: ${transaction.platformFee.toStringAsFixed(0)} ريال',
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
