import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cart = [
    {'name': 'باراسيتامول 500mg', 'price': 500, 'qty': 2, 'image': '💊'},
    {'name': 'فيتامين د 1000IU', 'price': 1200, 'qty': 1, 'image': '💊'},
    {'name': 'جهاز قياس ضغط', 'price': 8500, 'qty': 1, 'image': '📟'},
  ];

  int _selDelivery = 0;
  String _selPayment = 'floosak';
  bool _ordered = false;

  final List<Map<String, dynamic>> _deliveries = [
    {'name': 'تسهيل', 'time': '30-45 دقيقة', 'price': 500},
    {'name': 'توصيل', 'time': '45-60 دقيقة', 'price': 300},
    {'name': 'اطلبني', 'time': '20-30 دقيقة', 'price': 700},
  ];

  final List<Map<String, dynamic>> _payments = [
    {'id': 'floosak', 'name': 'فلوسك', 'icon': 'floosak_icon.png', 'color': AppColors.primary},
    {'id': 'jawali', 'name': 'جوالي', 'icon': 'Jawali_icon.png', 'color': AppColors.teal},
    {'id': 'cash', 'name': 'كاش', 'icon': 'كاش_icon.png', 'color': AppColors.warning},
    {'id': 'jeeb', 'name': 'جيب', 'icon': 'جيب_icon.png', 'color': AppColors.purple},
    {'id': 'easy', 'name': 'إيزي', 'icon': 'ايزي_icon.png', 'color': AppColors.info},
    {'id': 'yemen_wallet', 'name': 'يمن وولت', 'icon': 'Yemen Wallet_icon.png', 'color': AppColors.success},
    {'id': 'mobile_money', 'name': 'موبايل موني', 'icon': 'موبايل موني انترنت_icon.png', 'color': AppColors.orange},
    {'id': 'cash_one', 'name': 'كاش ONE', 'icon': 'كاش ONE_icon.png', 'color': AppColors.indigo},
    {'id': 'alkarimi', 'name': 'الكريمي', 'icon': 'الكريمي جوال_icon.png', 'color': AppColors.pink},
  ];

  double get _total {
    double sum = 0;
    for (var item in _cart) {
      sum += (item['price'] as int) * (item['qty'] as int);
    }
    return sum + _deliveries[_selDelivery]['price'];
  }

  void _updateQty(int index, int delta) {
    setState(() {
      final newQty = _cart[index]['qty'] + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index]['qty'] = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _ordered ? _buildSuccess() : _buildCart(),
    );
  }

  Widget _buildCart() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cart.length,
            itemBuilder: (context, index) {
              final item = _cart[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            item['image'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${item['price']} ريال',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => _updateQty(index, -1),
                          ),
                          Text(
                            '${item['qty']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => _updateQty(index, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'طريقة التوصيل',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._deliveries.asMap().entries.map((entry) {
                final idx = entry.key;
                final co = entry.value;
                final sel = idx == _selDelivery;
                return GestureDetector(
                  onTap: () => setState(() => _selDelivery = idx),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 20,
                          color: sel ? AppColors.primary : AppColors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                co['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: sel ? AppColors.primary : null,
                                ),
                              ),
                              Text(
                                'خلال ${co['time']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${co['price']} ريال',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: sel ? AppColors.primary : AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
              const Text(
                'طريقة الدفع',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _payments.map((p) {
                  final sel = _selPayment == p['id'];
                  final color = p['color'] as Color;
                  return GestureDetector(
                    onTap: () => setState(() => _selPayment = p['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? color.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: sel ? color : AppColors.lightGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/payment/${p['icon']}',
                            width: 36,
                            height: 36,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.payment,
                              color: color,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color: sel ? color : AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الإجمالي',
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),
                  Text(
                    '${_total.toStringAsFixed(0)} ريال',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _ordered = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'تأكيد الطلب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: AppColors.success,
          ),
          const SizedBox(height: 20),
          const Text(
            'تم تأكيد الطلب بنجاح!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'سيتم توصيل طلبك قريباً',
            style: TextStyle(fontSize: 16, color: AppColors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _ordered = false;
                _cart.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('العودة للتسوق'),
          ),
        ],
      ),
    );
  }
}
