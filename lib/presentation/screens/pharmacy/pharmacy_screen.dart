import 'package:flutter/material.dart';
import 'pharmacy_marketplace_screen.dart';

/// نقطة الدخول الرسمية للصيدلية داخل Sehatak.
/// Marketplace هو المصدر الحي للمنتجات المنشورة والمعتمدة؛ لا توجد أسعار checkout موثوقة في العميل.
class PharmacyScreen extends StatelessWidget {
  final ScrollController? scrollController;
  const PharmacyScreen({super.key, this.scrollController});
  @override
  Widget build(BuildContext context) => const PharmacyMarketplaceScreen();
}
