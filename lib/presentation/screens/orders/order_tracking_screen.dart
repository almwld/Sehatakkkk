import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Scaffold(
    backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: const Text('تتبع الطلب'),
      backgroundColor: const Color(0xFF0D5257),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'قريباً...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'خدمة تتبع الطلب قيد التطوير',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  );
}
}
