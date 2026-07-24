import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/subscription_model.dart';
import 'package:sehatak/presentation/screens/payment/payment_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  final String? providerId;
  final String? providerName;
  const SubscriptionsScreen({super.key, this.providerId, this.providerName});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _selectedPeriod = 'monthly';
  String? _currentPlanId;
  bool _isLoading = true;

  final List<String> _periods = ['شهري', 'سنوي (خصم 20%)'];

  @override
  void initState() {
    super.initState();
    _loadCurrentSubscription();
  }

  Future<void> _loadCurrentSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final query = FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: user.uid);

      final snap = widget.providerId != null
          ? await query.where('providerId', isEqualTo: widget.providerId).get()
          : await query.get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        final data = doc.data();
        if (data['status'] == 'active') {
          setState(() => _currentPlanId = data['plan']);
        }
      }
    } catch (e) {
      print('Error loading subscription: $e');
    }

    setState(() => _isLoading = false);
  }

  double get _priceMultiplier {
    return _selectedPeriod == 'سنوي (خصم 20%)' ? 12 * 0.8 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الباقات والاشتراكات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text('يرجى تسجيل الدخول'))
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: _periods.asMap().entries.map((entry) {
                          final index = entry.key;
                          final period = entry.value;
                          final isSelected = _selectedPeriod == (index == 0 ? 'monthly' : 'yearly');
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedPeriod = index == 0 ? 'monthly' : 'yearly';
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey),
                              ),
                              child: Text(
                                period,
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
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: SubscriptionPlans.plans.length,
                        itemBuilder: (context, index) {
                          final plan = SubscriptionPlans.plans[index];
                          final isActive = _currentPlanId == plan['id'];
                          final color = Color(plan['color'] as int);
                          final isPopular = plan['popular'] == true;
                          final price = (plan['price'] as int) * _priceMultiplier;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A2540) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive ? AppColors.primary : (isPopular ? color.withOpacity(0.3) : Colors.transparent),
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isPopular)
                                  BoxShadow(
                                    color: color.withOpacity(0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(plan['icon'] as IconData, color: color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan['name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          if (isPopular)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                '🌟 الأكثر طلباً',
                                                style: TextStyle(color: Colors.amber, fontSize: 10),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('✅ نشط', style: TextStyle(color: Colors.green, fontSize: 10)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${price.toInt()} ريال',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedPeriod == 'yearly' ? '/ سنة' : '/ شهر',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...(plan['features'] as List).map((feature) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isActive ? Icons.check_circle : Icons.check_circle_outline,
                                        color: isActive ? Colors.green : color,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        feature,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isActive
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PaymentScreen(
                                                  amount: price.toInt(),
                                                  packageName: plan['name'],
                                                  providerId: widget.providerId,
                                                  providerName: widget.providerName,
                                                  isSubscription: true,
                                                ),
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isActive ? Colors.grey : color,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      isActive ? '✅ مشترك' : 'اشترك الآن ${price.toInt()} ريال',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
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
}
