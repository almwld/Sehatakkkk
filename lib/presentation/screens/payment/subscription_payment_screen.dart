import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String planId;  // ✅ فقط الـ ID

  const SubscriptionPaymentScreen({
    super.key,
    required this.planId,
  });

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  late Future<DocumentSnapshot> _planData;
  String _selectedWallet = 'floosak';
  bool _isLoading = false;
  String _errorMessage = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 'floosak',
      'name': 'فلوسك',
      'icon': 'assets/icons/payment/floosak_icon.png',
      'number': '4582 ****',
      'balance': 12500,
      'color': AppColors.primary,
    },
    {
      'id': 'cash',
      'name': 'كاش',
      'icon': 'assets/icons/payment/كاش_icon.png',
      'number': '7891 ****',
      'balance': 8200,
      'color': AppColors.success,
    },
    {
      'id': 'jawali',
      'name': 'جوالي',
      'icon': 'assets/icons/payment/Jawali_icon.png',
      'number': '3456 ****',
      'balance': 4300,
      'color': AppColors.info,
    },
    {
      'id': 'jeeb',
      'name': 'جيب',
      'icon': 'assets/icons/payment/جيب_icon.png',
      'number': '9012 ****',
      'balance': 0,
      'color': AppColors.warning,
    },
    {
      'id': 'easy',
      'name': 'إيزي',
      'icon': 'assets/icons/payment/ايزي_icon.png',
      'number': '5678 ****',
      'balance': 0,
      'color': AppColors.purple,
    },
    {
      'id': 'yemen_wallet',
      'name': 'يمن وولت',
      'icon': 'assets/icons/payment/Yemen Wallet_icon.png',
      'number': '1234 ****',
      'balance': 15000,
      'color': AppColors.teal,
    },
    {
      'id': 'mobile_money',
      'name': 'موبايل موني',
      'icon': 'assets/icons/payment/موبايل موني انترنت_icon.png',
      'number': '6789 ****',
      'balance': 3200,
      'color': AppColors.orange,
    },
    {
      'id': 'cash_one',
      'name': 'كاش ONE',
      'icon': 'assets/icons/payment/كاش ONE_icon.png',
      'number': '2345 ****',
      'balance': 6700,
      'color': AppColors.indigo,
    },
    {
      'id': 'alkarimi',
      'name': 'الكريمي',
      'icon': 'assets/icons/payment/الكريمي جوال_icon.png',
      'number': '8901 ****',
      'balance': 9100,
      'color': AppColors.pink,
    },
  ];

  @override
  void initState() {
    super.initState();
    _planData = _firestore.collection('plans').doc(widget.planId).get();
  }

  // ✅ جلب الرصيد من Firestore
  Future<double> _getWalletBalance(String walletId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final doc = await _firestore
          .collection('wallets')
          .doc(user.uid)
          .collection('wallets')
          .doc(walletId)
          .get();

      if (doc.exists) {
        return (doc.data()?['balance'] ?? 0).toDouble();
      }
      return 0;
    } catch (e) {
      print('❌ فشل جلب الرصيد: $e');
      return 0;
    }
  }

  // ✅ تحديث الرصيد
  Future<bool> _updateWalletBalance(String walletId, double newBalance) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('wallets')
          .doc(user.uid)
          .collection('wallets')
          .doc(walletId)
          .set({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('❌ فشل تحديث الرصيد: $e');
      return false;
    }
  }

  // ✅ تسجيل المعاملة
  Future<void> _recordTransaction(String walletId, double amount, String planName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('wallets')
          .doc(user.uid)
          .collection('transactions')
          .add({
        'walletId': walletId,
        'amount': amount,
        'type': 'payment',
        'planName': planName,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ فشل تسجيل المعاملة: $e');
    }
  }

  // ✅ تحديث حالة الاشتراك
  Future<void> _updateSubscriptionStatus(String userId, String planName) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'subscription': {
          'plan': planName,
          'status': 'active',
          'startDate': FieldValue.serverTimestamp(),
          'expiryDate': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 30)),
          ),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ فشل تحديث الاشتراك: $e');
    }
  }

  // ✅ معالجة الدفع
  Future<void> _processPayment(String planName, double price) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'يرجى تسجيل الدخول أولاً';
          _isLoading = false;
        });
        return;
      }

      if (price == 0) {
        // ✅ باقة مجانية
        await _updateSubscriptionStatus(user.uid, planName);
        setState(() => _isLoading = false);
        _showSuccessDialog(planName, price);
        return;
      }

      final currentBalance = await _getWalletBalance(_selectedWallet);
      if (currentBalance < price) {
        setState(() {
          _errorMessage = 'الرصيد غير كافي';
          _isLoading = false;
        });
        _showErrorDialog(_errorMessage);
        return;
      }

      final newBalance = currentBalance - price;
      final success = await _updateWalletBalance(_selectedWallet, newBalance);

      if (!success) {
        setState(() {
          _errorMessage = 'فشل تحديث الرصيد';
          _isLoading = false;
        });
        _showErrorDialog(_errorMessage);
        return;
      }

      await _recordTransaction(_selectedWallet, price, planName);
      await _updateSubscriptionStatus(user.uid, planName);

      setState(() => _isLoading = false);
      _showSuccessDialog(planName, price);

    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isLoading = false;
      });
      _showErrorDialog(_errorMessage);
    }
  }

  void _showSuccessDialog(String planName, double price) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 80),
            const SizedBox(height: 16),
            const Text('✅ تم الدفع بنجاح!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('تم تفعيل الباقة $planName بنجاح', style: const TextStyle(color: AppColors.grey, fontSize: 14), textAlign: TextAlign.center),
            if (price > 0)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('تم خصم ${price.toStringAsFixed(0)} ريال من محفظتك', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('تم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('❌ فشل الدفع', style: TextStyle(color: AppColors.error)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الدفع'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _planData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('حدث خطأ: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _planData = _firestore.collection('plans').doc(widget.planId).get();
                      });
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('الباقة غير موجودة'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final planName = data['name'] ?? 'باقة';
          final price = (data['price'] ?? 0).toDouble();
          final period = data['period'] ?? 'شهرياً';
          final features = List<String>.from(data['features'] ?? []);
          final isFree = price == 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ بنر الباقة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.star_rounded, color: Colors.white, size: 32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        planName,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'اشتراك $period',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isFree ? 'مجاني' : '${price.toStringAsFixed(0)} ريال',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          if (!isFree) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '/$period',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildBadge('شامل الضريبة', Icons.check_circle),
                          _buildBadge('توصيل مجاني', Icons.local_shipping),
                          if (isFree) _buildBadge('مجاني', Icons.favorite),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ المميزات
                if (features.isNotEmpty) ...[
                  const Text('مميزات الباقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(f, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                ],

                // ✅ طرق الدفع (للباقات المدفوعة فقط)
                if (!isFree) ...[
                  const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('المحافظ الإلكترونية اليمنية المدعومة', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  ..._wallets.map((wallet) => FutureBuilder<double>(
                    future: _getWalletBalance(wallet['id']),
                    builder: (context, snapshot) {
                      final balance = snapshot.data ?? wallet['balance'].toDouble();
                      return _buildWalletTile(wallet, isDark, balance);
                    },
                  )),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('سيتم إضافة ربط محفظة جديدة قريباً'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      label: const Text('ربط محفظة جديدة', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ✅ زر الدفع
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _processPayment(planName, price),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFree ? AppColors.success : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            isFree ? 'تفعيل مجاناً' : 'تأكيد الدفع (${price.toStringAsFixed(0)} ريال)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    isFree ? 'سيتم تفعيل الباقة فوراً' : 'سيتم خصم المبلغ من محفظتك الإلكترونية',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWalletTile(Map<String, dynamic> wallet, bool isDark, double balance) {
    final isSelected = _selectedWallet == wallet['id'];
    final color = wallet['color'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedWallet = wallet['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : (isDark ? const Color(0xFF1A2540) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF2D3A54) : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Image.asset(
                wallet['icon'],
                width: 32,
                height: 32,
                color: color,
                errorBuilder: (_, __, ___) => Icon(Icons.account_balance_wallet, color: color, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wallet['name'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? color : null)),
                  const SizedBox(height: 2),
                  Text(wallet['number'], style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '${balance.toStringAsFixed(0)} ر.ي',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
