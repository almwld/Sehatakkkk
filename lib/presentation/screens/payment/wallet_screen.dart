import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _balance = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _wallets = [
    {'id': 'floosak', 'name': 'فلوسك', 'icon': 'assets/icons/payment/floosak_icon.png', 'color': AppColors.primary},
    {'id': 'cash', 'name': 'كاش', 'icon': 'assets/icons/payment/كاش_icon.png', 'color': AppColors.success},
    {'id': 'jawali', 'name': 'جوالي', 'icon': 'assets/icons/payment/Jawali_icon.png', 'color': AppColors.info},
    {'id': 'jeeb', 'name': 'جيب', 'icon': 'assets/icons/payment/جيب_icon.png', 'color': AppColors.warning},
    {'id': 'easy', 'name': 'إيزي', 'icon': 'assets/icons/payment/ايزي_icon.png', 'color': AppColors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final doc = await _firestore.collection('wallets').doc(user.uid).get();
      if (doc.exists) {
        _balance = (doc.data()?['balance'] ?? 0).toDouble();
      }
    } catch (e) {
      print('❌ فشل تحميل الرصيد: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addFunds(double amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('wallets').doc(user.uid).set({
        'balance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      setState(() => _balance += amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم إضافة ${amount.toStringAsFixed(0)} ريال'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل الإضافة: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '💰 الرصيد', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: '📊 المعاملات', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBalanceTab(isDark),
          _buildTransactionsTab(),
        ],
      ),
    );
  }

  Widget _buildBalanceTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ الرصيد
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12)],
            ),
            child: Column(
              children: [
                const Text('الرصيد الحالي', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  _isLoading ? '...' : '${_balance.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddFundsDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('شحن', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.compare_arrows, size: 18),
                        label: const Text('تحويل', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ✅ المحافظ
          const Text('المحافظ المدعومة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _wallets.map((wallet) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (wallet['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (wallet['color'] as Color).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(wallet['icon'], width: 24, height: 24, errorBuilder: (_, __, ___) => Icon(Icons.wallet, color: wallet['color'], size: 20)),
                    const SizedBox(width: 6),
                    Text(wallet['name'], style: TextStyle(color: wallet['color'], fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final user = _auth.currentUser;
    if (user == null) return const Center(child: Text('يرجى تسجيل الدخول'));

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('wallets')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }

        final transactions = snapshot.data?.docs ?? [];
        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 60, color: AppColors.grey),
                SizedBox(height: 16),
                Text('لا توجد معاملات', style: TextStyle(color: AppColors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final data = transactions[index].data() as Map<String, dynamic>;
            final isIncome = data['type'] == 'income';
            final amount = (data['amount'] ?? 0).toDouble();
            final date = (data['timestamp'] as Timestamp).toDate();

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                border: Border.all(color: isIncome ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isIncome ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? AppColors.success : AppColors.error),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['description'] ?? (isIncome ? 'إيداع' : 'سحب'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('dd/MM/yyyy HH:mm').format(date), style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${amount.toStringAsFixed(0)} ر.ي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFundsDialog() {
    final amountCtrl = TextEditingController();
    final List<int> amounts = [1000, 2000, 5000, 10000, 20000, 50000];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('شحن المحفظة', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر المبلغ أو أدخله يدوياً', style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amounts.map((amount) {
                return GestureDetector(
                  onTap: () => amountCtrl.text = amount.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text('$amount ر.ي', style: const TextStyle(fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال مبلغ صحيح'), backgroundColor: AppColors.warning),
                );
                return;
              }
              Navigator.pop(context);
              _addFunds(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('شحن'),
          ),
        ],
      ),
    );
  }
}
