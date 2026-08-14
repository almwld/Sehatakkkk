import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/wallet_service.dart';
import 'package:sehatak/presentation/screens/payment/payment_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WalletService _walletService = WalletService();
  bool _isLoading = true;
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic> _stats = {};
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'إيداع', 'دفع', 'استرداد'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      _balance = await _walletService.getBalance(user.uid);
      _transactions = await _walletService.getTransactions(user.uid);
      _stats = await _walletService.getStats(user.uid);
    } catch (e) {
      print('Error loading wallet: $e');
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'الكل') return _transactions;
    return _transactions.where((t) => t['type'] == _selectedFilter).toList();
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    String selectedWallet = 'جيب';
    final walletNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: '💳 شحن المحفظة',
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ نص توضيحي
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'قم بشحن محفظتك باستخدام إحدى المحافظ الإلكترونية المدعومة',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              // ✅ المبلغ
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'المبلغ (ريال)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // ✅ اختيار المحفظة
              DropdownButtonFormField<String>(
                value: selectedWallet,
                decoration: const InputDecoration(
                  labelText: 'اختر المحفظة',
                  prefixIcon: Icon(Icons.wallet),
                  border: OutlineInputBorder(),
                ),
                items: WalletService.supportedWallets.map((wallet) {
                  return DropdownMenuItem(value: wallet, child: Text(wallet));
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedWallet = value;
                },
              ),
              const SizedBox(height: 12),
              // ✅ رقم المحفظة
              TextField(
                controller: walletNumberController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'رقم المحفظة',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // ✅ معلومات نقطة الدفع
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 معلومات الدفع',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('🔑 رقم النقطة: ', style: TextStyle(fontSize: 12)),
                        Text(
                          WalletService.merchantCode,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '⚠️ سيتم تحويل المبلغ إلى حساب المنصة الرئيسي',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
                );
                return;
              }

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الرجاء تسجيل الدخول')),
                );
                return;
              }

              // ✅ تنفيذ الشحن
              final result = await _walletService.deposit(
                userId: user.uid,
                amount: amount,
                walletNumber: walletNumberController.text,
                walletType: selectedWallet,
              );

              if (result['success'] == true) {
                await _loadWalletData();
                Navigator.pop(_);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ تم شحن ${amount.toStringAsFixed(0)} ريال بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ فشل الشحن: ${result['error']}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('شحن المحفظة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'محفظتي',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ بطاقة الرصيد
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الرصيد الحالي',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'نشط ✅',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${_balance.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'ر.ي',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatChip('الإيداعات', '${_stats['totalDeposited']?.toStringAsFixed(0) ?? 0}', Colors.green),
                          const SizedBox(width: 8),
                          _buildStatChip('المصروفات', '${_stats['totalSpent']?.toStringAsFixed(0) ?? 0}', Colors.red),
                          const SizedBox(width: 8),
                          _buildStatChip('المكافآت', '${_stats['totalEarned']?.toStringAsFixed(0) ?? 0}', Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showDepositDialog,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'شحن المحفظة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ المحافظ المدعومة
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2540) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المحافظ المدعومة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: WalletService.supportedWallets.map((wallet) {
                          return Chip(
                            label: Text(wallet, style: const TextStyle(fontSize: 10)),
                            backgroundColor: AppColors.primary.withOpacity(0.08),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ سجل المعاملات
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        // ✅ الفلاتر
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filters.map((filter) {
                                final isSelected = _selectedFilter == filter;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedFilter = filter),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? Colors.transparent : Colors.grey,
                                      ),
                                    ),
                                    child: Text(
                                      filter,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        // ✅ المعاملات
                        Expanded(
                          child: _filteredTransactions.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'لا توجد معاملات',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'قم بشحن محفظتك لبدء المعاملات',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _filteredTransactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = _filteredTransactions[index];
                                    return _buildTransactionItem(transaction, isDark);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, bool isDark) {
    final isDeposit = transaction['type'] == 'deposit';
    final isPayment = transaction['type'] == 'payment';
    final isRefund = transaction['type'] == 'refund';
    final isCredit = isDeposit || isRefund;

    IconData icon;
    Color color;
    String label;

    if (isDeposit) {
      icon = Icons.arrow_downward;
      color = Colors.green;
      label = 'إيداع';
    } else if (isPayment) {
      icon = Icons.payment;
      color = Colors.blue;
      label = 'دفع';
    } else if (isRefund) {
      icon = Icons.refresh;
      color = Colors.purple;
      label = 'استرداد';
    } else {
      icon = Icons.history;
      color = Colors.grey;
      label = 'معاملة';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'] ?? label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _formatDate(transaction['createdAt']),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? "+" : "-"}${transaction['amount']} ريال',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              if (transaction['fee'] != null)
                Text(
                  'العمولة: ${transaction['fee']} ريال',
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
