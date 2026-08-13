import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/delivery/delivery_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  double _balance = 1250.50;
  bool _isLoading = false;
  String _selectedTab = 'all';
  late TabController _tabController;

  final List<Map<String, dynamic>> _transactions = [
    {'id': '1', 'type': 'income', 'amount': 500.0, 'description': 'إيداع من جيب', 'date': '2026-07-19', 'status': 'completed', 'icon': Icons.arrow_downward, 'color': Colors.green},
    {'id': '2', 'type': 'expense', 'amount': -250.0, 'description': 'دفع استشارة طبية', 'date': '2026-07-18', 'status': 'completed', 'icon': Icons.arrow_upward, 'color': Colors.red},
    {'id': '3', 'type': 'income', 'amount': 1000.0, 'description': 'إيداع من جوالي كاش', 'date': '2026-07-17', 'status': 'completed', 'icon': Icons.arrow_downward, 'color': Colors.green},
    {'id': '4', 'type': 'expense', 'amount': -150.0, 'description': 'شراء دواء', 'date': '2026-07-16', 'status': 'pending', 'icon': Icons.arrow_upward, 'color': Colors.orange},
    {'id': '5', 'type': 'income', 'amount': 200.0, 'description': 'استرداد مبلغ', 'date': '2026-07-15', 'status': 'completed', 'icon': Icons.arrow_downward, 'color': Colors.green},
    {'id': '6', 'type': 'expense', 'amount': -75.0, 'description': 'رسوم توصيل', 'date': '2026-07-14', 'status': 'completed', 'icon': Icons.arrow_upward, 'color': Colors.red},
    {'id': '7', 'type': 'income', 'amount': 300.0, 'description': 'مكافأة إحالة', 'date': '2026-07-13', 'status': 'completed', 'icon': Icons.arrow_downward, 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'jeeb', 'name': 'جيب', 'icon': 'assets/icons/payment/جيب_icon.png', 'color': AppColors.warning},
    {'id': 'jawali', 'name': 'جوالي كاش', 'icon': 'assets/icons/payment/Jawali_icon.png', 'color': AppColors.info},
    {'id': 'alkarimi', 'name': 'الكريمي جوال', 'icon': 'assets/icons/payment/الكريمي جوال_icon.png', 'color': AppColors.pink},
    {'id': 'floosak', 'name': 'فلوسك', 'icon': 'assets/icons/payment/floosak_icon.png', 'color': AppColors.primary},
    {'id': 'cash', 'name': 'كاش', 'icon': 'assets/icons/payment/كاش_icon.png', 'color': AppColors.success},
    {'id': 'easy', 'name': 'إيزي', 'icon': 'assets/icons/payment/ايزي_icon.png', 'color': AppColors.purple},
    {'id': 'yemen_wallet', 'name': 'يمن وولت', 'icon': 'assets/icons/payment/Yemen Wallet_icon.png', 'color': AppColors.teal},
    {'id': 'cash_one', 'name': 'كاش ONE', 'icon': 'assets/icons/payment/كاش ONE_icon.png', 'color': AppColors.indigo},
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {'icon': Icons.add_card, 'label': 'إيداع', 'color': AppColors.success},
    {'icon': Icons.send, 'label': 'تحويل', 'color': AppColors.primary},
    {'icon': Icons.receipt, 'label': 'الطلبات', 'color': AppColors.warning},
    {'icon': Icons.history, 'label': 'السجل', 'color': AppColors.info},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedTab == 'all') return _transactions;
    if (_selectedTab == 'income') {
      return _transactions.where((t) => t['type'] == 'income').toList();
    }
    return _transactions.where((t) => t['type'] == 'expense').toList();
  }

  double get _totalIncome {
    return _transactions.where((t) => t['type'] == 'income').fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  double get _totalExpense {
    return _transactions.where((t) => t['type'] == 'expense').fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المحفظة'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ✅ بطاقة الرصيد المحسنة
              _buildBalanceCard(isDark, primaryColor),
              const SizedBox(height: 20),

              // ✅ الإجراءات السريعة
              _buildQuickActions(isDark),
              const SizedBox(height: 20),

              // ✅ طرق الدفع
              _buildPaymentMethods(isDark),
              const SizedBox(height: 20),

              // ✅ تبويب المعاملات
              _buildTransactionsTabs(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D5257), Color(0xFF1A7A80)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.white70, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'إظهار',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_balance.toStringAsFixed(2)}',
                style: TextStyle(
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
              _buildStatChip('إيداعات', _totalIncome, Colors.green),
              const SizedBox(width: 8),
              _buildStatChip('مصروفات', _totalExpense.abs(), Colors.red),
              const SizedBox(width: 8),
              _buildStatChip('معاملات', _transactions.length.toDouble(), Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          Text(
            '${value.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _quickActions.map((action) {
          final color = action['color'] as Color;
          return GestureDetector(
            onTap: () {
              if (action['label'] == 'الطلبات') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeliveryScreen()),
                );
              } else if (action['label'] == 'إيداع') {
                _showAddMoneyDialog();
              } else if (action['label'] == 'السجل') {
                // التمرير إلى قسم المعاملات
                _tabController.animateTo(2);
              }
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طرق الدفع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final color = method['color'] as Color;
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        method['icon'],
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => Icon(Icons.wallet, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        method['name'],
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTabs(bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المعاملات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'إيداعات'),
              Tab(text: 'مصروفات'),
            ],
            onTap: (index) {
              setState(() {
                _selectedTab = index == 0 ? 'all' : index == 1 ? 'income' : 'expense';
              });
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: _filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'لا توجد معاملات',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionItem(transaction, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, bool isDark) {
    final isIncome = transaction['type'] == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final amount = transaction['amount'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  transaction['date'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : ''}${amount.abs().toStringAsFixed(2)} ر.ي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: transaction['status'] == 'completed'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  transaction['status'] == 'completed' ? 'مكتمل' : 'قيد الانتظار',
                  style: TextStyle(
                    fontSize: 9,
                    color: transaction['status'] == 'completed' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog() {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'jeeb';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'إضافة رصيد',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // ✅ خيارات المبالغ
              Row(
                children: [
                  Expanded(child: _buildAmountOption(50, setState)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAmountOption(100, setState)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAmountOption(200, setState)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildAmountOption(500, setState)),
                ],
              ),
              const SizedBox(height: 16),
              // ✅ حقل الإدخال
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  hintText: 'أو أدخل مبلغاً آخر',
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // ✅ اختيار طريقة الدفع
              const Text(
                'اختر طريقة الدفع',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods.take(4).map((method) {
                  final isSelected = selectedMethod == method['id'];
                  final color = method['color'] as Color;
                  return GestureDetector(
                    onTap: () => setState(() => selectedMethod = method['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            method['icon'],
                            width: 20,
                            height: 20,
                            errorBuilder: (_, __, ___) => Icon(Icons.wallet, color: color, size: 20),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            method['name'],
                            style: TextStyle(
                              color: isSelected ? color : Colors.grey,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى إدخال مبلغ صحيح'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _balance += amount;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ تم إضافة ${amount.toStringAsFixed(0)} ر.ي إلى المحفظة'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  child: const Text(
                    'إضافة الرصيد',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountOption(int amount, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        // يمكن إضافة منطق لملء الحقل
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'ر.ي',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }
}
