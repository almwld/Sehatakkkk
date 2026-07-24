import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/wallet_model.dart';
import 'package:sehatak/presentation/screens/payment/payment_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WalletModel? _wallet;
  List<WalletTransactionModel> _transactions = [];
  bool _isLoading = true;
  double _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // ✅ جلب المحفظة
      final walletSnap = await FirebaseFirestore.instance
          .collection('wallets')
          .doc(user.uid)
          .get();

      if (walletSnap.exists) {
        _wallet = WalletModel.fromFirestore(walletSnap.data() as Map<String, dynamic>, walletSnap.id);
      } else {
        // ✅ إنشاء محفظة جديدة
        final newWallet = WalletModel(
          id: user.uid,
          userId: user.uid,
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('wallets')
            .doc(user.uid)
            .set(newWallet.toFirestore());
        _wallet = newWallet;
      }

      // ✅ جلب المعاملات
      final transactionsSnap = await FirebaseFirestore.instance
          .collection('wallet_transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _transactions = transactionsSnap.docs.map((doc) {
        return WalletTransactionModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      _totalBalance = _wallet?.balance ?? 0;

    } catch (e) {
      print('Error loading wallet: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المحفظة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWallet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ بطاقة الرصيد
                _buildBalanceCard(isDark),
                // ✅ الأزرار السريعة
                _buildQuickActions(isDark),
                // ✅ تبويبات
                Container(
                  color: isDark ? const Color(0xFF0B1121) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.grey,
                    tabs: const [
                      Tab(text: 'المعاملات'),
                      Tab(text: 'الإحصائيات'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionsTab(),
                      _buildStatisticsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Container(
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
          const Text(
            'الرصيد الحالي',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${_totalBalance.toStringAsFixed(0)}',
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
              _buildBalanceStat('الإيداعات', '${_wallet?.totalDeposited ?? 0}', Colors.green),
              const SizedBox(width: 16),
              _buildBalanceStat('المصروفات', '${_wallet?.totalSpent ?? 0}', Colors.red),
              const SizedBox(width: 16),
              _buildBalanceStat('المكافآت', '${_wallet?.totalEarned ?? 0}', Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildActionButton('إيداع', Icons.add, Colors.green, () {
            // TODO: شاشة الإيداع
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('جاري فتح شاشة الإيداع...'),
                backgroundColor: Colors.blue,
              ),
            );
          }),
          const SizedBox(width: 12),
          _buildActionButton('سحب', Icons.arrow_upward, Colors.red, () {
            // TODO: شاشة السحب
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('جاري فتح شاشة السحب...'),
                backgroundColor: Colors.blue,
              ),
            );
          }),
          const SizedBox(width: 12),
          _buildActionButton('تحويل', Icons.send, Colors.blue, () {
            // TODO: شاشة التحويل
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('جاري فتح شاشة التحويل...'),
                backgroundColor: Colors.blue,
              ),
            );
          }),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton('كشف الحساب', Icons.receipt, Colors.purple, () {
              // TODO: شاشة كشف الحساب
            }, isFull: true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap,
      {bool isFull = false}) {
    return Flexible(
      flex: isFull ? 2 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد معاملات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ باستخدام محفظتك الآن',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(WalletTransactionModel transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = transaction.type == WalletTransactionType.deposit ||
        transaction.type == WalletTransactionType.refund ||
        transaction.type == WalletTransactionType.bonus;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.typeIcon,
              color: transaction.typeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                  transaction.description ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? "+" : "-"}${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات المحفظة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatBox('إجمالي الإيداعات', '${_wallet?.totalDeposited ?? 0} ريال', Colors.green, Icons.arrow_downward),
              _buildStatBox('إجمالي السحوبات', '${_wallet?.totalWithdrawn ?? 0} ريال', Colors.red, Icons.arrow_upward),
              _buildStatBox('إجمالي المكافآت', '${_wallet?.totalEarned ?? 0} ريال', Colors.amber, Icons.star),
              _buildStatBox('عدد المعاملات', '${_transactions.length}', Colors.blue, Icons.history),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ملخص المحفظة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow('الرصيد الحالي', '${_wallet?.balance ?? 0} ريال', isTotal: true),
                _buildSummaryRow('الرصيد المعلق', '${_wallet?.pendingBalance ?? 0} ريال'),
                _buildSummaryRow('إجمالي الإيداعات', '${_wallet?.totalDeposited ?? 0} ريال'),
                _buildSummaryRow('إجمالي السحوبات', '${_wallet?.totalWithdrawn ?? 0} ريال'),
                _buildSummaryRow('صافي الأرباح', '${(_wallet?.totalEarned ?? 0) - (_wallet?.totalSpent ?? 0)} ريال'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
            ),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
