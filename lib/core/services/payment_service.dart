import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.sehatak.com/payment';
  
  // المحافظ اليمنية المدعومة
  static const List<String> supportedWallets = [
    'فلوسك',
    'جوالي',
    'جيب',
    'كاش',
    'إيزي',
    'كريمي جوال',
    'كاش ONE',
    'موبايل موني',
  ];

  // توزيع الأرباح
  static const Map<String, double> profitDistribution = {
    'platform': 0.15,  // 15%
    'doctor': 0.60,    // 60%
    'employee': 0.25,  // 25%
  };

  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String serviceType,
    required String serviceId,
    required String paymentMethod,
    required String walletNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
          'serviceType': serviceType,
          'serviceId': serviceId,
          'paymentMethod': paymentMethod,
          'walletNumber': walletNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // حساب التوزيع
        final distribution = _calculateDistribution(amount);
        await _saveTransaction(data['transactionId'], {
          'amount': amount,
          'distribution': distribution,
          'status': 'completed',
        });
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'فشل الدفع'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Map<String, double> _calculateDistribution(double amount) {
    return {
      'platform': amount * profitDistribution['platform']!,
      'doctor': amount * profitDistribution['doctor']!,
      'employee': amount * profitDistribution['employee']!,
    };
  }

  Future<void> _saveTransaction(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = prefs.getStringList('transactions') ?? [];
    transactions.add(jsonEncode({'id': id, ...data, 'date': DateTime.now().toIso8601String()}));
    await prefs.setStringList('transactions', transactions);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = prefs.getStringList('transactions') ?? [];
    return transactions.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<double> getWalletBalance(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/wallet/$userId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['balance'] ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
